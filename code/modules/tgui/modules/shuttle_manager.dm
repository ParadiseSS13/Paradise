RESTRICT_TYPE(/datum/ui_module/admin/shuttle_manager)

#define SEND_IMMEDIATELY "Send Immediately"

/datum/ui_module/admin/shuttle_manager
	name = "Shuttle Manager"

/datum/ui_module/admin/shuttle_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/admin/shuttle_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleManager", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/ui_module/admin/shuttle_manager/ui_data(mob/user)
	. = list(
		"refuel_delay" = SSshuttle.refuel_delay,
		"custom_shuttle_ordered" = SSshuttle.custom_shuttle_ordered,
		"emergency" = list(
			"home_port" = null,
			"away_port" = null,
		),
	)

	.["sec_level"] = list(
		"number" = SSsecurity_level.get_current_level_as_number(),
		"name" = SSsecurity_level.get_current_level_as_text(),
		"color" = SSsecurity_level.current_security_level?.color,
	)

	.["mobile_docking_ports"] = list()
	for(var/obj/docking_port/mobile/port in SSshuttle.mobile_docking_ports)
		.["mobile_docking_ports"] += list(port.ui_data(user))

	.["stationary_docking_ports"] = list()
	for(var/obj/docking_port/stationary/port in SSshuttle.stationary_docking_ports)
		.["stationary_docking_ports"] += list(port.ui_data(user))
		if(port.id == "emergency_home")
			.["emergency"]["home_port"] = port
		else if(port.id == "emergency_away")
			.["emergency"]["away_port"] = port

	.["transit_docking_ports"] = list()
	for(var/obj/docking_port/stationary/transit/port in SSshuttle.transit_docking_ports)
		.["transit_docking_ports"] += list(port.ui_data(user))

	.["emergency"]["port"] = SSshuttle.emergency?.ui_data(user)
	.["emergency"]["call_time"] = SSshuttle.emergencyCallTime
	.["emergency"]["dock_time"] = SSshuttle.emergencyDockTime
	.["emergency"]["escape_time"] = SSshuttle.emergencyEscapeTime
	.["emergency"]["locked_in"] = SSshuttle.emergency_locked_in
	.["emergency"]["timer_str"] = SSshuttle.emergency.getTimerStr()

	.["emergency"]["hostiles"] = list()
	for(var/datum/hostile in SSshuttle.hostile_environments)
		var/list/hostile_data = list(
			"name" = "Unnamed Datum",
			"type" = hostile.type,
			"uid" = hostile.UID(),
		)
		if(isatom(hostile))
			var/atom/hostile_atom = hostile
			hostile_data["name"] = hostile_atom.name
			hostile_data["loc"] = list("x" = hostile_atom.x, "y" = hostile_atom.y, "z" = hostile_atom.z)
		else if(isclient(hostile))
			var/client/hostile_client = hostile
			hostile_data["name"] = hostile_client.ckey
			hostile_data["loc"] = list("x" = hostile_client.mob?.x, "y" = hostile_client.mob?.y, "z" = hostile_client.mob?.z)

		.["emergency"]["hostiles"] += list(hostile_data)

/datum/ui_module/admin/shuttle_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("jump_to_coords")
			var/x = params["x"]
			var/y = params["y"]
			var/z = params["z"]

			usr.client.jumptocoord(x, y, z)

		if("vv")
			SSuser_verbs.invoke_verb(usr, /datum/user_verb/debug_variables, locateUID(params["uid"]))

		if("call_shuttle")
			SSuser_verbs.invoke_verb(usr, /datum/user_verb/call_shuttle)

		if("cancel_shuttle")
			SSuser_verbs.invoke_verb(usr, /datum/user_verb/cancel_shuttle)

		if("deny_shuttle")
			SSuser_verbs.invoke_verb(usr, /datum/user_verb/deny_shuttle)

		if("fast_travel")
			var/obj/docking_port/mobile/port = locateUID(params["uid"])
			port.setTimer(50)
			log_and_message_admins("fast travelled [port]")

		if("force_send_eshuttle")
			var/obj/docking_port/stationary/emergency_home = SSshuttle.getDock("emergency_home")
			var/obj/docking_port/stationary/emergency_away = SSshuttle.getDock("emergency_away")
			if(emergency_away.get_docked() == SSshuttle.emergency)
				SSshuttle.emergency.dock(emergency_home, force = TRUE)
				log_and_message_admins("force sent the shuttle to the station")
			else if(emergency_home.get_docked() == SSshuttle.emergency)
				SSshuttle.emergency.dock(emergency_away, force = TRUE)
				log_and_message_admins("force sent the shuttle to Centcom")
		if("remove_hostile")
			var/datum/hostile = locateUID(params["uid"])
			if(!istype(hostile))
				to_chat(usr, SPAN_WARNING("Could not find datum matching hostile."))
				return
			SSshuttle.clearHostileEnvironment(hostile)
			log_and_message_admins("removed the hostile shuttle launch environment [hostile.type].")

		if("send_to_port")
			var/obj/docking_port/stationary/docking_port = locateUID(params["uid"])
			if(!istype(docking_port))
				to_chat(usr, SPAN_WARNING("Could not find docking port `[params["name"]]` ([params["uid"]])."))
				return TRUE

			INVOKE_ASYNC(src, PROC_REF(request_shuttle), docking_port, ui)

		if("send_shuttle")
			var/obj/docking_port/mobile/mobile_port = locateUID(params["uid"])
			if(!istype(mobile_port))
				to_chat(usr, SPAN_WARNING("Could not find shuttle `[params["name"]]` ([params["uid"]])."))
				return TRUE

			INVOKE_ASYNC(src, PROC_REF(send_shuttle), mobile_port, ui)

	return TRUE

/datum/ui_module/admin/shuttle_manager/proc/request_shuttle(obj/docking_port/stationary/docking_port, datum/tgui/ui)
	var/list/valid_shuttles = list()
	for(var/obj/docking_port/mobile/mobile_port in SSshuttle.mobile_docking_ports)
		if(mobile_port.canDock(docking_port) == SHUTTLE_CAN_DOCK)
			valid_shuttles[mobile_port.name] = mobile_port

	var/shuttle = tgui_input_list(ui.user, "Choose which shuttle to send:", "Send Shuttle to [docking_port.name]", valid_shuttles)
	if(shuttle)
		var/obj/docking_port/mobile/shuttle_port = valid_shuttles[shuttle]
		var/send_directly = tgui_alert(ui.user, "Send immediately or include transit time?", "Launch Method", list(SEND_IMMEDIATELY, "Transit"))
		if(send_directly == SEND_IMMEDIATELY)
			shuttle_port.dock(docking_port, force = TRUE)
		else
			shuttle_port.request(docking_port)
		log_and_message_admins_mob_user(ui.user, "sent the shuttle `[shuttle_port.name]` to port `[docking_port.name]` at [ADMIN_COORDJMP(docking_port)].")
		to_chat(ui.user, SPAN_WARNING("Attempting to send Shuttle [shuttle_port.name] to port [docking_port.name]."))
	else
		to_chat(ui.user, SPAN_NOTICE("Cancelled Send Shuttle."))

/datum/ui_module/admin/shuttle_manager/proc/send_shuttle(obj/docking_port/mobile/mobile_port, datum/tgui/ui)
	var/list/valid_docks = list()
	for(var/obj/docking_port/stationary/port in SSshuttle.stationary_docking_ports)
		if(istype(port, /obj/docking_port/stationary/transit))
			continue
		if(mobile_port.canDock(port) == SHUTTLE_CAN_DOCK)
			valid_docks[port.name] = port

	var/dock = tgui_input_list(ui.user, "Choose docking port:", "Send Shuttle [mobile_port.name]", valid_docks)
	if(dock)
		var/obj/docking_port/stationary/docking_port = valid_docks[dock]
		var/send_directly = tgui_alert(ui.user, "Send immediately or include transit time?", "Launch Method", list(SEND_IMMEDIATELY, "Transit"))
		if(send_directly == SEND_IMMEDIATELY)
			mobile_port.dock(docking_port, force = TRUE)
		else
			mobile_port.request(docking_port)
		log_and_message_admins_mob_user(ui.user, "sent the shuttle `[mobile_port.name]` to port `[docking_port.name]` at [ADMIN_COORDJMP(docking_port)].")
		to_chat(ui.user, SPAN_WARNING("Attempting to send Shuttle [mobile_port.name] to port [docking_port.name]."))
	else
		to_chat(ui.user, SPAN_NOTICE("Cancelled Send Shuttle."))
#undef SEND_IMMEDIATELY
