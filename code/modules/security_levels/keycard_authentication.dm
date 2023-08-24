/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"

	var/active = FALSE // This gets set to TRUE on all devices except the one where the initial request was made.
	var/event
	var/swiping = FALSE // on swiping screen?
	var/confirm_delay = 20 SECONDS // time allowed for a second person to confirm a swipe.
	/// True when a request is sent from another device. So someone on the other end can't just close the ERT menu while someone is typing
	var/busy = FALSE
	var/obj/machinery/keycard_auth/event_source
	var/mob/triggered_by
	var/mob/confirmed_by
	var/ert_reason

	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 6
	power_channel = PW_CHANNEL_ENVIRONMENT

	req_access = list(ACCESS_KEYCARD_AUTH)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/keycard_auth/update_icon_state()
	. = ..()

	if(triggered_by || event_source)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/keycard_auth/update_overlays()
	. = ..()
	underlays.Cut()

	if(triggered_by || event_source)
		underlays += emissive_appearance(icon, "auth_lightmask")


/obj/machinery/keycard_auth/attack_ai(mob/user)
	to_chat(user, "<span class='warning'>The station AI is not to interact with these devices.</span>")
	return

/obj/machinery/keycard_auth/attackby(obj/item/W, mob/user, params)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))
		if(!check_access(W))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
		if(user == event_source?.triggered_by)
			to_chat(user, "<span class='warning'>Identical body-signature detected. Access denied.</span>")
			return
		if(active)
			//This is not the device that made the initial request. It is the device confirming the request.
			if(!event_source)
				return
			event_source.confirmed_by = user
			SStgui.update_uis(event_source)
			SStgui.update_uis(src)
			event_source.confirm_and_trigger()
			reset()
			return
		if(swiping)
			if(event == "Emergency Response Team" && !ert_reason)
				to_chat(user, "<span class='warning'>Supply a reason for calling the ERT first!</span>")
				return
			triggered_by = user
			SStgui.update_uis(src)
			broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices
	return ..()

/obj/machinery/keycard_auth/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/keycard_auth/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/keycard_auth/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/keycard_auth/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "KeycardAuth", name, 540, 300, master_ui, state)
		ui.open()


/obj/machinery/keycard_auth/ui_data()
	var/list/data = list()
	data["redAvailable"] = GLOB.security_level == SEC_LEVEL_RED ? FALSE : TRUE
	data["swiping"] = swiping
	data["busy"] = busy
	data["event"] = active && event_source && event_source.event ? event_source.event : event
	data["ertreason"] = active && event_source && event_source.ert_reason ? event_source.ert_reason : ert_reason
	data["isRemote"] = active ? TRUE : FALSE
	data["hasSwiped"] = triggered_by ? TRUE : FALSE
	data["hasConfirm"] = confirmed_by || (active && event_source && event_source.confirmed_by) ? TRUE : FALSE
	return data

/obj/machinery/keycard_auth/ui_act(action, params)
	if(..())
		return
	if(busy)
		to_chat(usr, "<span class='warning'>This device is busy.</span>")
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	. = TRUE
	switch(action)
		if("ert")
			ert_reason = stripped_input(usr, "Reason for ERT Call:", "", "")
		if("reset")
			reset()
		if("triggerevent")
			event = params["triggerevent"]
			swiping = TRUE

	add_fingerprint(usr)

/obj/machinery/keycard_auth/proc/reset()
	active = FALSE
	event = null
	swiping = FALSE
	busy = FALSE
	event_source = null
	triggered_by = null
	confirmed_by = null
	set_light(0)
	update_icon()

/obj/machinery/keycard_auth/proc/broadcast_request()
	update_icon()
	set_light(1, LIGHTING_MINIMUM_POWER)
	for(var/obj/machinery/keycard_auth/KA in GLOB.machines)
		if(KA == src)
			continue
		KA.receive_request(src)

	addtimer(CALLBACK(src, PROC_REF(reset)), confirm_delay)

/obj/machinery/keycard_auth/proc/confirm_and_trigger()
	trigger_event(event)
	log_game("[key_name(triggered_by)] triggered and [key_name(confirmed_by)] confirmed event [event]")
	message_admins("[key_name_admin(triggered_by)] triggered and [key_name_admin(confirmed_by)] confirmed event [event]", 1)

	reset()

/obj/machinery/keycard_auth/proc/receive_request(obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER))
		return
	reset()

	set_light(1, LIGHTING_MINIMUM_POWER)
	event_source = source
	busy = TRUE
	active = TRUE
	SStgui.update_uis(src)
	update_icon()

	addtimer(CALLBACK(src, PROC_REF(reset)), confirm_delay)

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red Alert")
			set_security_level(SEC_LEVEL_RED)
		if("Grant Emergency Maintenance Access")
			make_maint_all_access()
		if("Revoke Emergency Maintenance Access")
			revoke_maint_all_access()
		if("Activate Station-Wide Emergency Access")
			make_station_all_access()
		if("Deactivate Station-Wide Emergency Access")
			revoke_station_all_access()
		if("Emergency Response Team")
			if(is_ert_blocked())
				atom_say("All Emergency Response Teams are dispatched and can not be called at this time.")
				return
			atom_say("ERT request transmitted!")
			GLOB.command_announcer.autosay("ERT request transmitted. Reason: [ert_reason]", name, follow_target_override = src)
			print_centcom_report(ert_reason, station_time_timestamp() + " ERT Request")

			var/fullmin_count = 0
			for(var/client/C in GLOB.admins)
				if(check_rights(R_EVENT, 0, C.mob))
					fullmin_count++
			if(!fullmin_count)
				trigger_armed_response_team(new /datum/response_team/amber) // No admins? No problem. Automatically send a code amber ERT.
				return

			ERT_Announce(ert_reason, triggered_by, repeat_warning = FALSE)
			SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("ert", "called"))
			addtimer(CALLBACK(src, PROC_REF(remind_admins), ert_reason, triggered_by), 5 MINUTES)
			ert_reason = null

/obj/machinery/keycard_auth/proc/remind_admins(old_reason, the_triggerer) // im great at naming variables
	if(GLOB.ert_request_answered)
		GLOB.ert_request_answered = FALSE // For ERT requests that may come later
		return
	ERT_Announce(old_reason, the_triggerer, repeat_warning = TRUE)

/obj/machinery/keycard_auth/proc/is_ert_blocked()
	return SSticker.mode && SSticker.mode.ert_disabled

GLOBAL_VAR_INIT(maint_all_access, 0)
GLOBAL_VAR_INIT(station_all_access, 0)

// Why are these global procs?
/proc/make_maint_all_access()
	for(var/area/maintenance/A in world) // Why are these global lists? AAAAAAAAAAAAAA
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 1
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on maintenance and external airlocks have been removed.")
	GLOB.maint_all_access = 1
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "enabled"))

/proc/revoke_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 0
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on maintenance and external airlocks have been re-added.")
	GLOB.maint_all_access = 0
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "disabled"))

/proc/make_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = 1
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on all station airlocks have been removed due to an ongoing crisis. Trespassing laws still apply unless ordered otherwise by Command staff.")
	GLOB.station_all_access = 1
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "enabled"))

/proc/revoke_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = 0
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on all station airlocks have been re-added. Seek station AI or a colleague's assistance if you are stuck.")
	GLOB.station_all_access = 0
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "disabled"))
