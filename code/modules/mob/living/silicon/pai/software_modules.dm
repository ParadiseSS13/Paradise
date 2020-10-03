/datum/pai_software
	/// Name for the software. This is used as the button text when buying or opening/toggling the software
	var/name = "pAI software module"
	/// RAM cost; pAIs start with 100 RAM, spending it on programs
	var/ram_cost = 0
	/// ID for the software. This must be unique
	var/id
	// Toggled software should override toggle() and is_active()
	// Non-toggled software should override on_ui_data() and Topic()
	/// Whether this software is a toggle or not
	var/toggle_software = FALSE
	/// Do we have this software installed by default
	var/default = FALSE
	/// Template for the TGUI file
	var/template_file = "oops"
	/// Icon for inside the UI
	var/ui_icon = "file-code"
	/// pAI which holds this software
	var/mob/living/silicon/pai/pai_holder

/datum/pai_software/New(mob/living/silicon/pai/user)
	pai_holder = user
	..()

/datum/pai_software/proc/get_app_data(mob/living/silicon/pai/user)
	return list()

/datum/pai_software/proc/toggle(mob/living/silicon/pai/user)
	return

/datum/pai_software/proc/is_active(mob/living/silicon/pai/user)
	return FALSE

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
			installed_t |= list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "active" = PS.is_active()))
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

/*
/datum/pai_software/directives/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	if(href_list["getdna"])
		var/mob/living/M = P.loc
		var/count = 0

		// Find the carrier
		while(!istype(M, /mob/living))
			if(!M || !M.loc || count > 6)
				//For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
				to_chat(P, "You are not being carried by anyone!")
				return 0
			M = M.loc
			count++

		// Check the carrier
		var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
		if(answer == "Yes")
			var/turf/T = get_turf_or_move(P.loc)
			for(var/mob/v in viewers(T))
				v.show_message("<span class='notice'>[M] presses [M.p_their()] thumb against [P].</span>", 3, "<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>", 2)
			var/datum/dna/dna = M.dna
			to_chat(P, "<font color = red><h3>[M]'s UE string : [dna.unique_enzymes]</h3></font>")
			if(dna.unique_enzymes == P.master_dna)
				to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
			else
				to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
		else
			to_chat(P, "[M] does not seem like [M.p_they()] [M.p_are()] going to provide a DNA sample willingly.")
		return 1

/datum/pai_software/radio_config
	name = "Radio Configuration"
	ram_cost = 0
	id = "radio"
	toggle = 0
	default = 1

	template_file = "pai_radio.tmpl"
	ui_title = "Radio Configuration"
	ui_width = 300
	ui_height = 150

/datum/pai_software/radio_config/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]

	data["listening"] = user.radio.broadcasting
	data["frequency"] = format_frequency(user.radio.frequency)
	var/channels[0]
	for(var/ch_name in user.radio.channels)
		var/ch_stat = user.radio.channels[ch_name]
		var/ch_dat[0]
		ch_dat["name"] = ch_name
		// FREQ_LISTENING is const in /obj/item/radio
		ch_dat["listening"] = !!(ch_stat & user.radio.FREQ_LISTENING)
		channels[++channels.len] = ch_dat

	data["channels"] = channels

	return data

/datum/pai_software/radio_config/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	P.radio.Topic(href, href_list)
	return 1
*/
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
/*
/datum/pai_software/messenger
	name = "Digital Messenger"
	ram_cost = 5
	id = "messenger"
	toggle = 0

	autoupdate = 1
	template_file = "pai_messenger.tmpl"
	ui_title = "Digital Messenger"

/datum/pai_software/messenger/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]

	if(!user.pda)
		log_runtime(EXCEPTION("pAI found without PDA."), user)
		return data
	var/datum/data/pda/app/messenger/M = user.pda.find_program(/datum/data/pda/app/messenger)
	if(!M)
		log_runtime(EXCEPTION("pAI PDA lacks a messenger program"), user)
		return data

	data["receiver_off"] = M.toff
	data["ringer_off"] = M.notify_silent
	data["current_ref"] = null
	data["current_name"] = user.current_pda_messaging

	var/pdas[0]
	if(!M.toff)
		for(var/obj/item/pda/P in GLOB.PDAs)
			var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

			if(P == user.pda || !PM || !PM.can_receive())
				continue
			var/pda[0]
			pda["name"] = "[P]"
			pda["owner"] = "[P.owner]"
			pda["ref"] = "\ref[P]"
			if(P.owner == user.current_pda_messaging)
				data["current_ref"] = "\ref[P]"
			pdas[++pdas.len] = pda

	data["pdas"] = pdas

	var/messages[0]
	if(user.current_pda_messaging)
		for(var/index in M.tnote)
			if(index["owner"] != user.current_pda_messaging)
				continue
			var/msg[0]
			var/sent = index["sent"]
			msg["sent"] = sent ? 1 : 0
			msg["target"] = index["owner"]
			msg["message"] = index["message"]
			messages[++messages.len] = msg

	data["messages"] = messages

	return data

/datum/pai_software/messenger/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	if(!isnull(P.pda))
		var/datum/data/pda/app/messenger/M = P.pda.find_program(/datum/data/pda/app/messenger)
		if(!M)
			return

		if(href_list["toggler"])
			M.toff = href_list["toggler"] != "1"
			return 1
		else if(href_list["ringer"])
			M.notify_silent = href_list["ringer"] != "1"
			return 1
		else if(href_list["select"])
			var/s = href_list["select"]
			if(s == "*NONE*")
				P.current_pda_messaging = null
			else
				P.current_pda_messaging = s
			return 1
		else if(href_list["target"])
			if(P.silence_time)
				return alert("Communications circuits remain uninitialized.")

			var/target = locate(href_list["target"])
			M.create_message(P, target, 1)
			return 1

/datum/pai_software/med_records
	name = "Medical Records"
	ram_cost = 15
	id = "med_records"
	toggle = 0

	autoupdate = 1
	template_file = "pai_medrecords.tmpl"
	ui_title = "Medical Records"


/datum/pai_software/med_records/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]

	var/records[0]
	for(var/datum/data/record/general in sortRecord(GLOB.data_core.general))
		var/record[0]
		record["name"] = general.fields["name"]
		record["ref"] = "\ref[general]"
		records[++records.len] = record

	data["records"] = records

	var/datum/data/record/G = user.medicalActive1
	var/datum/data/record/M = user.medicalActive2
	data["general"] = G ? G.fields : null
	data["medical"] = M ? M.fields : null
	data["could_not_find"] = user.medical_cannotfind

	return data

/datum/pai_software/med_records/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	if(href_list["select"])
		var/datum/data/record/record = locate(href_list["select"])
		if(record)
			var/datum/data/record/R = record
			var/datum/data/record/M = null
			if(!( GLOB.data_core.general.Find(R) ))
				P.medical_cannotfind = 1
			else
				P.medical_cannotfind = 0
				for(var/datum/data/record/E in GLOB.data_core.medical)
					if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
				P.medicalActive1 = R
				P.medicalActive2 = M
		else
			P.medical_cannotfind = 1
		return 1

/datum/pai_software/sec_records
	name = "Security Records"
	ram_cost = 15
	id = "sec_records"
	toggle = 0

	autoupdate = 1
	template_file = "pai_secrecords.tmpl"
	ui_title = "Security Records"


/datum/pai_software/sec_records/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]

	var/records[0]
	for(var/datum/data/record/general in sortRecord(GLOB.data_core.general))
		var/record[0]
		record["name"] = general.fields["name"]
		record["ref"] = "\ref[general]"
		records[++records.len] = record

	data["records"] = records

	var/datum/data/record/G = user.securityActive1
	var/datum/data/record/S = user.securityActive2
	data["general"] = G ? G.fields : null
	data["security"] = S ? S.fields : null
	data["could_not_find"] = user.security_cannotfind

	return data

/datum/pai_software/sec_records/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	if(href_list["select"])
		var/datum/data/record/record = locate(href_list["select"])
		if(record)
			var/datum/data/record/R = record
			var/datum/data/record/S = null
			if(!( GLOB.data_core.general.Find(R) ))
				P.securityActive1 = null
				P.securityActive2 = null
				P.security_cannotfind = 1
			else
				P.security_cannotfind = 0
				for(var/datum/data/record/E in GLOB.data_core.security)
					if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
				P.securityActive1 = R
				P.securityActive2 = S
		else
			P.securityActive1 = null
			P.securityActive2 = null
			P.security_cannotfind = 1
		return 1

/datum/pai_software/door_jack
	name = "Door Jack"
	ram_cost = 30
	id = "door_jack"
	toggle = 0

	autoupdate = 1
	template_file = "pai_doorjack.tmpl"
	ui_title = "Door Jack"
	ui_width = 300
	ui_height = 150

/datum/pai_software/door_jack/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]

	data["cable"] = user.cable != null
	data["machine"] = user.cable && (user.cable.machine != null)
	data["inprogress"] = user.hackdoor != null
	data["progress_a"] = round(user.hackprogress / 10)
	data["progress_b"] = user.hackprogress % 10
	data["aborted"] = user.hack_aborted

	return data

/datum/pai_software/door_jack/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	if(href_list["jack"])
		if(P.cable && P.cable.machine)
			P.hackdoor = P.cable.machine
			P.hackloop()
		return 1
	else if(href_list["cancel"])
		P.hackdoor = null
		return 1
	else if(href_list["cable"])
		var/turf/T = get_turf_or_move(P.loc)
		P.hack_aborted = 0
		P.cable = new /obj/item/pai_cable(T)
		for(var/mob/M in viewers(T))
			M.show_message("<span class='warning'>A port on [P] opens to reveal [P.cable], which promptly falls to the floor.</span>", 3,
			               "<span class='warning'>You hear the soft click of something light and hard falling to the ground.</span>", 2)
		return 1

/mob/living/silicon/pai/proc/hackloop()
	var/obj/machinery/door/D = cable.machine
	if(!istype(D))
		hack_aborted = 1
		hackprogress = 0
		cable.machine = null
		hackdoor = null
		return
	while(hackprogress < 1000)
		if(cable && cable.machine == D && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
			hackprogress = min(hackprogress+rand(1, 20), 1000)
		else
			hack_aborted = 1
			hackprogress = 0
			hackdoor = null
			return
		if(hackprogress >= 1000)
			hackprogress = 0
			D.open()
			cable.machine = null
			return
		sleep(10)			// Update every second
*/
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

/*
/datum/pai_software/sec_hud
	name = "Security HUD"
	ram_cost = 20
	id = "sec_hud"

/datum/pai_software/sec_hud/toggle(mob/living/silicon/pai/user)
	user.secHUD = !user.secHUD
	user.remove_med_sec_hud()
	if(user.secHUD)
		user.add_sec_hud()

/datum/pai_software/sec_hud/is_active(mob/living/silicon/pai/user)
		return user.secHUD

/datum/pai_software/med_hud
	name = "Medical HUD"
	ram_cost = 20
	id = "med_hud"

/datum/pai_software/med_hud/toggle(mob/living/silicon/pai/user)
	user.medHUD = !user.medHUD
	user.remove_med_sec_hud()
	if(user.medHUD)
		user.add_med_hud()

/datum/pai_software/med_hud/is_active(mob/living/silicon/pai/user)
	return user.medHUD

/datum/pai_software/translator
	name = "Universal Translator"
	ram_cost = 35
	id = "translator"

/datum/pai_software/translator/toggle(mob/living/silicon/pai/user)
	// 	Galactic Common, Sol Common, Tradeband, Gutter and Trinary are added with New() and are therefore the current default, always active languages
	user.translator_on = !user.translator_on
	if(user.translator_on)
		user.add_language("Sinta'unathi")
		user.add_language("Siik'tajr")
		user.add_language("Canilunzt")
		user.add_language("Skrellian")
		user.add_language("Vox-pidgin")
		user.add_language("Rootspeak")
		user.add_language("Chittin")
		user.add_language("Bubblish")
		user.add_language("Orluum")
		user.add_language("Clownish")
		user.add_language("Neo-Russkiya")
	else
		user.remove_language("Sinta'unathi")
		user.remove_language("Siik'tajr")
		user.remove_language("Canilunzt")
		user.remove_language("Skrellian")
		user.remove_language("Vox-pidgin")
		user.remove_language("Rootspeak")
		user.remove_language("Chittin")
		user.remove_language("Bubblish")
		user.remove_language("Orluum")
		user.remove_language("Clownish")
		user.remove_language("Neo-Russkiya")

/datum/pai_software/translator/is_active(mob/living/silicon/pai/user)
	return user.translator_on

/datum/pai_software/signaller
	name = "Remote Signaller"
	ram_cost = 5
	id = "signaller"
	toggle = 0

	template_file = "pai_signaller.tmpl"
	ui_title = "Signaller"
	ui_width = 320
	ui_height = 150

/datum/pai_software/signaller/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]

	data["frequency"] = format_frequency(user.sradio.frequency)
	data["code"] = user.sradio.code

	return data

/datum/pai_software/signaller/Topic(href, href_list)
	var/mob/living/silicon/pai/P = usr
	if(!istype(P)) return

	if(href_list["send"])
		P.sradio.send_signal("ACTIVATE")
		for(var/mob/O in hearers(1, P.loc))
			O.show_message("[bicon(P)] *beep* *beep*", 3, "*beep* *beep*", 2)
		return 1

	else if(href_list["freq"])
		var/new_frequency = (P.sradio.frequency + text2num(href_list["freq"]))
		if(new_frequency < PUBLIC_LOW_FREQ || new_frequency > PUBLIC_HIGH_FREQ)
			new_frequency = sanitize_frequency(new_frequency)
		P.sradio.set_frequency(new_frequency)
		return 1

	else if(href_list["code"])
		P.sradio.code += text2num(href_list["code"])
		P.sradio.code = round(P.sradio.code)
		P.sradio.code = min(100, P.sradio.code)
		P.sradio.code = max(1, P.sradio.code)
		return 1

/datum/pai_software/host_scan
	name = "Host Bioscan"
	ram_cost = 5
	id = "bioscan"
	toggle = 0

	template_file = "pai_bioscan.tmpl"
	ui_title = "Host Bioscan"
	ui_width = 400
	ui_height = 350

/datum/pai_software/host_scan/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = GLOB.self_state)
	var/data[0]
	var/mob/living/held = user.loc
	var/count = 0

		// Find the carrier
	while(!isliving(held))
		if(!held || !held.loc || count > 6)
			//For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
			to_chat(user, "You are not being carried by anyone!")
			return 0
		held = held.loc
		count++
	if(isliving(held))
		data["holder"] = held
		data["health"] = "[held.stat > 1 ? "dead" : "[held.health]% healthy"]"
		data["brute"] = "[held.getBruteLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][held.getBruteLoss()]</font>"
		data["oxy"] = "[held.getOxyLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][held.getOxyLoss()]</font>"
		data["tox"] = "[held.getToxLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][held.getToxLoss()]</font>"
		data["burn"] = "[held.getFireLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][held.getFireLoss()]</font>"
		data["temp"] = "[held.bodytemperature-T0C]&deg;C ([held.bodytemperature*1.8-459.67]&deg;F)"
	else
		data["holder"] = 0

	return data

/datum/pai_software/flashlight
	name = "Flashlight"
	ram_cost = 5
	id = "flashlight"

/datum/pai_software/flashlight/toggle(mob/living/silicon/pai/user)
	var/atom/movable/actual_location = istype(user.loc, /obj/item/paicard) ? user.loc : user
	if(!user.flashlight_on)
		actual_location.set_light(2)
		user.card.set_light(2)
	else
		actual_location.set_light(0)
		user.card.set_light(0)

	user.flashlight_on = !user.flashlight_on

/datum/pai_software/flashlight/is_active(mob/living/silicon/pai/user)
	return user.flashlight_on
*/
