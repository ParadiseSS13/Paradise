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
	var/datum/supply_packs/misc/bsa/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/bsa]"]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_cannon/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/bsa/full/B)
		if(B && !B.stat && is_station_contact(B.z))
			return TRUE
	return FALSE

/obj/machinery/bsa
	icon = 'icons/obj/machines/particle_accelerator3.dmi'
	density = 1
	anchored = 1

/obj/machinery/bsa/back
	name = "Bluespace Artillery Generator"
	desc = "Generates cannon pulse. Needs to be linked with a fusor. "
	icon_state = "power_box"

/obj/machinery/bsa/back/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		M.buffer = src
		to_chat(user, "<span class='notice'>You store linkage information in [W]'s buffer.</span>")
	else if(istype(W, /obj/item/wrench))
		default_unfasten_wrench(user, W, 10)
		return TRUE
	else
		return ..()

/obj/machinery/bsa/front
	name = "Bluespace Artillery Bore"
	desc = "Do not stand in front of cannon during operation. Needs to be linked with a fusor."
	icon_state = "emitter_center"

/obj/machinery/bsa/front/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		M.buffer = src
		to_chat(user, "<span class='notice'>You store linkage information in [W]'s buffer.</span>")
	else if(istype(W, /obj/item/wrench))
		default_unfasten_wrench(user, W, 10)
		return TRUE
	else
		return ..()

/obj/machinery/bsa/middle
	name = "Bluespace Artillery Fusor"
	desc = "Contents classifed by Nanotrasen Naval Command. Needs to be linked with the other BSA parts using multitool."
	icon_state = "fuel_chamber"
	var/obj/machinery/bsa/back/back
	var/obj/machinery/bsa/front/front

/obj/machinery/bsa/middle/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		if(M.buffer)
			if(istype(M.buffer,/obj/machinery/bsa/back))
				back = M.buffer
				M.buffer = null
				to_chat(user, "<span class='notice'>You link [src] with [back].</span>")
			else if(istype(M.buffer,/obj/machinery/bsa/front))
				front = M.buffer
				M.buffer = null
				to_chat(user, "<span class='notice'>You link [src] with [front].</span>")
	else if(istype(W, /obj/item/wrench))
		default_unfasten_wrench(user, W, 10)
		return TRUE
	else
		return ..()

/obj/machinery/bsa/middle/proc/check_completion()
	if(!front || !back)
		return "No linked parts detected!"
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
	var/power_used_per_shot = 2000000 //enough to kil standard apc - todo : make this use wires instead and scale explosion power with it
	var/last_fire_time = 0 // The time at which the gun was last fired
	var/reload_cooldown = 600 // The gun's cooldown

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
	power_used_per_shot = 0
	reload_cooldown = 100

/obj/machinery/bsa/full/admin/east
	icon_state = "cannon_east"
	cannon_direction = EAST

/obj/machinery/bsa/full/proc/get_front_turf()
	switch(dir)
		if(WEST)
			return locate(x - 6,y,z)
		if(EAST)
			return locate(x + 4,y,z)
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
	reload()

/obj/machinery/bsa/full/proc/fire(mob/user, turf/bullseye)
	var/turf/point = get_front_turf()
	for(var/turf/T in getline(get_step(point,dir),get_target_turf()))
		T.ex_act(1)
		for(var/atom/A in T)
			A.ex_act(1)

	point.Beam(get_target_turf(), icon_state = "bsa_beam", time = 50, maxdistance = world.maxx, beam_type = /obj/effect/ebeam/deadly) //ZZZAP
	playsound(src, 'sound/machines/bsa_fire.ogg', 100, 1)

	message_admins("[key_name_admin(user)] has launched an artillery strike.")
	explosion(bullseye,ex_power,ex_power*2,ex_power*4)

	reload()

/obj/machinery/bsa/full/proc/reload()
	use_power(power_used_per_shot)
	last_fire_time = world.time / 10

/obj/item/circuitboard/machine/bsa/back
	name = "Bluespace Artillery Generator (Machine Board)"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
							/obj/item/stock_parts/capacitor/quadratic = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	name = "Bluespace Artillery Fusor (Machine Board)"
	build_path = /obj/machinery/bsa/middle
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 20,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	name = "Bluespace Artillery Bore (Machine Board)"
	build_path = /obj/machinery/bsa/front
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/stock_parts/manipulator/femto = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/computer/bsa_control
	name = "Bluespace Artillery Controls (Computer Board)"
	build_path = /obj/machinery/computer/bsa_control
	origin_tech = "engineering=2;combat=2;bluespace=2"

/obj/machinery/computer/bsa_control
	name = "Bluespace Artillery Control"
	var/obj/machinery/bsa/full/cannon
	var/notice
	var/target
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/computer/bsa_control
	icon = 'icons/obj/machines/particle_accelerator3.dmi'
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

/obj/machinery/computer/bsa_control/admin/Initialize()
	..()
	if(!cannon)
		cannon = deploy()

/obj/machinery/computer/bsa_control/Destroy()
	if(cannon && cannon.controller == src)
		cannon.controller = null
		cannon = null
	return ..()

/obj/machinery/computer/bsa_control/process()
	..()
	update_icon()

/obj/machinery/computer/bsa_control/update_icon()
	if(stat & BROKEN)
		icon_state = icon_state_broken
	else if(stat & NOPOWER)
		icon_state = icon_state_nopower
	else if(cannon && (cannon.last_fire_time + cannon.reload_cooldown) > (world.time / 10))
		icon_state = icon_state_reloading
	else if(cannon)
		icon_state = icon_state_active
	else
		icon_state = initial(icon_state)

/obj/machinery/computer/bsa_control/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/bsa_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "bsa.tmpl", name, 400, 305)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/bsa_control/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/list/data = list()
	data["connected"] = cannon
	data["notice"] = notice
	if(target)
		data["target"] = get_target_name()

	if(cannon)
		var/reload_cooldown = cannon.reload_cooldown
		var/last_fire_time = cannon.last_fire_time
		var/time_to_wait = max(0, round(reload_cooldown - ((world.time / 10) - last_fire_time)))
		var/minutes = max(0, round(time_to_wait / 60))
		var/seconds = max(0, time_to_wait - (60 * minutes))

		data["reloadtime_mins"] = minutes
		data["reloadtime_secs"] = (seconds < 10) ? "0[seconds]" : seconds
		data["ready"] = minutes == 0 && seconds == 0
	else
		data["ready"] = FALSE

	return data

/obj/machinery/computer/bsa_control/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["build"])
		cannon = deploy()
		. = TRUE
	else if(href_list["fire"])
		fire(usr)
		. = TRUE
	else if(href_list["recalibrate"])
		calibrate(usr)
		. = TRUE
	update_icon()

/obj/machinery/computer/bsa_control/proc/calibrate(mob/user)
	var/list/gps_locators = list()
	for(var/obj/item/gps/G in GPS_list) //nulls on the list somehow
		gps_locators[G.gpstag] = G

	var/list/options = gps_locators
	if(area_aim)
		options += target_all_areas ? ghostteleportlocs : teleportlocs
	var/V = input(user,"Select target", "Select target",null) in options|null
	target = options[V]

/obj/machinery/computer/bsa_control/proc/get_target_name()
	if(istype(target,/area))
		var/area/A = target
		return A.name
	else if(istype(target,/obj/item/gps))
		var/obj/item/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	if(istype(target,/area))
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
	cannon.fire(user, get_impact_turf())

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
	s.set_up(4, 0, get_turf(centerpiece))
	s.start()
	var/obj/machinery/bsa/full/cannon = new(get_turf(centerpiece),centerpiece.get_cannon_direction())
	cannon.controller = src
	qdel(centerpiece.front)
	qdel(centerpiece.back)
	qdel(centerpiece)
	return cannon
