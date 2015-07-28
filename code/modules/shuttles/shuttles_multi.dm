//This is a holder for things like the Vox and Nuke shuttle.
/datum/shuttle/multi_shuttle
	var/cloaked = 1
	var/can_cloak = 1
	var/at_origin = 1
	var/returned_home = 0
	var/move_time = 240
	var/cooldown = 20
	var/last_move = 0	//the time at which we last moved

	var/announcer
	var/arrival_message
	var/departure_message

	var/area/interim
	var/area/last_departed
	var/list/destinations
	var/area/origin

/datum/shuttle/multi_shuttle/New()
	..()
	if(origin) 
		last_departed = origin

/datum/shuttle/multi_shuttle/move(var/area/origin, var/area/destination)
	..()
	last_move = world.time
	if (destination == src.origin)
		returned_home = 1

/datum/shuttle/multi_shuttle/proc/announce_departure()
	if(cloaked || isnull(departure_message))
		return

	command_announcement.Announce(departure_message,(announcer ? announcer : "Central Command"))

/datum/shuttle/multi_shuttle/proc/announce_arrival()
	if(cloaked || isnull(arrival_message))
		return

	command_announcement.Announce(arrival_message,(announcer ? announcer : "Central Command"))

/obj/machinery/computer/shuttle_control/multi
	icon_screen = "shuttle"
	icon_keyboard = "med_key"
	var/is_syndicate = 0
	var/warn_on_return = 0
	
/obj/machinery/computer/shuttle_control/multi/New()
	..()
	if(is_syndicate)
		icon_screen = "syndishuttle"
		icon_keyboard = "syndie_key"

/obj/machinery/computer/shuttle_control/multi/attack_hand(user as mob)
	if(..(user))
		return 1
	
	if(!allowed(user))
		user << "\red Access Denied."
		return 1	
	
	ui_interact(user)
	
/obj/machinery/computer/shuttle_control/multi/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(MS))
		return

	var/shuttle_state
	switch(MS.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"
	if(MS.moving_status == SHUTTLE_IDLE && (MS.last_move + MS.cooldown*10) > world.time)
		shuttle_state = "charging"

	var/shuttle_status
	if (MS.moving_status != SHUTTLE_IDLE)
		shuttle_status = "Proceeding to destination."
	else if (MS.at_origin)
		shuttle_status = "Standing-by at base."
	else
		var/area/areacheck = get_area(src)
		shuttle_status = "Standing-by at [sanitize(areacheck.name)]."		

	data = list(
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"can_launch" = can_launch(),
		"can_return_to_base" = can_return_to_base(),
		"can_cloak" = MS.can_cloak,
		"cloaked" = MS.cloaked,
		"is_syndicate" = is_syndicate
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "shuttle_control_multi_console.tmpl", "[shuttle_tag] Ship Control", 470, 310)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/multi/proc/can_launch()
	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(MS))
		return
	
	if (MS.moving_status != SHUTTLE_IDLE)
		return 0

	if((MS.last_move + MS.cooldown * 10) > world.time)
		return 0
	
	return 1
	
/obj/machinery/computer/shuttle_control/multi/proc/can_return_to_base()
	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(MS))
		return
	
	if(MS.moving_status != SHUTTLE_IDLE)
		return 0

	if((MS.last_move + MS.cooldown * 10) > world.time)
		return 0
	
	if(MS.at_origin)
		return 0
	
	return 1
	
/obj/machinery/computer/shuttle_control/multi/proc/return_to_base()
	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(MS))
		return
	
	if(!can_return_to_base())
		return

	if(warn_on_return)
		var/confirm = alert("Returning to your home base will end your mission. Are you sure you want to return to base?", "Confirm Return to Base", "Yes", "No")
		if(confirm == "No")
			return

	MS.long_jump(MS.last_departed,MS.origin,MS.interim,MS.move_time)
	MS.last_departed = MS.origin
	MS.at_origin = 1
	
/obj/machinery/computer/shuttle_control/multi/proc/toggle_cloak()
	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(MS))
		return
	
	MS.cloaked = !MS.cloaked
	
/obj/machinery/computer/shuttle_control/multi/proc/launch_multi()
	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(MS))
		return
	
	if(MS.moving_status != SHUTTLE_IDLE)
		return 0

	if((MS.last_move + MS.cooldown * 10) > world.time)
		return 0

	var/choice = input("Select a destination.") as null|anything in MS.destinations
	if(!choice) 
		return

	if(MS.at_origin)
		MS.announce_arrival()
		MS.last_departed = MS.origin
		MS.at_origin = 0
		MS.long_jump(MS.last_departed, MS.destinations[choice], MS.interim, MS.move_time)
		MS.last_departed = MS.destinations[choice]
		return

	else if(choice == MS.origin)
		MS.announce_departure()

	MS.short_jump(MS.last_departed, MS.destinations[choice])
	MS.last_departed = MS.destinations[choice]
	
/obj/machinery/computer/shuttle_control/multi/Topic(href, href_list)
	if(..())
		return 1
	
	if(!allowed(usr))
		return 1

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/datum/shuttle/multi_shuttle/MS = shuttle_controller.shuttles[shuttle_tag]
	if(!istype(MS)) 
		return

	if(href_list["start"])
		return_to_base()

	if(href_list["toggle_cloak"])
		toggle_cloak()

	if(href_list["move_multi"])
		launch_multi()
