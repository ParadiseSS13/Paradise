/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "auth_off"

	var/active = FALSE // This gets set to TRUE on all devices except the one where the initial request was made.
	var/event
	var/swiping = FALSE // on swiping screen?
	var/list/ert_chosen = list()
	var/confirmed = FALSE // This variable is set by the device that confirms the request.
	var/confirm_delay = 5 SECONDS // time allowed for a second person to confirm a swipe.
	var/busy = FALSE // Busy when waiting for authentication or an event request has been sent from this device.
	var/obj/machinery/keycard_auth/event_source
	var/mob/event_triggered_by
	var/mob/event_confirmed_by
	var/ert_reason

	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

	req_access = list(ACCESS_KEYCARD_AUTH)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	to_chat(user, "<span class='warning'>The station AI is not to interact with these devices.</span>")
	return

/obj/machinery/keycard_auth/attackby(obj/item/W as obj, mob/user as mob, params)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(W.GetID())
		if(check_access(W))
			if(active)
				//This is not the device that made the initial request. It is the device confirming the request.
				if(event_source)
					event_source.confirmed = TRUE
					event_source.event_confirmed_by = usr
					SStgui.update_uis(event_source)
					SStgui.update_uis(src)
			else if(swiping)
				if(event == "Emergency Response Team" && !ert_reason)
					to_chat(user, "<span class='warning'>Supply a reason for calling the ERT first!</span>")
					return
				event_triggered_by = usr
				SStgui.update_uis(src)
				broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
			playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	return ..()

/obj/machinery/keycard_auth/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		icon_state = "auth_off"
	else
		stat |= NOPOWER

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
	data["hasSwiped"] = event_triggered_by ? TRUE : FALSE
	data["hasConfirm"] = event_confirmed_by || (active && event_source && event_source.event_confirmed_by) ? TRUE : FALSE
	return data

/obj/machinery/keycard_auth/ui_act(action, params)
	if(..())
		return
	if(busy)
		to_chat(usr, "<span class='warning'>This device is busy.</span>")
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	. = TRUE
	switch(action)
		if("ert")
			ert_reason = stripped_input(usr, "Reason for ERT Call:", "", "")
		if("reset")
			reset()
		if("triggerevent")
			event = params["triggerevent"]
			if(GLOB.security_level > SEC_LEVEL_RED && event == "Red Alert") //if gamma, epsilon or delta
				to_chat(usr, "<span class='warning'>CentCom security measures prevent you from changing the alert level.</span>")
				return
			swiping = TRUE

	add_fingerprint(usr)

/obj/machinery/keycard_auth/proc/reset()
	active = FALSE
	event = null
	swiping = FALSE
	confirmed = FALSE
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in GLOB.machines)
		if(KA == src) continue
		KA.reset()
		spawn()
			KA.receive_request(src)

	sleep(confirm_delay)
	if(confirmed)
		confirmed = FALSE
		trigger_event(event)
		add_game_logs("[key_name_log(event_triggered_by)] triggered and [key_name_log(event_confirmed_by)] confirmed event [event]", event_triggered_by)
		message_admins("[key_name_admin(event_triggered_by)] triggered and [key_name_admin(event_confirmed_by)] confirmed event [event]", 1)
	reset()

/obj/machinery/keycard_auth/proc/receive_request(var/obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER))
		return
	event_source = source
	busy = TRUE
	active = TRUE
	SStgui.update_uis(src)
	icon_state = "auth_on"

	sleep(confirm_delay)

	event_source = null
	icon_state = "auth_off"
	active = FALSE
	busy = FALSE

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
				atom_say("Все Отряды Быстрого Реагирования распределены и не могут быть вызваны в данный момент.")
				return
			atom_say("Запрос ОБР отправлен!")
			GLOB.command_announcer.autosay("ERT request transmitted. Reason: [ert_reason]", name)
			print_centcom_report(ert_reason, station_time_timestamp() + " ERT Request")

			var/fullmin_count = 0
			for(var/client/C in GLOB.admins)
				if(check_rights(R_EVENT, 0, C.mob))
					fullmin_count++
			if(fullmin_count)
				GLOB.ert_request_answered = TRUE
				ERT_Announce(ert_reason , event_triggered_by, 0)
				ert_reason = null
				SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("ert", "called"))
				spawn(3000)
					if(!GLOB.ert_request_answered)
						ERT_Announce(ert_reason , event_triggered_by, 1)
			else
				var/list/excludemodes = list(/datum/game_mode/nuclear, /datum/game_mode/blob)
				if(SSticker.mode.type in excludemodes)
					return
				var/list/excludeevents = list(/datum/event/blob, /datum/event/disease_outbreak)
				for(var/datum/event/E in SSevents.active_events|SSevents.finished_events)
					if(E.type in excludeevents)
						return
				trigger_armed_response_team(new /datum/response_team/amber) // No admins? No problem. Automatically send a code amber ERT.

/obj/machinery/keycard_auth/proc/is_ert_blocked()
	return SSticker.mode && SSticker.mode.ert_disabled

GLOBAL_VAR_INIT(maint_all_access, 0)
GLOBAL_VAR_INIT(station_all_access, 0)

// Why are these global procs?
/proc/make_maint_all_access()
	for(var/area/maintenance/A in world) // Why are these global lists? AAAAAAAAAAAAAA
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 1
			D.update_icon(0)
	GLOB.minor_announcement.Announce("Ограничения на доступ к техническим и внешним шл+юзам были сняты.")
	GLOB.maint_all_access = 1
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "enabled"))

/proc/revoke_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 0
			D.update_icon(0)
	GLOB.minor_announcement.Announce("Ограничения на доступ к техническим и внешним шл+юзам были возобновлены.")
	GLOB.maint_all_access = 0
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "disabled"))

/proc/make_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = 1
			D.update_icon(0)
	GLOB.minor_announcement.Announce("Ограничения на доступ ко всем шл+юзам станции были сняты в связи с происходящим кризисом. Статьи о незаконном проникновении по-прежнему действуют, если командование не заявит об обратном.")
	GLOB.station_all_access = 1
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "enabled"))

/proc/revoke_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = 0
			D.update_icon(0)
	GLOB.minor_announcement.Announce("Ограничения на доступ ко всем шл+юзам станции были вновь возобновлены. Если вы застряли, обратитесь за помощью к ИИ станции, или к коллегам.")
	GLOB.station_all_access = 0
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "disabled"))
