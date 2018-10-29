//--------------------------------------------
// Base omni device
//--------------------------------------------
/obj/machinery/atmospherics/omni
	name = "omni device"
	icon = 'icons/atmos/omni_devices.dmi'
	icon_state = "base"
	use_power = IDLE_POWER_USE
	initialize_directions = 0

	can_unwrench = 1

	var/on = 0
	var/configuring = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/tag_north = ATM_NONE
	var/tag_south = ATM_NONE
	var/tag_east = ATM_NONE
	var/tag_west = ATM_NONE

	var/overlays_on[5]
	var/overlays_off[5]
	var/overlays_error[2]
	var/underlays_current[4]

	var/list/ports = new()

/obj/machinery/atmospherics/omni/New()
	..()
	icon_state = "base"

	ports = new()
	for(var/d in cardinal)
		var/datum/omni_port/new_port = new(src, d)
		switch(d)
			if(NORTH)
				new_port.mode = tag_north
			if(SOUTH)
				new_port.mode = tag_south
			if(EAST)
				new_port.mode = tag_east
			if(WEST)
				new_port.mode = tag_west
		if(new_port.mode > 0)
			initialize_directions |= d
		ports += new_port

	build_icons()

/obj/machinery/atmospherics/omni/Destroy()
	for(var/datum/omni_port/P in ports)
		if(P.node)
			P.node.disconnect(src)
			P.node = null
			nullifyPipenet(P.parent)
	return ..()

/obj/machinery/atmospherics/omni/atmos_init()
	..()
	for(var/datum/omni_port/P in ports)
		if(P.node || P.mode == 0)
			continue
		for(var/obj/machinery/atmospherics/target in get_step(src, P.dir))
			if(target.initialize_directions & get_dir(target,src))
				P.node = target
				break

	for(var/datum/omni_port/P in ports)
		P.update = 1

	update_ports()

/obj/machinery/atmospherics/omni/update_icon()
	if(stat & NOPOWER)
		overlays = overlays_off
		on = 0
	else if(error_check())
		overlays = overlays_error
		on = 0
	else
		overlays = on ? (overlays_on) : (overlays_off)

	underlays = underlays_current

	return

/obj/machinery/atmospherics/omni/proc/error_check()
	return

/obj/machinery/atmospherics/omni/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/omni/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	if(!istype(W, /obj/item/wrench))
		return ..()

	if(can_unwrench)
		var/int_pressure = 0
		for(var/datum/omni_port/P in ports)
			int_pressure += P.air.return_pressure()
		var/datum/gas_mixture/env_air = loc.return_air()
		if((int_pressure - env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			to_chat(user, "<span class='danger'>You cannot unwrench [src], it is too exerted due to internal pressure.</span>")
			add_fingerprint(user)
			return 1
		playsound(loc, W.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"<span class='notice'>You have unfastened \the [src].</span>", \
				"You hear a ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			qdel(src)
	else
		return ..()

/obj/machinery/atmospherics/omni/attack_hand(mob/user)
	if(..())
		return

	add_fingerprint(usr)
	ui_interact(user)

/obj/machinery/atmospherics/omni/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/omni/proc/build_icons()
	if(!check_icon_cache())
		return

	var/core_icon = null
	if(istype(src, /obj/machinery/atmospherics/omni/mixer))
		core_icon = "mixer"
	else if(istype(src, /obj/machinery/atmospherics/omni/filter))
		core_icon = "filter"
	else
		return

	//directional icons are layers 1-4, with the core icon on layer 5
	if(core_icon)
		overlays_off[5] = GLOB.pipe_icon_manager.get_atmos_icon("omni", , , core_icon)
		overlays_on[5] = GLOB.pipe_icon_manager.get_atmos_icon("omni", , , core_icon + "_glow")

		overlays_error[1] = GLOB.pipe_icon_manager.get_atmos_icon("omni", , , core_icon)
		overlays_error[2] = GLOB.pipe_icon_manager.get_atmos_icon("omni", , , "error")

/obj/machinery/atmospherics/omni/proc/update_port_icons()
	if(!check_icon_cache())
		return

	for(var/datum/omni_port/P in ports)
		if(P.update)
			var/ref_layer = 0
			switch(P.dir)
				if(NORTH)
					ref_layer = 1
				if(SOUTH)
					ref_layer = 2
				if(EAST)
					ref_layer = 3
				if(WEST)
					ref_layer = 4

			if(!ref_layer)
				continue

			var/list/port_icons = select_port_icons(P)
			if(port_icons)
				if(P.node)
					underlays_current[ref_layer] = port_icons["pipe_icon"]
				else
					underlays_current[ref_layer] = null
				overlays_off[ref_layer] = port_icons["off_icon"]
				overlays_on[ref_layer] = port_icons["on_icon"]
			else
				underlays_current[ref_layer] = null
				overlays_off[ref_layer] = null
				overlays_on[ref_layer] = null

	update_icon()

/obj/machinery/atmospherics/omni/proc/select_port_icons(var/datum/omni_port/P)
	if(!istype(P))
		return

	if(P.mode > 0)
		var/ic_dir = dir_name(P.dir)
		var/ic_on = ic_dir
		var/ic_off = ic_dir
		switch(P.mode)
			if(ATM_INPUT)
				ic_on += "_in_glow"
				ic_off += "_in"
			if(ATM_OUTPUT)
				ic_on += "_out_glow"
				ic_off += "_out"
			if(ATM_O2 to ATM_N2O)
				ic_on += "_filter"
				ic_off += "_out"

		ic_on = GLOB.pipe_icon_manager.get_atmos_icon("omni", , , ic_on)
		ic_off = GLOB.pipe_icon_manager.get_atmos_icon("omni", , , ic_off)

		var/pipe_state
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(T.intact && istype(P.node, /obj/machinery/atmospherics/pipe) && P.node.level == 1 )
			//pipe_state = GLOB.pipe_icon_manager.get_atmos_icon("underlay_down", P.dir, color_cache_name(P.node))
			pipe_state = GLOB.pipe_icon_manager.get_atmos_icon("underlay", P.dir, color_cache_name(P.node), "down")
		else
			//pipe_state = GLOB.pipe_icon_manager.get_atmos_icon("underlay_intact", P.dir, color_cache_name(P.node))
			pipe_state = GLOB.pipe_icon_manager.get_atmos_icon("underlay", P.dir, color_cache_name(P.node), "intact")

		return list("on_icon" = ic_on, "off_icon" = ic_off, "pipe_icon" = pipe_state)

/obj/machinery/atmospherics/omni/update_underlays()
	for(var/datum/omni_port/P in ports)
		P.update = 1
	update_ports()

/obj/machinery/atmospherics/omni/hide(var/i)
	update_underlays()

/obj/machinery/atmospherics/omni/proc/update_ports()
	sort_ports()
	update_port_icons()
	for(var/datum/omni_port/P in ports)
		P.update = 0

/obj/machinery/atmospherics/omni/proc/sort_ports()
	return

// Pipenet procs
/obj/machinery/atmospherics/omni/build_network(remove_deferral = FALSE)
	for(var/datum/omni_port/P in ports)
		if(!P.parent)
			P.parent = new /datum/pipeline()
			P.parent.build_pipeline(src)
	..()

/obj/machinery/atmospherics/omni/disconnect(obj/machinery/atmospherics/reference)
	for(var/datum/omni_port/P in ports)
		if(reference == P.node)
			if(istype(P.node, /obj/machinery/atmospherics/pipe))
				qdel(P.parent)
			P.node = null
	update_ports()

/obj/machinery/atmospherics/omni/nullifyPipenet(datum/pipeline/P)
	..()
	if(!P)
		return
	for(var/datum/omni_port/PO in ports)
		if(P == PO.parent)
			PO.parent.other_airs -= PO.air
			PO.parent = null

/obj/machinery/atmospherics/omni/returnPipenetAir(datum/pipeline/P)
	for(var/datum/omni_port/PO in ports)
		if(P == PO.parent)
			return PO.air

/obj/machinery/atmospherics/omni/pipeline_expansion(datum/pipeline/P)
	if(P)
		for(var/datum/omni_port/PO in ports)
			if(PO.parent == P)
				return list(PO.node)
	else
		var/list/nodes = list()
		for(var/datum/omni_port/PO in ports)
			nodes += PO.node

		return nodes

/obj/machinery/atmospherics/omni/setPipenet(datum/pipeline/P, obj/machinery/atmospherics/A)
	for(var/datum/omni_port/PO in ports)
		if(A == PO.node)
			PO.parent = P

/obj/machinery/atmospherics/omni/returnPipenet(obj/machinery/atmospherics/A)
	for(var/datum/omni_port/P in ports)
		if(A == P.node)
			return P.parent

/obj/machinery/atmospherics/omni/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	for(var/datum/omni_port/P in ports)
		if(Old == P.parent)
			P.parent = New


/obj/machinery/atmospherics/omni/process_atmos()
	..()
	for(var/datum/omni_port/port in ports)
		if(!port.parent)
			return 0
	return 1
