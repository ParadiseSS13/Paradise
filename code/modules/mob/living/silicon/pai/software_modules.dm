/*
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

*/
