/datum/pai_software
	// Name for the software. This is used as the button text when buying or opening/toggling the software
	var/name = "pAI software module"
	// RAM cost; pAIs start with 100 RAM, spending it on programs
	var/ram_cost = 0
	// ID for the software. This must be unique
	var/id = ""
	// Whether this software is a toggle or not
	// Toggled software should override toggle() and is_active()
	// Non-toggled software should override on_ui_data() and Topic()
	var/toggle = 1
	// Whether pAIs should automatically receive this module at no cost
	var/default = 0

	// Vars for pAI nanoUI handling
	var/autoupdate = 0
	var/template_file = "oops"
	var/ui_title = "somebody forgot to set this"
	var/ui_width = 450
	var/ui_height = 600

/datum/pai_software/proc/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
	return list()

/datum/pai_software/proc/toggle(mob/living/silicon/pai/user)
		return

/datum/pai_software/proc/is_active(mob/living/silicon/pai/user)
		return 0

/datum/pai_software/directives
	name = "Directives"
	ram_cost = 0
	id = "directives"
	toggle = 0
	default = 1

	template_file = "pai_directives.tmpl"
	ui_title = "pAI Directives"
	autoupdate = 1

/datum/pai_software/directives/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
	var/data[0]

	data["master"] = user.master
	data["dna"] = user.master_dna
	data["prime"] = user.pai_law0
	data["supplemental"] = user.pai_laws

	return data

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

/datum/pai_software/radio_config/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
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

/datum/pai_software/crew_manifest
	name = "Crew Manifest"
	ram_cost = 5
	id = "manifest"
	toggle = 0

	autoupdate = 1
	template_file = "pai_manifest.tmpl"
	ui_title = "Crew Manifest"

/datum/pai_software/crew_manifest/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
	var/data[0]

	data_core.get_manifest_json()
	data["manifest"] = PDA_Manifest

	return data

/datum/pai_software/messenger
	name = "Digital Messenger"
	ram_cost = 5
	id = "messenger"
	toggle = 0

	autoupdate = 1
	template_file = "pai_messenger.tmpl"
	ui_title = "Digital Messenger"

/datum/pai_software/messenger/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
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
		for(var/obj/item/pda/P in PDAs)
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


/datum/pai_software/med_records/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
	var/data[0]

	var/records[0]
	for(var/datum/data/record/general in sortRecord(data_core.general))
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
			if(!( data_core.general.Find(R) ))
				P.medical_cannotfind = 1
			else
				P.medical_cannotfind = 0
				for(var/datum/data/record/E in data_core.medical)
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


/datum/pai_software/sec_records/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
	var/data[0]

	var/records[0]
	for(var/datum/data/record/general in sortRecord(data_core.general))
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
			if(!( data_core.general.Find(R) ))
				P.securityActive1 = null
				P.securityActive2 = null
				P.security_cannotfind = 1
			else
				P.security_cannotfind = 0
				for(var/datum/data/record/E in data_core.security)
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

/datum/pai_software/door_jack/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
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
	var/turf/T = get_turf_or_move(src.loc)
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(!T || !is_station_contact(T.z))
			break
		if(T.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
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

/datum/pai_software/atmosphere_sensor
	name = "Atmosphere Sensor"
	ram_cost = 5
	id = "atmos_sense"
	toggle = 0

	template_file = "pai_atmosphere.tmpl"
	ui_title = "Atmosphere Sensor"
	ui_width = 350
	ui_height = 300


/datum/pai_software/atmosphere_sensor/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
	var/data[0]

	var/turf/T = get_turf_or_move(user.loc)
	if(!T)
		data["reading"] = 0
		data["pressure"] = 0
		data["temperature"] = 0
		data["temperatureC"] = 0
		data["gas"] = list()
	else
		var/datum/gas_mixture/env = T.return_air()
		data["reading"] = 1
		data["pressure"] = env.return_pressure()
		data["temperature"] = round(env.temperature)
		data["temperatureC"] = round(env.temperature-T0C)

		var/t_moles = env.total_moles()
		var/gases[0]
		if(t_moles)
			var/n2[0]
			n2["name"] = "Nitrogen"
			n2["percent"] = round((env.nitrogen/t_moles)*100)
			var/o2[0]
			o2["name"] = "Oxygen"
			o2["percent"] = round((env.oxygen/t_moles)*100)
			var/co2[0]
			co2["name"] = "Carbon Dioxide"
			co2["percent"] = round((env.carbon_dioxide/t_moles)*100)
			var/plasma[0]
			plasma["name"] = "Plasma"
			plasma["percent"] = round((env.toxins/t_moles)*100)
			var/other[0]
			other["name"] = "Other"
			other["percent"] = round(1-((env.oxygen/t_moles)+(env.nitrogen/t_moles)+(env.carbon_dioxide/t_moles)+(env.toxins/t_moles)))
			gases[++gases.len] = n2
			gases[++gases.len] = o2
			gases[++gases.len] = co2
			gases[++gases.len] = plasma
			gases[++gases.len] = other
		data["gas"] = gases

		return data

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

/datum/pai_software/signaller/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
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

/datum/pai_software/host_scan/on_ui_data(mob/living/silicon/pai/user, datum/topic_state/state = self_state)
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
	if(user.flashlight_on)
		actual_location.set_light(2)
		user.card.set_light(2)
		return
	actual_location.set_light(2)
	user.card.set_light(0)

/datum/pai_software/flashlight/is_active(mob/living/silicon/pai/user)
	return user.flashlight_on
