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

	var/list/speech_types = list()
	for(var/name in user.possible_say_verbs)
		var/list/speech = list()
		speech["name"] = name
		speech["id"] = length(speech_types)
		speech_types[++speech_types.len] = speech

	data["current_speech_verb"] = user.speech_state
	data["speech_verbs"] = speech_types

	var/list/chassis_choices = list()
	var/list/chassises_to_add = list()

	chassis_choices = user.possible_chassis.Copy()
	if(user.custom_sprite)
		chassis_choices["Custom"] = "[user.ckey]-pai"
	for(var/name in chassis_choices)
		var/list/chassis_to_update_with = list()
		chassis_to_update_with["name"] = name
		chassis_to_update_with["icon"] = chassis_choices[name]
		chassis_to_update_with["id"] = length(chassis_to_update_with)
		chassises_to_add[++chassises_to_add.len] = chassis_to_update_with

	data["available_chassises"] = chassises_to_add
	data["current_chassis"] = user.chassis

	var/list/available_s = list()
	for(var/s in GLOB.pai_software_by_key)
		var/datum/pai_software/PS = GLOB.pai_software_by_key[s]
		available_s += list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "cost" = PS.ram_cost))

	// Split to installed software and toggles for the UI
	var/list/installed_s = list()
	var/list/installed_t = list()
	for(var/s in pai_holder.installed_software)
		var/datum/pai_software/PS = pai_holder.installed_software[s]
		if(PS.toggle_software)
			installed_t += list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "active" = PS.is_active(user)))
		else
			installed_s += list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon))

	data["available_software"] = available_s
	data["installed_software"] = installed_s
	data["installed_toggles"] = installed_t

	return data

/datum/pai_software/main_menu/ui_act(action, list/params)
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
				pai_holder.installed_software[toggle_key].toggle(pai_holder)
		if("setSpeechStyle")
			pai_holder.speech_state = params["speech_state"]
			var/list/sayverbs = pai_holder.possible_say_verbs[pai_holder.speech_state]
			pai_holder.speak_statement = sayverbs[1]
			pai_holder.speak_exclamation = sayverbs[length(sayverbs) > 1 ? 2 : length(sayverbs)]
			pai_holder.speak_query = sayverbs[length(sayverbs) > 2 ? 3 : length(sayverbs)]
		if("setChassis")
			pai_holder.chassis = params["chassis_to_change"]
			pai_holder.icon_state = pai_holder.chassis
			if(pai_holder.icon_state == "[pai_holder.ckey]-pai")
				pai_holder.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
			else
				pai_holder.icon = 'icons/mob/pai.dmi'


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

/datum/pai_software/directives/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("getdna")
			var/mob/living/M = get_holding_mob()
			if(!istype(M))
				return

			// Check the carrier
			var/answer = alert(M, "[pai_holder] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[pai_holder] Check DNA", "Yes", "No")
			if(answer == "Yes")
				M.visible_message("<span class='notice'>[M] presses [M.p_their()] thumb against [pai_holder].</span>", "<span class='notice'>You press your thumb against [pai_holder].</span>")
				var/datum/dna/dna = M.dna
				to_chat(usr, "<span class='notice'>[M]'s UE string: [dna.unique_enzymes]</span>")
				if(dna.unique_enzymes == pai_holder.master_dna)
					to_chat(usr, "<span class='notice'>DNA is a match to stored Master DNA.</span>")
				else
					to_chat(usr, "<span class='warning'>DNA does not match stored Master DNA.</span>")
			else
				to_chat(usr, "<span class='warning'>[M] does not seem like [M.p_they()] [M.p_are()] going to provide a DNA sample willingly.</span>")

// Crew Manifest //
/datum/pai_software/crew_manifest
	name = "Crew Manifest"
	id = "manifest"
	default = TRUE
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

/datum/pai_software/med_records/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	// Double proxy here
	integrated_records.ui_act(action, params, ui, state)

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

/datum/pai_software/sec_records/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	// Double proxy here
	integrated_records.ui_act(action, params, ui, state)

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
	id = "messenger"
	default = TRUE
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

/datum/pai_software/messenger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	// Grab their messenger
	var/datum/data/pda/app/messenger/PM = pai_holder.pda.find_program(/datum/data/pda/app/messenger)
	// Double proxy here
	PM.ui_act(action, params, ui, state)

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

/datum/pai_software/radio_config/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("toggleBroadcast")
			// Just toggle it
			pai_holder.radio.broadcasting = !pai_holder.radio.broadcasting

		if("freq")
			var/new_frequency = sanitize_frequency(text2num(params["freq"]) * 10)
			pai_holder.radio.set_frequency(new_frequency)

// Signaler //
/datum/pai_software/signaler
	name = "Remote Signaler"
	ram_cost = 5
	id = "signaler"
	template_file = "pai_signaler"
	ui_icon = "rss"

/datum/pai_software/signaler/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["frequency"] = user.integ_signaler.frequency
	data["code"] = user.integ_signaler.code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ

	return data

/datum/pai_software/signaler/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("signal")

			pai_holder.integ_signaler.activate()

		if("freq")
			pai_holder.integ_signaler.frequency = sanitize_frequency(text2num(params["freq"]) * 10)

		if("code")
			pai_holder.integ_signaler.code = clamp(text2num(params["code"]), 1, 100)

// Door Jack //
/datum/pai_software/door_jack
	name = "Door Jack"
	ram_cost = 30
	id = "door_jack"
	template_file = "pai_doorjack"
	ui_icon = "door-open"
	/// Progress on hacking the door
	var/progress = 0
	/// Are we hacking?
	var/hacking = FALSE
	/// The cable being plugged into a door
	var/obj/item/pai_cable/cable
	/// The door being hacked
	var/obj/machinery/door/hackdoor

/datum/pai_software/door_jack/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["cable"] = (cable != null)
	data["machine"] = (cable?.machine != null)
	data["inprogress"] = (hackdoor != null)
	data["progress"] = progress

	return data

/datum/pai_software/door_jack/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("jack")
			if(cable && cable.machine)
				hackdoor = cable.machine
				if(hacking)
					to_chat(usr, "<span class='warning'>You are already hacking that door!</span>")
				else
					hacking = TRUE
					INVOKE_ASYNC(src, PROC_REF(hackloop))
		if("cancel")
			hackdoor = null
		if("cable")
			playsound(pai_holder, 'sound/mecha/mechmove03.ogg', 25, TRUE)
			if(cable) // Retracting
				pai_holder.visible_message("<span class='warning'>[cable] is pulled back into [pai_holder] with a quick snap.</span>")
				QDEL_NULL(cable)
			else // Extending
				cable = new /obj/item/pai_cable(get_turf(pai_holder))
				pai_holder.visible_message("<span class='warning'>A port on [pai_holder] opens to reveal [cable], which promptly falls to the floor.</span>")

/**
  * Door jack hack loop
  *
  * Self-contained proc for handling the hacking of a door.
  * Invoked asyncly, but will only allow one instance at a time
  */
/datum/pai_software/door_jack/proc/hackloop()
	var/obj/machinery/door/D = cable.machine
	if(!istype(D))
		cleanup_hack()
		return
	while(progress < 100)
		if(cable && cable.machine == D && cable.machine == hackdoor && get_dist(pai_holder, hackdoor) <= 1)
			progress = min(progress + rand(1, 20), 100)
		else
			cleanup_hack()
			return
		if(progress >= 100)
			D.open()
			cleanup_hack()
			return
		sleep(1 SECONDS) // Update every second

/**
  * Door jack cleanup proc
  *
  * Self-contained proc for cleaning up failed hack attempts
  */
/datum/pai_software/door_jack/proc/cleanup_hack()
	progress = 0
	hackdoor = null
	cable.machine = null
	QDEL_NULL(cable)
	hacking = FALSE

// Host Bioscan //
/datum/pai_software/host_scan
	name = "Host Bioscan"
	ram_cost = 5
	id = "bioscan"
	template_file = "pai_bioscan"
	ui_icon = "heartbeat"

/datum/pai_software/host_scan/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	var/mob/living/held = get_holding_mob(FALSE)

	if(isliving(held))
		data["holder"] = held.name
		data["dead"] = (held.stat > UNCONSCIOUS)
		data["health"] = held.health
		data["brute"] = held.getBruteLoss()
		data["oxy"] = held.getOxyLoss()
		data["tox"] = held.getToxLoss()
		data["burn"] = held.getFireLoss()

	return data
