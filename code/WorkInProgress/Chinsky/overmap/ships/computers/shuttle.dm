//Shuttle controller computer for shuttles going between sectors
/datum/shuttle/ferry/var/range = 0	//how many overmap tiles can shuttle go, for picking destinatiosn and returning.
/obj/machinery/computer/shuttle_control/explore
	name = "exploration shuttle console"
	shuttle_tag = "Exploration"
	req_access = list()
	var/landing_type	//area for shuttle ship-side
	var/obj/effect/map/destination //current destination
	var/obj/effect/map/home //current destination

/obj/machinery/computer/shuttle_control/explore/initialize()
	..()
	home = map_sectors["[z]"]
	shuttle_tag = "[shuttle_tag]-[z]"
	if(!shuttle_controller.shuttles[shuttle_tag])
		var/datum/shuttle/ferry/shuttle = new()
		shuttle.warmup_time = 10
		shuttle.area_station = locate(landing_type)
		shuttle.area_offsite = shuttle.area_station
		shuttle_controller.shuttles[shuttle_tag] = shuttle
		shuttle_controller.process_shuttles += shuttle
		testing("Exploration shuttle '[shuttle_tag]' at zlevel [z] successfully added.")

//Sets destination to new sector. Can be null.
/obj/machinery/computer/shuttle_control/explore/proc/update_destination(var/obj/effect/map/D)
	destination = D
	if(destination && shuttle_controller.shuttles[shuttle_tag])
		var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
		shuttle.area_offsite = destination.shuttle_landing
		testing("Shuttle controller [shuttle_tag] now sends shuttle to [destination]")
		shuttle_controller.shuttles[shuttle_tag] = shuttle

//Gets all sectors with landing zones in shuttle's range
/obj/machinery/computer/shuttle_control/explore/proc/get_possible_destinations()
	var/list/res = list()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	for (var/obj/effect/map/S in orange(shuttle.range, home))
		if(S.shuttle_landing)
			res += S
	return res

//Checks if current destination is still reachable
/obj/machinery/computer/shuttle_control/explore/proc/check_destination()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	return shuttle && destination && get_dist(home, destination) <= shuttle.range

/obj/machinery/computer/shuttle_control/explore/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	//If we are already there, or can't reach place anymore, reset destination
	if(!shuttle.location && !check_destination())
		destination = null

	//check if shuttle can fly at all
	var/can_go = !isnull(destination)
	var/current_destination = destination ? destination.name : "None"
	//shuttle doesn't need destination set to return home, as long as it's in range.
	if(shuttle.location)
		current_destination = "Return"
		var/area/offsite = shuttle.area_offsite
		var/obj/effect/map/cur_loc = map_sectors["[offsite.z]"]
		can_go = (get_dist(home,cur_loc) <= shuttle.range)

	//disable picking locations if there are none, or shuttle is already off-site
	var/list/possible_d = get_possible_destinations()
	var/can_pick = !shuttle.location && possible_d.len

	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"

	var/shuttle_status
	switch (shuttle.process_state)
		if(IDLE_STATE)
			if (shuttle.in_use)
				shuttle_status = "Busy."
			else if (!shuttle.location)
				shuttle_status = "Standing-by at station."
			else
				shuttle_status = "Standing-by at offsite location."
		if(WAIT_LAUNCH)
			shuttle_status = "Shuttle has recieved command and will depart shortly."
		if(WAIT_ARRIVE)
			shuttle_status = "Proceeding to destination."
		if(WAIT_FINISH)
			shuttle_status = "Arriving at destination now."

	data = list(
		"destination_name" = current_destination,
		"can_pick" = can_pick,
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.docking_controller? 1 : 0,
		"docking_status" = shuttle.docking_controller? shuttle.docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.docking_controller? shuttle.docking_controller.override_enabled : null,
		"can_launch" = can_go && shuttle.can_launch(),
		"can_cancel" = can_go && shuttle.can_cancel(),
		"can_force" = can_go && shuttle.can_force(),
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "shuttle_control_console_exploration.tmpl", "[shuttle_tag] Shuttle Control", 470, 310)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/explore/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	if(href_list["pick"])
		var/obj/effect/map/self = map_sectors["[z]"]
		if(self)
			var/list/possible_d = get_possible_destinations()
			var/obj/effect/map/D
			if(possible_d.len)
				D = input("Choose shuttle destination", "Shuttle Destination") as null|anything in possible_d
			update_destination(D)

	if(href_list["move"])
		shuttle.launch(src)
	if(href_list["force"])
		shuttle.force_launch(src)
	else if(href_list["cancel"])
		shuttle.cancel_launch(src)