
//////////////////////////////////////
//			Driver Button			//
//////////////////////////////////////

/obj/machinery/driver_button
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	anchored = TRUE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, RAD = 100, FIRE = 90, ACID = 70)
	idle_power_consumption = 2
	active_power_consumption = 4
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	/// ID tag of the driver to hook to
	var/id_tag = "default"
	/// Are we active?
	var/active = FALSE
	/// Range of drivers + blast doors to hit
	var/range = 7

/obj/machinery/button/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/driver_button/Initialize(mapload, place_dir)
	. = ..()
	switch(place_dir)
		if(NORTH)
			pixel_y = 25
		if(SOUTH)
			pixel_y = -25
		if(EAST)
			pixel_x = 25
		if(WEST)
			pixel_x = -25

/obj/machinery/driver_button/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/driver_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		attack_hand(user)

/obj/machinery/driver_button/wrench_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.tool_use_check(user, 0))
		return

	user.visible_message("<span class='notice'>[user] starts unwrenching [src] from the wall...</span>", "<span class='notice'>You are unwrenching [src] from the wall...</span>", "<span class='warning'>You hear ratcheting.</span>")
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return

	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/driver_button(get_turf(src))
	qdel(src)

/obj/machinery/driver_button/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(active)
		return

	add_fingerprint(user)

	use_power(5)

	// Start us off
	launch_sequence()

/obj/machinery/driver_button/proc/launch_sequence()
	active = TRUE
	icon_state = "launcheract"

	// Time sequence
	// OPEN DOORS
	// Wait 2 seconds
	// LAUNCH
	// Wait 5 seconds
	// CLOSE
	// Then make not active

	for(var/obj/machinery/door/poddoor/M in range(src, range))
		if(M.id_tag == id_tag && !M.protected)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/door, open))

	// 2 seconds after previous invocation

	for(var/obj/machinery/mass_driver/M in range(src, range))
		if(M.id_tag == id_tag)
			addtimer(CALLBACK(M, TYPE_PROC_REF(/obj/machinery/mass_driver, drive)), 2 SECONDS)

	// We want this 5 seconds after open, so the delay is 7 seconds from this proc

	for(var/obj/machinery/door/poddoor/M in range(src, range))
		if(M.id_tag == id_tag && !M.protected)
			addtimer(CALLBACK(M, TYPE_PROC_REF(/obj/machinery/door, close)), 7 SECONDS)

	// And rearm us
	addtimer(CALLBACK(src, PROC_REF(rearm)), 7 SECONDS)

/obj/machinery/driver_button/proc/rearm()
	icon_state = "launcherbtt"
	active = FALSE

/obj/machinery/driver_button/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(!Adjacent(user))
		return

	var/new_tag = clean_input("Enter a new ID tag", "ID Tag", id_tag, user)

	if(new_tag && Adjacent(user))
		id_tag = new_tag


//////////////////////////////////////
//			Ignition Switch			//
//////////////////////////////////////

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = FALSE
	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 4

/obj/machinery/ignition_switch/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/ignition_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(active)
		return

	use_power(5)

	active = TRUE
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in SSmachines.get_by_type(/obj/machinery/sparker))
		if(M.id == id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/sparker, spark))

	for(var/obj/machinery/igniter/M in SSmachines.get_by_type(/obj/machinery/igniter))
		if(M.id == id)
			use_power(50)
			M.on = !M.on
			M.icon_state = "igniter[M.on]"

	addtimer(CALLBACK(src, PROC_REF(rearm)), 5 SECONDS)

/obj/machinery/ignition_switch/proc/rearm()
	icon_state = "launcherbtt"
	active = FALSE
