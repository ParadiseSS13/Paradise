/datum/ui_module/ert_manager
	name = "ERT Manager"
	var/ert_type = "Red"
	var/commander_slots = 1 // defaults for open slots
	var/security_slots = 4
	var/medical_slots = 0
	var/engineering_slots = 0
	var/janitor_slots = 0
	var/paranormal_slots = 0
	var/cyborg_slots = 0

/datum/ui_module/ert_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ERTManager", name, 350, 430, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/ert_manager/ui_data(mob/user)
	var/list/data = list()
	data["str_security_level"] = capitalize(get_security_level())
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green"
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue"
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red"
		else
			data["security_level_color"] = "purple"
	data["ert_type"] = ert_type
	data["com"] = commander_slots
	data["sec"] = security_slots
	data["med"] = medical_slots
	data["eng"] = engineering_slots
	data["jan"] = janitor_slots
	data["par"] = paranormal_slots
	data["cyb"] = cyborg_slots
	data["total"] = commander_slots + security_slots + medical_slots + engineering_slots + janitor_slots + paranormal_slots + cyborg_slots
	data["spawnpoints"] = GLOB.emergencyresponseteamspawn.len
	return data

/datum/ui_module/ert_manager/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("ert_type")
			ert_type = params["ert_type"]
		if("toggle_com")
			commander_slots = commander_slots ? 0 : 1
		if("set_sec")
			security_slots = text2num(params["set_sec"])
		if("set_med")
			medical_slots = text2num(params["set_med"])
		if("set_eng")
			engineering_slots = text2num(params["set_eng"])
		if("set_jan")
			janitor_slots = text2num(params["set_jan"])
		if("set_par")
			paranormal_slots = text2num(params["set_par"])
		if("set_cyb")
			cyborg_slots = text2num(params["set_cyb"])
		if("dispatch_ert")
			var/datum/response_team/D
			switch(ert_type)
				if("Amber")
					D = new /datum/response_team/amber
				if("Red")
					D = new /datum/response_team/red
				if("Gamma")
					D = new /datum/response_team/gamma
				else
					to_chat(usr, "<span class='userdanger'>Invalid ERT type.</span>")
					return
			GLOB.ert_request_answered = TRUE
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
			var/slot_text = english_list(slots_list)
			notify_ghosts("An ERT is being dispatched. Open positions: [slot_text]")
			message_admins("[key_name_admin(usr)] dispatched a [ert_type] ERT. Slots: [slot_text]", 1)
			log_admin("[key_name(usr)] dispatched a [ert_type] ERT. Slots: [slot_text]")
			GLOB.event_announcement.Announce("Attention, [station_name()]. We are attempting to assemble an ERT. Standby.", "ERT Protocol Activated")
			trigger_armed_response_team(D, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)
		else
			return FALSE

