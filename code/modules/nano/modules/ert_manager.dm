/datum/nano_module/ert_manager
	name = "ERT Manager"
	var/ert_type = "Code Red"
	var/commander_slots = 1
	var/security_slots = 3
	var/medical_slots = 3
	var/engineering_slots = 3
	var/janitor_slots = 0
	var/paranormal_slots = 0
	var/cyborg_slots = 0
	var/autoclose = 0


/datum/nano_module/ert_manager/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = admin_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(ui && autoclose)
		ui.close()
		return 0
	if(!ui)
		ui = new(user, src, ui_key, "ert_config.tmpl", "ERT Panel", 600, 600, state = state)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/ert_manager/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["set_code"])
		ert_type = href_list["set_code"]

	if(href_list["set_com"])
		commander_slots = text2num(href_list["set_com"])

	if(href_list["set_sec"])
		security_slots = text2num(href_list["set_sec"])

	if(href_list["set_med"])
		medical_slots = text2num(href_list["set_med"])

	if(href_list["set_eng"])
		engineering_slots = text2num(href_list["set_eng"])

	if(href_list["set_jan"])
		janitor_slots = text2num(href_list["set_jan"])

	if(href_list["set_par"])
		paranormal_slots = text2num(href_list["set_par"])

	if(href_list["set_cyb"])
		cyborg_slots = text2num(href_list["set_cyb"])

	if(href_list["dispatch_ert"])
		ert_request_answered = TRUE
		var/slots_list = list()
		if(commander_slots > 0)
			slots_list += "commander: [commander_slots]"
		if(security_slots > 0)
			slots_list += "security: [security_slots]"
		if(medical_slots > 0)
			slots_list += "medical: [medical_slots]"
		if(engineering_slots > 0)
			slots_list += "engineering: [engineering_slots]"
		if(janitor_slots > 0)
			slots_list += "janitor: [janitor_slots]"
		if(paranormal_slots > 0)
			slots_list += "paranormal: [paranormal_slots]"
		if(cyborg_slots > 0)
			slots_list += "cyborg: [cyborg_slots]"
		var/slot_text = jointext(slots_list, ", ")
		notify_ghosts("An ERT is being dispatched. Open positions: [slot_text]")
		message_admins("[key_name_admin(usr)] dispatched a [ert_type] ERT. Slots: [slot_text]", 1)
		log_admin("[key_name(usr)] dispatched a [ert_type] ERT. Slots: [slot_text]")
		autoclose = 1
		ui_interact(usr)
		trigger_armed_response_team(convert_ert_string(ert_type), commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)
		return 0

	ui_interact(usr)


/proc/convert_ert_string(thestring)
	switch(thestring)
		if("Code Amber")
			return new /datum/response_team/amber
		if("Code Red")
			return new /datum/response_team/red
		if("Code Gamma")
			return new /datum/response_team/gamma


/datum/nano_module/ert_manager/ui_data()
	var/data[0]
	data["alert_level"] = get_security_level()
	data["ert_type"] = ert_type
	data["com"] = commander_slots
	data["sec"] = security_slots
	data["med"] = medical_slots
	data["eng"] = engineering_slots
	data["jan"] = janitor_slots
	data["par"] = paranormal_slots
	data["cyb"] = cyborg_slots

	return data

