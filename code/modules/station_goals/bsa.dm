// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts

/datum/station_goal/bluespace_cannon
	name = "Bluespace Artillery"

/datum/station_goal/bluespace_cannon/get_report()
	return {"<b>Bluespace Artillery position construction</b><br>
	Our military presence is inadequate in your sector. We need you to construct a BSA-[rand(1,99)] Artillery position aboard your station.
	<br><br>
	Its base parts should be available for shipping by your cargo shuttle.
	<br>
	-Nanotrasen Naval Command"}

/datum/station_goal/bluespace_cannon/on_report()
	//Unlock BSA parts
	var/datum/supply_packs/misc/station_goal/bsa/P = SSeconomy.supply_packs["[/datum/supply_packs/misc/station_goal/bsa]"]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_cannon/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/bsa/full/B in SSmachines.get_by_type(/obj/machinery/bsa/full))
		if(B && !B.stat && is_station_contact(B.z))
			return TRUE
	return FALSE

/obj/machinery/bsa
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = TRUE
	anchored = TRUE

/obj/machinery/bsa/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 1 SECONDS)
	return TRUE

/obj/machinery/bsa/multitool_act(mob/living/user, obj/item/multitool/M)
	M.buffer = src
	to_chat(user, "<span class='notice'>You store linkage information in [M]'s buffer.</span>")
	return TRUE

/obj/machinery/bsa/back
	name = "Bluespace Artillery Generator"
	desc = "Generates cannon pulse. Needs to be linked with a fusor. "
	icon_state = "power_box"

/obj/machinery/bsa/front
	name = "Bluespace Artillery Bore"
	desc = "Do not stand in front of cannon during operation. Needs to be linked with a fusor."
	icon_state = "emitter_center"

/obj/machinery/bsa/middle
	name = "Bluespace Artillery Fusor"
	desc = "Contents classifed by Nanotrasen Naval Command. Needs to be linked with the other BSA parts using multitool."
	icon_state = "fuel_chamber"
	var/obj/machinery/bsa/back/back
	var/obj/machinery/bsa/front/front

/obj/machinery/bsa/middle/multitool_act(mob/living/user, obj/item/multitool/M)
	. = TRUE
	if(!M.buffer)
		to_chat(user, "<span class='warning'>[M]'s buffer is empty!</span>")
		return
	if(istype(M.buffer,/obj/machinery/bsa/back))
		back = M.buffer
		M.buffer = null
		to_chat(user, "<span class='notice'>You link [src] with [back].</span>")
	else if(istype(M.buffer,/obj/machinery/bsa/front))
		front = M.buffer
		M.buffer = null
		to_chat(user, "<span class='notice'>You link [src] with [front].</span>")

/obj/machinery/bsa/middle/proc/check_completion()
	if(!front || !back)
		return "No multitool-linked parts detected!"
	if(!front.anchored || !back.anchored || !anchored)
		return "Linked parts unwrenched!"
	if(front.y != y || back.y != y || !(front.x > x && back.x < x || front.x < x && back.x > x) || front.z != z || back.z != z)
		return "Parts misaligned!"
	if(!has_space())
		return "Not enough free space!"

/obj/machinery/bsa/middle/proc/has_space()
	var/cannon_dir = get_cannon_direction()
	var/x_min
	var/x_max
	switch(cannon_dir)
		if(EAST)
			x_min = x - BSA_SIZE_BACK
			x_max = x + BSA_SIZE_FRONT
		if(WEST)
			x_min = x + BSA_SIZE_BACK
			x_max = x - BSA_SIZE_FRONT

	for(var/turf/T in block(locate(x_min,y-1,z),locate(x_max,y+1,z)))
		if(T.density || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/bsa/middle/proc/get_cannon_direction()
	if(front.x > x && back.x < x)
		return EAST
	else if(front.x < x && back.x > x)
		return WEST

/obj/machinery/bsa/full
	name = "Bluespace Artillery"
	desc = "Long range bluespace artillery."
	icon = 'icons/obj/lavaland/cannon.dmi'
	icon_state = "cannon_west"

	var/obj/machinery/computer/bsa_control/controller
	var/cannon_direction = WEST
	var/static/image/top_layer = null
	var/ex_power = 3
	/// Amount of energy required to reload the BSA (Joules)
	var/energy_used_per_shot = 2 MJ //enough to kil standard apc - todo : make this use wires instead and scale explosion power with it
	/// The gun's cooldown
	var/reload_cooldown_time = 10 MINUTES
	/// Are we trying to reload? Should only be true if we failed to reload due to lack of power.
	var/try_reload = FALSE
	COOLDOWN_DECLARE(firing_cooldown)

	pixel_y = -32
	pixel_x = -192
	bound_width = 352
	bound_x = -192

/obj/machinery/bsa/full/Destroy()
	if(controller && controller.cannon == src)
		controller.cannon = null
		controller = null
	return ..()

/obj/machinery/bsa/full/east
	icon_state = "cannon_east"
	cannon_direction = EAST

/obj/machinery/bsa/full/admin
	energy_used_per_shot = 0
	reload_cooldown_time = 100 SECONDS

/obj/machinery/bsa/full/admin/east
	icon_state = "cannon_east"
	cannon_direction = EAST

/obj/machinery/bsa/full/proc/get_front_turf()
	switch(dir)
		if(WEST)
			return locate(x - 7,y,z)
		if(EAST)
			return locate(x + 5,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_back_turf()
	switch(dir)
		if(WEST)
			return locate(x + 4,y,z)
		if(EAST)
			return locate(x - 6,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_target_turf()
	switch(dir)
		if(WEST)
			return locate(1,y,z)
		if(EAST)
			return locate(world.maxx,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/New(loc, direction)
	..()

	if(direction)
		cannon_direction = direction

	switch(cannon_direction)
		if(WEST)
			dir = WEST
			pixel_x = -192
			top_layer = image("icons/obj/lavaland/orbital_cannon.dmi", "top_west")
			top_layer.layer = 4.1
			icon_state = "cannon_west"
		if(EAST)
			dir = EAST
			top_layer = image("icons/obj/lavaland/orbital_cannon.dmi", "top_east")
			top_layer.layer = 4.1
			icon_state = "cannon_east"
	overlays += top_layer

/obj/machinery/bsa/full/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/bsa/full/LateInitialize(mapload)
	. = ..()
	reload() // so we don't try and use the powernet before it initializes


/obj/machinery/bsa/full/proc/fire(mob/user, turf/bullseye, target)
	if(!COOLDOWN_FINISHED(src, firing_cooldown))
		return
	var/turf/point = get_front_turf()
	for(var/turf/T in get_line(get_step(point,dir),get_target_turf()))
		T.ex_act(EXPLODE_DEVASTATE)
		for(var/atom/A in T)
			A.ex_act(EXPLODE_DEVASTATE)

	point.Beam(get_target_turf(), icon_state = "bsa_beam", time = 50, maxdistance = world.maxx, beam_type = /obj/effect/ebeam/deadly) //ZZZAP
	new /obj/effect/temp_visual/bsa_splash(point, dir)
	playsound(src, 'sound/machines/bsa_fire.ogg', 100, 1)
	if(istype(target, /obj/item/gps))
		var/obj/item/gps/G = target
		message_admins("[key_name_admin(user)] has launched an artillery strike at GPS named [G.gpstag].")

	else
		message_admins("[key_name_admin(user)] has launched an artillery strike.")//Admin BSA firing, just targets a room, which the explosion says

	log_admin("[key_name(user)] has launched an artillery strike.") // Line below handles logging the explosion to disk
	explosion(bullseye,ex_power,ex_power*2,ex_power*4, cause = "BSA strike")

	reload()

/obj/machinery/bsa/full/proc/reload()
	if(machine_powernet?.powernet_apc?.cell?.charge KJ >= energy_used_per_shot)
		try_reload = FALSE
		use_power(energy_used_per_shot)
		COOLDOWN_START(src, firing_cooldown, reload_cooldown_time)
	else
		try_reload = TRUE

/// If we failed a reload keep trying until the APC has enough energy available.
/obj/machinery/bsa/full/process()
	if(try_reload)
		reload()

/obj/item/circuitboard/machine/bsa/back
	board_name = "Bluespace Artillery Generator"
	icon_state = "command"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
							/obj/item/stock_parts/capacitor/quadratic = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	board_name = "Bluespace Artillery Fusor"
	icon_state = "command"
	build_path = /obj/machinery/bsa/middle
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 20,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	board_name = "Bluespace Artillery Bore"
	icon_state = "command"
	build_path = /obj/machinery/bsa/front
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/stock_parts/manipulator/femto = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/computer/bsa_control
	board_name = "Bluespace Artillery Controls"
	icon_state = "command"
	build_path = /obj/machinery/computer/bsa_control
	origin_tech = "engineering=2;combat=2;bluespace=2"

/obj/machinery/computer/bsa_control
	name = "Bluespace Artillery Control"
	var/obj/machinery/bsa/full/cannon
	var/notice
	var/atom/target
	power_state = NO_POWER_USE
	circuit = /obj/item/circuitboard/computer/bsa_control
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	var/icon_state_broken = "control_box"
	var/icon_state_nopower = "control_boxw"
	var/icon_state_reloading = "control_boxp1"
	var/icon_state_active = "control_boxp0"
	layer = 3.1 // Just above the cannon sprite

	var/area_aim = FALSE //should also show areas for targeting
	var/target_all_areas = FALSE //allows all areas (including admin areas) to be targeted

/obj/machinery/computer/bsa_control/admin
	area_aim = TRUE
	target_all_areas = TRUE

/obj/machinery/computer/bsa_control/admin/Initialize(mapload)
	. = ..()
	if(!cannon)
		cannon = deploy()

/obj/machinery/computer/bsa_control/Destroy()
	if(cannon && cannon.controller == src)
		cannon.controller = null
		cannon = null
	return ..()

/obj/machinery/computer/bsa_control/process()
	..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/computer/bsa_control/update_icon_state()
	if(stat & BROKEN)
		icon_state = icon_state_broken
	else if(stat & NOPOWER)
		icon_state = icon_state_nopower
	else if(cannon && (!COOLDOWN_FINISHED(cannon, firing_cooldown)))
		icon_state = icon_state_reloading
	else if(cannon)
		icon_state = icon_state_active
	else
		icon_state = initial(icon_state)

/obj/machinery/computer/bsa_control/update_overlays()
	return list()

/obj/machinery/computer/bsa_control/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/bsa_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/bsa_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BlueSpaceArtilleryControl", name)
		ui.open()

/obj/machinery/computer/bsa_control/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = cannon
	data["notice"] = notice
	if(target)
		data["target"] = get_target_name()
	if(cannon)
		data["reloadtime_text"] = cannon.try_reload ? "Insufficient Energy For Reloading" : seconds_to_clock(round(COOLDOWN_TIMELEFT(cannon, firing_cooldown) / 10))
		data["ready"] = !cannon.try_reload && COOLDOWN_FINISHED(cannon, firing_cooldown)
	else
		data["ready"] = FALSE
	return data

/obj/machinery/computer/bsa_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("build")
			cannon = deploy()
		if("fire")
			fire(usr)
		if("recalibrate")
			calibrate(usr)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/computer/bsa_control/proc/calibrate(mob/user)
	var/list/gps_locators = list()
	for(var/obj/item/gps/G in GLOB.GPS_list) //nulls on the list somehow
		gps_locators[G.gpstag] = G

	var/list/options = gps_locators
	if(area_aim)
		options += target_all_areas ? SSmapping.ghostteleportlocs : SSmapping.teleportlocs
	var/choose = tgui_input_list(user, "Select target", "Target",  options)
	if(!choose)
		return
	target = options[choose]

/obj/machinery/computer/bsa_control/proc/get_target_name()
	if(isarea(target))
		var/area/A = target
		return A.name
	else if(istype(target,/obj/item/gps))
		var/obj/item/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	if(isarea(target))
		return pick(get_area_turfs(target))
	else if(istype(target,/obj/item/gps))
		return get_turf(target)

/obj/machinery/computer/bsa_control/proc/fire(mob/user)
	if(!cannon || !target)
		return
	if(cannon.stat)
		notice = "Cannon unpowered!"
		return
	notice = null
	investigate_log("[key_name(user)] has fired the BSA at [ADMIN_VERBOSEJMP(cannon)] at the target [ADMIN_VERBOSEJMP(target)].", INVESTIGATE_BOMB)
	cannon.fire(user, get_impact_turf(), target)

/obj/machinery/computer/bsa_control/proc/deploy()
	var/obj/machinery/bsa/full/prebuilt = locate() in range(7, src) //In case of adminspawn
	if(prebuilt)
		prebuilt.controller = src
		return prebuilt

	var/obj/machinery/bsa/middle/centerpiece = locate() in range(7, src)
	if(!centerpiece)
		notice = "No BSA parts detected nearby."
		return null
	notice = centerpiece.check_completion()
	if(notice)
		return null
	//Totally nanite construction system not an immersion breaking spawning
	var/datum/effect_system/smoke_spread/s = new
	s.set_up(4, FALSE, centerpiece)
	s.start()
	var/obj/machinery/bsa/full/cannon = new(get_turf(centerpiece),centerpiece.get_cannon_direction())
	cannon.controller = src
	qdel(centerpiece.front)
	qdel(centerpiece.back)
	qdel(centerpiece)
	return cannon
