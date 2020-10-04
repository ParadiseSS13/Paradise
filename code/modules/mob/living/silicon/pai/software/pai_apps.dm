// Main Menu //
/datum/pai_software/main_menu
	name = "Main Menu"
	id = "mainmenu"
	default = TRUE
	template_file = "pai_main_menu"
	ui_icon = "home"

/datum/pai_software/main_menu/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	data["available_ram"] = user.ram

	// Emotions
	var/list/emotions = list()
	for(var/name in GLOB.pai_emotions)
		var/list/emote = list()
		emote["name"] = name
		emote["id"] = GLOB.pai_emotions[name]
		emotions[++emotions.len] = emote

	data["emotions"] = emotions
	data["current_emotion"] = user.card.current_emotion

	var/list/available_s = list()
	for(var/s in GLOB.pai_software_by_key)
		var/datum/pai_software/PS = GLOB.pai_software_by_key[s]
		available_s |= list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "cost" = PS.ram_cost))

	// Split to installed software and toggles for the UI
	var/list/installed_s = list()
	var/list/installed_t = list()
	for(var/s in pai_holder.installed_software)
		var/datum/pai_software/PS = pai_holder.installed_software[s]
		if(PS.toggle_software)
			installed_t |= list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "active" = PS.is_active(user)))
		else
			installed_s |= list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon))

	data["available_software"] = available_s
	data["installed_software"] = installed_s
	data["installed_toggles"] = installed_t

	return data

/datum/pai_software/main_menu/tgui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("purchaseSoftware")
			var/datum/pai_software/S = GLOB.pai_software_by_key[params["key"]]
			if(S && (pai_holder.ram >= S.ram_cost))
				var/datum/pai_software/newPS = new S.type(pai_holder)
				pai_holder.ram -= newPS.ram_cost
				pai_holder.installed_software[newPS.id] = newPS
		if("setEmotion")
			var/emotion = clamp(text2num(params["emotion"]), 1, 9)
			pai_holder.card.setEmotion(emotion)
		if("startSoftware")
			var/software_key = params["software_key"]
			if(pai_holder.installed_software[software_key])
				pai_holder.active_software = pai_holder.installed_software[software_key]
		if("setToggle")
			var/toggle_key = params["toggle_key"]
			if(pai_holder.installed_software[toggle_key])
				pai_holder.installed_software[toggle_key].toggle(usr)

// Directives //
/datum/pai_software/directives
	name = "Directives"
	id = "directives"
	default = TRUE
	template_file = "pai_directives"
	ui_icon = "clipboard-list"

/datum/pai_software/directives/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["master"] = user.master
	data["dna"] = user.master_dna
	data["prime"] = user.pai_law0
	data["supplemental"] = user.pai_laws

	return data

/datum/pai_software/directives/tgui_act(action, list/params)
	if(..())
		return

	var/mob/living/silicon/pai/P = usr
	if(!istype(P))
		return

	. = TRUE

	switch(action)
		if("getdna")
			var/mob/living/M = P.loc
			var/count = 0

			// Find the carrier
			while(!istype(M, /mob/living))
				if(!M || !M.loc || count > 6)
					//For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
					to_chat(usr, "<span class='warning'>You are not being carried by anyone!</span>")
					return
				M = M.loc
				count++

			// Check the carrier
			var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
			if(answer == "Yes")
				M.visible_message("<span class='notice'>[M] presses [M.p_their()] thumb against [P].</span>", "<span class='notice'>You press your thumb against [P].</span>")
				var/datum/dna/dna = M.dna
				to_chat(usr, "<span class='notice'>[M]'s UE string: [dna.unique_enzymes]</span>")
				if(dna.unique_enzymes == P.master_dna)
					to_chat(usr, "<span class='notice'>DNA is a match to stored Master DNA.</span>")
				else
					to_chat(usr, "<span class='warning'>DNA does not match stored Master DNA.</span>")
			else
				to_chat(usr, "<span class='warning'>[M] does not seem like [M.p_they()] [M.p_are()] going to provide a DNA sample willingly.</span>")

// Crew Manifest //
/datum/pai_software/crew_manifest
	name = "Crew Manifest"
	ram_cost = 5
	id = "manifest"
	template_file = "pai_manifest"
	ui_icon = "users"

/datum/pai_software/crew_manifest/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest

	return data

// Med Records //
/datum/pai_software/med_records
	name = "Medical Records"
	ram_cost = 15
	id = "med_records"
	template_file = "pai_medrecords"
	ui_icon = "heartbeat"
	/// Integrated medical records module to reduce duplicated code
	var/datum/data/pda/app/crew_records/medical/integrated_records = new

/datum/pai_software/med_records/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	// Just grab the stuff internally
	integrated_records.update_ui(user, data)
	return data

/datum/pai_software/med_records/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	// Double proxy here
	integrated_records.tgui_act(action, params, ui, state)

// Sec Records //
/datum/pai_software/sec_records
	name = "Security Records"
	ram_cost = 15
	id = "sec_records"
	template_file = "pai_secrecords"
	ui_icon = "id-badge"
	/// Integrated security records module to reduce duplicated code
	var/datum/data/pda/app/crew_records/security/integrated_records = new

/datum/pai_software/sec_records/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	// Just grab the stuff internally
	integrated_records.update_ui(user, data)
	return data

/datum/pai_software/sec_records/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	// Double proxy here
	integrated_records.tgui_act(action, params, ui, state)

// Atmos Scan //
/datum/pai_software/atmosphere_sensor
	name = "Atmosphere Sensor"
	ram_cost = 5
	id = "atmos_sense"
	template_file = "pai_atmosphere"
	ui_icon = "fire"
	/// Integrated PDA atmos scan module to reduce duplicated code
	var/datum/data/pda/app/atmos_scanner/scanner = new

/datum/pai_software/atmosphere_sensor/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	// Just grab the stuff internally
	scanner.update_ui(user, data)
	return data

// Messenger //
/datum/pai_software/messenger
	name = "Digital Messenger"
	ram_cost = 5
	id = "messenger"
	template_file = "pai_messenger"
	ui_icon = "envelope"

/datum/pai_software/messenger/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	// Some safety checks
	if(!user.pda)
		CRASH("pAI found without PDA.")

	var/datum/data/pda/app/messenger/PM = user.pda.find_program(/datum/data/pda/app/messenger)
	if(!PM)
		CRASH("pAI PDA lacks a messenger program")

	// Grab the internal data
	PM.update_ui(user, data)

	return data

/datum/pai_software/messenger/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	// Sanity checks
	var/mob/living/silicon/pai/P = usr
	if(!istype(P))
		return

	// Grab their messenger
	var/datum/data/pda/app/messenger/PM = P.pda.find_program(/datum/data/pda/app/messenger)
	// Double proxy here
	PM.tgui_act(action, params, ui, state)

// Radio
/datum/pai_software/radio_config
	name = "Radio Configuration"
	id = "radio"
	default = TRUE
	template_file = "pai_radio"
	ui_icon = "broadcast-tower"

/datum/pai_software/radio_config/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	data["frequency"] = user.radio.frequency
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ
	data["broadcasting"] = user.radio.broadcasting
	return data

/datum/pai_software/radio_config/tgui_act(action, list/params)
	if(..())
		return

	var/mob/living/silicon/pai/P = usr
	if(!istype(P))
		return

	switch(action)
		if("toggleBroadcast")
			// Just toggle it
			P.radio.broadcasting =! P.radio.broadcasting

		if("freq")
			var/new_frequency = sanitize_frequency(text2num(params["freq"]) * 10)
			P.radio.set_frequency(new_frequency)

// Signaler //
/datum/pai_software/signaler
	name = "Remote Signaler"
	ram_cost = 5
	id = "signaler"
	template_file = "pai_signaler"
	ui_icon = "rss"

/datum/pai_software/signaler/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["frequency"] = user.sradio.frequency
	data["code"] = user.sradio.code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ

	return data

/datum/pai_software/signaler/tgui_act(action, list/params)
	if(..())
		return

	var/mob/living/silicon/pai/P = usr
	if(!istype(P))
		return

	switch(action)
		if("signal")
			P.sradio.send_signal("ACTIVATE")

		if("freq")
			var/new_frequency = sanitize_frequency(text2num(params["freq"]) * 10)
			P.sradio.set_frequency(new_frequency)

		if("code")
			P.sradio.code = clamp(text2num(params["code"]), 1, 100)
