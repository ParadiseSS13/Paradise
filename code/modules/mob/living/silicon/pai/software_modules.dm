/*
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
