/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/active = 0 //This gets set to 1 on all devices except the one where the initial request was made.
	var/event = ""
	var/screen = 1
	var/list/ert_chosen = list()
	var/confirmed = 0 //This variable is set by the device that confirms the request.
	var/confirm_delay = 20 //(2 seconds)
	var/busy = 0 //Busy when waiting for authentication or an event request has been sent from this device.
	var/obj/machinery/keycard_auth/event_source
	var/mob/event_triggered_by
	var/mob/event_confirmed_by
	//1 = select event
	//2 = authenticate
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	user << "The station AI is not to interact with these devices."
	return

/obj/machinery/keycard_auth/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(stat & (NOPOWER|BROKEN))
		user << "This device is not powered."
		return
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = W
		if(access_keycard_auth in ID.access)
			if(active == 1)
				//This is not the device that made the initial request. It is the device confirming the request.
				if(event_source)
					event_source.confirmed = 1
					event_source.event_confirmed_by = usr
			else if(screen == 2)
				if(event == "Emergency Response Team" && !ert_chosen.len)
					user << "<span class='notice'>Pick the Emergency Response Team type first!</span>"
					return
				event_triggered_by = usr
				broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices

/obj/machinery/keycard_auth/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		icon_state = "auth_off"
	else
		stat |= NOPOWER

/obj/machinery/keycard_auth/attack_hand(mob/user as mob)
	if(!user.IsAdvancedToolUser())
		return 0
	ui_interact(user)

/obj/machinery/keycard_auth/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(user.stat || stat & (NOPOWER|BROKEN))
		user << "This device is not powered."
		return
	if(busy)
		user << "This device is busy."
		return

	user.set_machine(src)

	var/data[0]
	data["screen"] = screen
	data["event"] = event
	data["erttypes"] = list()
	for(var/type in response_team_types)
		var/active = 0
		if((type in ert_chosen))
			active = 1
		data["erttypes"] += list(list("name" = type, "active" = active))

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "keycard_auth.tmpl", "Keycard Authentication Device UI", 520, 320)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/keycard_auth/Topic(href, href_list)
	if(..())
		return
	if(busy)
		usr << "This device is busy."
		return
	if(usr.stat || stat & (BROKEN|NOPOWER))
		usr << "This device is without power."
		return
	if(href_list["triggerevent"])
		ert_chosen.Cut()
		event = href_list["triggerevent"]
		screen = 2
	if(href_list["reset"])
		reset()
	if(href_list["ert"])
		var/chosen = href_list["ert"]
		if((chosen in response_team_types) && !(chosen in ert_chosen))
			ert_chosen |= chosen
		else
			ert_chosen -= chosen

	nanomanager.update_uis(src)
	add_fingerprint(usr)
	return

/obj/machinery/keycard_auth/proc/reset()
	active = 0
	event = ""
	screen = 1
	confirmed = 0
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in world)
		if(KA == src) continue
		KA.reset()
		spawn()
			KA.receive_request(src)

	sleep(confirm_delay)
	if(confirmed)
		confirmed = 0
		trigger_event(event)
		log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event]")
		message_admins("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event]", 1)
	reset()

/obj/machinery/keycard_auth/proc/receive_request(var/obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER))
		return
	event_source = source
	busy = 1
	active = 1
	icon_state = "auth_on"

	sleep(confirm_delay)

	event_source = null
	icon_state = "auth_off"
	active = 0
	busy = 0

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red Alert")
			set_security_level(SEC_LEVEL_RED)
			feedback_inc("alert_keycard_auth_red",1)
		if("Grant Emergency Maintenance Access")
			make_maint_all_access()
			feedback_inc("alert_keycard_auth_maintGrant",1)
		if("Revoke Emergency Maintenance Access")
			revoke_maint_all_access()
			feedback_inc("alert_keycard_auth_maintRevoke",1)
		if("Emergency Response Team")
			if(is_ert_blocked())
				usr << "\red All Emergency Response Teams are dispatched and can not be called at this time."
				return

			response_team_chosen_types += ert_chosen
			trigger_armed_response_team(1)
			feedback_inc("alert_keycard_auth_ert",1)

/obj/machinery/keycard_auth/proc/is_ert_blocked()
	return ticker.mode && ticker.mode.ert_disabled

var/global/maint_all_access = 0

/proc/make_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 1
			D.update_icon(0)
	world << "<font size=4 color='red'>Attention!</font>"
	world << "<font color='red'>The maintenance access requirement has been revoked on all airlocks.</font>"
	maint_all_access = 1

/proc/revoke_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 0
			D.update_icon(0)
	world << "<font size=4 color='red'>Attention!</font>"
	world << "<font color='red'>The maintenance access requirement has been readded on all maintenance airlocks.</font>"
	maint_all_access = 0