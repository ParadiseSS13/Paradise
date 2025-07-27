/turf/simulated/floor/mech_bay_recharge_floor
	name = "mech bay recharge station"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"

/turf/simulated/floor/mech_bay_recharge_floor/airless
	icon_state = "recharge_floor_asteroid"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/obj/machinery/mech_bay_recharge_port
	name = "mech bay power port"
	density = TRUE
	anchored = TRUE
	dir = EAST
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	var/obj/mecha/recharging_mecha
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/max_charge = 50
	var/on = FALSE
	var/turf/recharging_turf = null

/obj/machinery/mech_bay_recharge_port/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mech_recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_recharge_turf()

/obj/machinery/mech_bay_recharge_port/Destroy()
	if(recharge_console)
		recharge_console.recharge_port = null
		recharge_console.update_icon()
	recharge_console = null
	recharging_mecha = null
	recharging_turf = null
	return ..()

/obj/machinery/mech_bay_recharge_port/proc/update_recharge_turf()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mech_recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_recharge_turf()

/obj/machinery/mech_bay_recharge_port/proc/update_recharging_mecha()
	if(recharging_mecha)
		if(recharging_mecha.loc == recharging_turf)
			return  // no need to update anything
		// it wandered away
		UnregisterSignal(recharging_mecha, COMSIG_PARENT_QDELETING)
		recharging_mecha = null
	// try to find a new mecha if we don't have any
	if(!recharging_mecha)
		recharging_mecha = locate(/obj/mecha) in recharging_turf
		if(recharging_mecha)
			// so that we don't hold references to it after it's gone, and not causing GC issues
			RegisterSignal(recharging_mecha, COMSIG_PARENT_QDELETING, PROC_REF(on_mecha_qdel))

/obj/machinery/mech_bay_recharge_port/proc/on_mecha_qdel()
	recharging_mecha = null

/obj/machinery/mech_bay_recharge_port/upgraded/unsimulated/process()
	update_recharging_mecha()
	if(recharging_mecha && recharging_mecha.cell)
		if(recharging_mecha.cell.charge < recharging_mecha.cell.maxcharge)
			var/delta = min(max_charge, recharging_mecha.cell.maxcharge - recharging_mecha.cell.charge)
			recharging_mecha.give_power(delta)

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/MC
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		MC += C.rating
	max_charge = MC * 25

/obj/machinery/mech_bay_recharge_port/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return TRUE

/obj/machinery/mech_bay_recharge_port/wrench_act(mob/user, obj/item/I)
	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return TRUE

/obj/machinery/mech_bay_recharge_port/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mech_bay_recharge_port/process()
	if(stat & NOPOWER || !recharge_console)
		return
	var/had_mecha = !isnull(recharging_mecha)
	update_recharging_mecha()
	if(had_mecha != !isnull(recharging_mecha)) // the presence of mecha is not what it used to be
		// update_icon is somewhat expensive, so try not to call it too often
		recharge_console.update_icon()
	var/obj/item/stock_parts/cell/cell = recharging_mecha?.cell
	if(!cell)
		return
	if(cell.charge < cell.maxcharge)
		var/delta = min(max_charge, cell.maxcharge - cell.charge)
		recharging_mecha.give_power(delta)
		use_power(delta * 150)
		recharge_console.update_icon()

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	icon_keyboard = "tech_key"
	icon_screen = "recharge_comp"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/mech_bay_power_console
	var/obj/machinery/mech_bay_recharge_port/recharge_port


/obj/machinery/computer/mech_bay_power_console/update_overlays()
	if(stat & (NOPOWER|BROKEN))
		icon_screen = "recharge_comp" // off
	else
		var/obj/item/stock_parts/cell/cell = recharge_port?.recharging_mecha?.cell
		if(!cell)
			icon_screen = "recharge_comp" // don't have a reachable cell to charge
		else if(cell.charge >= cell.maxcharge)
			icon_screen = "recharge_comp" // fully charged
		else
			icon_screen = "recharge_comp_on" // now we working!
	. = ..()

/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port)
		for(var/D in GLOB.cardinal)
			var/turf/A = get_step(src, D)
			A = get_step(A, D)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in A
			if(recharge_port)
				if(!recharge_port.recharge_console)
					break
				else
					recharge_port = null
	if(recharge_port)
		if(!recharge_port.recharge_console)
			recharge_port.recharge_console = src
		else
			recharge_port = null


/obj/machinery/computer/mech_bay_power_console/Destroy()
	if(recharge_port)
		recharge_port.recharge_console = null
	return ..()

/obj/machinery/computer/mech_bay_power_console/attack_hand(mob/user as mob)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/mech_bay_power_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/mech_bay_power_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechBayConsole", name)
		ui.open()

/obj/machinery/computer/mech_bay_power_console/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("reconnect")
			reconnect()
			. = TRUE
			update_icon()

/obj/machinery/computer/mech_bay_power_console/ui_data(mob/user)
	var/data = list()
	if(!recharge_port)
		reconnect()
	if(recharge_port && !QDELETED(recharge_port))
		data["recharge_port"] = list("mech" = null)
		if(recharge_port.recharging_mecha && !QDELETED(recharge_port.recharging_mecha))
			data["recharge_port"]["mech"] = list("health" = recharge_port.recharging_mecha.obj_integrity, "maxhealth" = recharge_port.recharging_mecha.max_integrity, "cell" = null, "name" = recharge_port.recharging_mecha.name)
			if(recharge_port.recharging_mecha.cell && !QDELETED(recharge_port.recharging_mecha.cell))
				data["recharge_port"]["mech"]["cell"] = list(
				"charge" = recharge_port.recharging_mecha.cell.charge,
				"maxcharge" = recharge_port.recharging_mecha.cell.maxcharge
				)
	return data

/obj/machinery/computer/mech_bay_power_console/Initialize(mapload)
	reconnect()
	update_icon()
	return ..()
