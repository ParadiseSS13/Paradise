/datum/ui_module/ert_manager
	name = "ERT Manager"
	var/ert_type
	var/commander_slots = 1 // defaults for open slots
	var/security_slots = 4
	var/medical_slots = 0
	var/engineering_slots = 0
	var/janitor_slots = 0
	var/paranormal_slots = 0
	var/cyborg_slots = 0
	/// The below is a toggle for if sec cyborgs are enabled or not
	var/cyborg_security = FALSE

	var/datum/response_team/response_team_type
	var/list/loadouts_per_role = list()

	var/datum/ert_loadout/commander_loadout
	var/datum/ert_loadout/security_loadout
	var/datum/ert_loadout/medical_loadout
	var/datum/ert_loadout/engineering_loadout
	var/datum/ert_loadout/janitor_loadout
	var/datum/ert_loadout/paranormal_loadout

/datum/ui_module/ert_manager/New(datum/_host)
	. = ..()
	set_ert_type("Red")
	get_loadouts_per_role()
	RegisterSignal(SSdcs, COMSIG_ERT_LOADOUT_CREATED, PROC_REF(add_created_loadout))

/datum/ui_module/ert_manager/Destroy()
	. = ..()
	response_team_type = null
	loadouts_per_role.Cut()
	commander_loadout = null
	security_loadout = null
	medical_loadout = null
	engineering_loadout = null
	janitor_loadout = null
	paranormal_loadout = null
	UnregisterSignal(SSdcs, COMSIG_ERT_LOADOUT_CREATED)

/datum/ui_module/ert_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/ert_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ERTManager", name)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/ert_manager/proc/get_custom_loadout_ui_data(mob/user)
	var/list/data = list()
	data["Command"] = commander_loadout?.loadout_name
	data["Security"] = security_loadout?.loadout_name
	data["Medical"] = medical_loadout?.loadout_name
	data["Engineering"] = engineering_loadout?.loadout_name
	data["Janitor"] = janitor_loadout?.loadout_name
	data["Paranormal"] = paranormal_loadout?.loadout_name

	return data

/datum/ui_module/ert_manager/proc/set_ert_type(new_type)
	if(new_type == ert_type)
		return

	if(new_type != "Red")
		cyborg_security = FALSE

	switch(new_type)
		if("Amber")
			response_team_type = /datum/response_team/amber
		if("Red")
			response_team_type = /datum/response_team/red
		if("Gamma")
			response_team_type = /datum/response_team/gamma
		if("Custom")
			response_team_type = /datum/response_team/custom

	ert_type = new_type

	update_ert_loadouts(new_type)

/datum/ui_module/ert_manager/proc/update_ert_loadouts(new_type)
	switch(new_type)
		if("Amber", "Red", "Gamma")
			commander_loadout = GLOB.ert_loadouts[response_team_type::command_outfit]
			security_loadout = GLOB.ert_loadouts[response_team_type::security_outfit]
			medical_loadout = GLOB.ert_loadouts[response_team_type::medical_outfit]
			engineering_loadout = GLOB.ert_loadouts[response_team_type::engineering_outfit]
			janitor_loadout = GLOB.ert_loadouts[response_team_type::janitor_outfit]
			paranormal_loadout = GLOB.ert_loadouts[response_team_type::paranormal_outfit]

/datum/ui_module/ert_manager/proc/get_loadouts_per_role()
	loadouts_per_role.Cut()

	for(var/outfit_type in GLOB.ert_loadouts)
		var/datum/ert_loadout/loadout = GLOB.ert_loadouts[outfit_type]
		LAZYORASSOCLIST(loadouts_per_role, loadout.role, loadout.loadout_name)

	for(var/datum/ert_loadout/custom_loadout in GLOB.ert_custom_loadouts)
		LAZYORASSOCLIST(loadouts_per_role, custom_loadout.role, custom_loadout.loadout_name)

/datum/ui_module/ert_manager/ui_data(mob/user)
	var/list/data = list()
	data["str_security_level"] = capitalize(SSsecurity_level.get_current_level_as_text())
	data["security_level_color"] = SSsecurity_level.current_security_level.color
	data["ert_request_answered"] = GLOB.ert_request_answered
	data["ert_type"] = ert_type
	data["com"] = commander_slots
	data["sec"] = security_slots
	data["med"] = medical_slots
	data["eng"] = engineering_slots
	data["jan"] = janitor_slots
	data["par"] = paranormal_slots
	data["cyb"] = cyborg_slots
	data["secborg"] = cyborg_security
	data["total"] = commander_slots + security_slots + medical_slots + engineering_slots + janitor_slots + paranormal_slots + cyborg_slots
	data["spawnpoints"] = length(GLOB.emergencyresponseteamspawn)

	data["ert_request_messages"] = GLOB.ert_request_messages

	data["custom_loadouts"] = get_custom_loadout_ui_data(user)
	return data

/datum/ui_module/ert_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("toggle_ert_request_answered")
			GLOB.ert_request_answered = !GLOB.ert_request_answered
		if("ert_type")
			set_ert_type(params["ert_type"])
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
			if(!cyborg_slots)
				cyborg_security = FALSE
		if("toggle_secborg")
			cyborg_security = !cyborg_security
		if("dispatch_ert")
			var/datum/response_team/D = new response_team_type
			D.command_outfit = commander_loadout?.to_outfit()
			D.security_outfit = security_loadout?.to_outfit()
			D.medical_outfit = medical_loadout?.to_outfit()
			D.engineering_outfit = engineering_loadout?.to_outfit()
			D.janitor_outfit = janitor_loadout?.to_outfit()
			D.paranormal_outfit = paranormal_loadout?.to_outfit()

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

			var/silenced = (params["silent"])
			D.silent = silenced

			var/slot_text = english_list(slots_list)
			notify_ghosts("An ERT is being dispatched. Type: [ert_type]. Open positions: [slot_text]")
			message_admins("[key_name_admin(usr)] dispatched a [silenced ? "silent " : ""][ert_type] ERT. Slots: [slot_text]", 1)
			log_admin("[key_name(usr)] dispatched a [silenced ? "silent " : ""][ert_type] ERT. Slots: [slot_text]")
			if(!silenced)
				GLOB.major_announcement.Announce("Attention, [station_name()]. We are attempting to assemble an ERT. Standby.", "ERT Protocol Activated")
			trigger_armed_response_team(D, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots, cyborg_security)

		if("view_player_panel")
			SSuser_verbs.invoke_verb(ui.user, /datum/user_verb/show_player_panel, locate(params["uid"]))

		if("deny_ert")
			GLOB.ert_request_answered = TRUE
			var/message = "[station_name()], we are unfortunately unable to send you an Emergency Response Team at this time."
			if(params["reason"])
				message += " Your ERT request has been denied for the following reasons:\n\n[params["reason"]]"
			GLOB.major_announcement.Announce(message, "ERT Unavailable")

		if("choose_custom_loadout")
			INVOKE_ASYNC(src, PROC_REF(choose_custom_loadout), ui, params["role"])

		if("refresh_loadouts")
			get_loadouts_per_role()
		else
			return FALSE

/datum/ui_module/ert_manager/proc/choose_custom_loadout(datum/tgui/ui, role_name)
	var/list/loadouts = loadouts_per_role[role_name]
	var/choice = tgui_input_list(ui.user, "Select the custom loadout for the [role_name] role.", "Select custom loadout", loadouts)
	if(choice)
		set_custom_loadout(role_name, choice)

/datum/ui_module/ert_manager/proc/set_custom_loadout(role_name, choice)
	var/datum/ert_loadout/loadout = ert_loadout_by_name(choice)
	if(istype(loadout))
		switch(role_name)
			if("Command")
				commander_loadout = loadout
			if("Security")
				security_loadout = loadout
			if("Medical")
				medical_loadout = loadout
			if("Engineering")
				engineering_loadout = loadout
			if("Janitor")
				janitor_loadout = loadout
			if("Paranormal")
				paranormal_loadout = loadout

/datum/ui_module/ert_manager/proc/add_created_loadout(datum/source, role_name, loadout_name)
	SIGNAL_HANDLER // COMSIG_ERT_LOADOUT_CREATED
	get_loadouts_per_role()

