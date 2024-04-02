/obj/item/card/id/syndicate
	var/list/card_images
	var/mob/living/carbon/human/registered_human
	var/list/appearances = list(
							"data",
							"id",
							"gold",
							"silver",
							"centcom",
							"security",
							"detective",
							"warden",
							"internalaffairsagent",
							"medical",
							"coroner",
							"virologist",
							"chemist",
							"paramedic",
							"psychiatrist",
							"research",
							"roboticist",
							"quartermaster",
							"cargo",
							"shaftminer",
							"engineering",
							"atmostech",
							"captain",
							"HoP",
							"HoS",
							"CMO",
							"RD",
							"CE",
							"assistant",
							"clown",
							"mime",
							"barber",
							"botanist",
							"librarian",
							"chaplain",
							"bartender",
							"chef",
							"janitor",
							"explorer",
							"rainbow",
							"prisoner",
							"syndie",
							"deathsquad",
							"commander",
							"ERT_leader",
							"ERT_security",
							"ERT_engineering",
							"ERT_medical",
							"ERT_janitorial",
							"ERT_paranormal",
						)

/obj/item/card/id/syndicate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!registered_human)
		return
	. = TRUE
	switch(action)
		if("delete_info")
			delete_info()
		if("clear_access")
			clear_access()
		if("change_ai_tracking")
			change_ai_tracking()
		if("change_name")
			change_name()
		if("change_photo")
			change_photo()
		if("change_appearance")
			change_appearance(params)
		if("change_sex")
			change_sex()
		if("change_age")
			change_age()
		if("change_occupation")
			change_occupation()
		if("change_money_account")
			change_money_account()
		if("change_blood_type")
			change_blood_type()
		if("change_dna_hash")
			change_dna_hash()
		if("change_fingerprints")
			change_fingerprints()
	RebuildHTML()

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = list()
	data["registered_name"] = registered_name
	data["sex"] = sex
	data["age"] = age
	data["assignment"] = assignment
	data["associated_account_number"] = associated_account_number
	data["blood_type"] = blood_type
	data["dna_hash"] = dna_hash
	data["fingerprint_hash"] = fingerprint_hash
	data["photo"] = photo
	data["ai_tracking"] = untrackable
	return data

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = list()
	if(!length(card_images))
		var/list/new_images = list()
		for(var/appearance_name in appearances)
			new_images.Add(list(list(
				"name" = appearance_name,
				"image" = "[icon2base64(icon(initial(icon), appearance_name, SOUTH, 1))]"
			)))
		card_images = new_images
	data["appearances"] = card_images
	return data

/obj/item/card/id/syndicate/ui_state(mob/user)
	return GLOB.default_state

/obj/item/card/id/syndicate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AgentCard", name)
		ui.open()

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!registered_human)
		registered_human = user
	if(registered_human != user)
		return flash_card(user)
	switch(alert("Would you like to display \the [src] or edit it?","Choose","Show","Edit"))
		if("Show")
			return flash_card(user)
		if("Edit")
			ui_interact(user)
			return

/obj/item/card/id/proc/flash_card(mob/user)
	user.visible_message("[user] shows you: [bicon(src)] [src.name]. The assignment on the card: [src.assignment]",\
		"You flash your ID card: [bicon(src)] [src.name]. The assignment on the card: [src.assignment]")
	if(mining_points)
		to_chat(user, "There's <b>[mining_points] Mining Points</b> loaded onto this card. This card has earned <b>[total_mining_points] Mining Points</b> this Shift!")
	src.add_fingerprint(user)

/obj/item/card/id/syndicate/proc/delete_info()
	var/response = alert(registered_human, "Are you sure you want to delete all card info?","Delete Card Info", "No", "Yes")
	if(response == "Yes")
		name = initial(name)
		registered_name = initial(registered_name)
		icon_state = initial(icon_state)
		sex = initial(sex)
		age = initial(age)
		assignment = initial(assignment)
		associated_account_number = initial(associated_account_number)
		blood_type = initial(blood_type)
		dna_hash = initial(dna_hash)
		fingerprint_hash = initial(fingerprint_hash)
		photo = null
		registered_human = null

/obj/item/card/id/syndicate/proc/clear_access()
	var/response = alert(registered_human, "Are you sure you want to reset access saved on the card?","Reset Access", "No", "Yes")
	if(response == "Yes")
		access = initial_access.Copy() // Initial() doesn't work on lists
		to_chat(registered_human, span_notice("Card access reset."))

/obj/item/card/id/syndicate/proc/change_ai_tracking()
	untrackable = !untrackable
	to_chat(registered_human, span_notice("This ID card is now [untrackable ? "untrackable" : "trackable"] by the AI's."))

/obj/item/card/id/syndicate/proc/change_name()
	var/new_name = reject_bad_name(input(registered_human,"What name would you like to put on this card?","Agent Card Name", ishuman(registered_human) ? registered_human.real_name : registered_human.name), TRUE)
	if(!Adjacent(registered_human))
		return
	registered_name = new_name
	UpdateName()
	to_chat(registered_human, span_notice("Name changed to [new_name]."))

/obj/item/card/id/syndicate/proc/change_photo()
	if(!Adjacent(registered_human))
		return
	var/job_clothes = null
	if(assignment)
		job_clothes = assignment
	var/icon/newphoto = get_id_photo(registered_human, job_clothes)
	if(!newphoto)
		return
	photo = newphoto
	to_chat(registered_human, span_notice("Photo changed. Select another occupation and take a new photo if you wish to appear with different clothes."))

/obj/item/card/id/syndicate/proc/change_appearance(list/params)
	var/choice = params["new_appearance"]
	icon_state = choice
	to_chat(usr, span_notice("Appearance changed to [choice]."))

/obj/item/card/id/syndicate/proc/change_sex()
	var/new_sex = sanitize(stripped_input(registered_human,"What sex would you like to put on this card?","Agent Card Sex", ishuman(registered_human) ? capitalize(registered_human.gender) : "Male", MAX_MESSAGE_LEN))
	if(!Adjacent(registered_human))
		return
	sex = new_sex
	to_chat(registered_human, span_notice("Sex changed to [new_sex]."))

/obj/item/card/id/syndicate/proc/change_age()
	var/default = "21"
	if(ishuman(registered_human))
		var/mob/living/carbon/human/H = registered_human
		default = H.age
	var/new_age = sanitize(input(registered_human,"What age would you like to be written on this card?","Agent Card Age", default) as text)
	if(!Adjacent(registered_human))
		return
	age = new_age
	to_chat(registered_human, span_notice("Age changed to [new_age]."))

/obj/item/card/id/syndicate/proc/change_occupation()
	var/list/departments =list(
				"Civilian",
				"Engineering",
				"Medical",
				"Science",
				"Security",
				"Support",
				"Command",
				"Special",
				"Custom",
			)

	var/department = tgui_input_list(registered_human, "What job would you like to put on this card?\nChoose a department or a custom job title.\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", departments)
	var/new_job = "Civilian"
	var/new_rank = "Civilian"

	if(department == "Custom")
		new_job = sanitize(stripped_input(registered_human,"Choose a custom job title:","Agent Card Occupation", "Civilian", MAX_MESSAGE_LEN))
		var/department_icon = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", departments)
		switch(department_icon)
			if("Engineering")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.engineering_positions)
			if("Medical")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.medical_positions)
			if("Science")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.science_positions)
			if("Security")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.security_positions)
			if("Support")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.service_positions)
			if("Command")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.command_positions)
			if("Special")
				new_rank = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs()))
			if("Custom")
				new_rank = null
	else if(department != "Civilian")
		switch(department)
			if("Engineering")
				new_job = tgui_input_list(registered_human, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.engineering_positions)
			if("Medical")
				new_job = tgui_input_list(registered_human, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.medical_positions)
			if("Science")
				new_job = tgui_input_list(registered_human, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.science_positions)
			if("Security")
				new_job = tgui_input_list(registered_human, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.security_positions)
			if("Support")
				new_job = tgui_input_list(registered_human, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.service_positions)
			if("Command")
				new_job = tgui_input_list(registered_human, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.", "Agent Card Occupation", GLOB.command_positions)
			if("Special")
				new_job = tgui_input_list(registered_human, "What job would you like to be shown on this card (for SecHUDs)?\nChanging occupation will not grant or remove any access levels.","Agent Card Occupation", (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs()))
		new_rank = new_job

	if(!Adjacent(registered_human))
		return
	assignment = new_job
	rank = new_rank
	to_chat(registered_human, span_notice("Occupation changed to [new_job]."))
	UpdateName()
	registered_human.sec_hud_set_ID()

/obj/item/card/id/syndicate/proc/change_money_account()
	var/new_account = input(registered_human,"What money account would you like to link to this card?","Agent Card Account",12345) as num
	if(!Adjacent(registered_human))
		return
	associated_account_number = new_account
	to_chat(registered_human, span_notice("Linked money account changed to [new_account]."))

/obj/item/card/id/syndicate/proc/change_blood_type()
	var/default = "\[UNSET\]"
	if(ishuman(registered_human))
		var/mob/living/carbon/human/H = registered_human
		if(H.dna)
			default = H.dna.blood_type
	var/new_blood_type = sanitize(input(registered_human,"What blood type would you like to be written on this card?","Agent Card Blood Type",default) as text)
	if(!Adjacent(registered_human))
		return
	blood_type = new_blood_type
	to_chat(registered_human, span_notice("Blood type changed to [new_blood_type]."))

/obj/item/card/id/syndicate/proc/change_dna_hash()
	var/default = "\[UNSET\]"
	if(ishuman(registered_human))
		var/mob/living/carbon/human/H = registered_human
		if(H.dna)
			default = H.dna.unique_enzymes
	var/new_dna_hash = sanitize(input(registered_human,"What DNA hash would you like to be written on this card?","Agent Card DNA Hash",default) as text)
	if(!Adjacent(registered_human))
		return
	dna_hash = new_dna_hash
	to_chat(registered_human, span_notice(">DNA hash changed to [new_dna_hash]."))

/obj/item/card/id/syndicate/proc/change_fingerprints()
	var/default = "\[UNSET\]"
	if(ishuman(registered_human))
		var/mob/living/carbon/human/H = registered_human
		if(H.dna)
			default = md5(H.dna.uni_identity)
	var/new_fingerprint_hash = sanitize(input(registered_human,"What fingerprint hash would you like to be written on this card?","Agent Card Fingerprint Hash",default) as text)
	if(!Adjacent(registered_human))
		return
	fingerprint_hash = new_fingerprint_hash
	to_chat(registered_human, span_notice("Fingerprint hash changed to [new_fingerprint_hash]."))
