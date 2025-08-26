/datum/ui_module/appearance_changer
	name = "Appearance Editor"
	var/flags = APPEARANCE_ALL_HAIR
	var/mob/living/carbon/human/owner = null
	var/obj/item/organ/external/head/head_organ = null
	var/list/valid_species = list()
	var/list/valid_hairstyles = list()
	var/list/valid_facial_hairstyles = list()
	var/list/valid_head_accessories = list()
	var/list/valid_head_marking_styles = list()
	var/list/valid_body_marking_styles = list()
	var/list/valid_tail_marking_styles = list()
	var/list/valid_body_accessories = list()
	var/list/valid_alt_head_styles = list()

	var/check_whitelist
	var/list/whitelist
	var/list/blacklist

/datum/ui_module/appearance_changer/New(datum/host, mob/living/carbon/human/H, check_species_whitelist = TRUE, list/species_whitelist = list(), list/species_blacklist = list())
	..()
	owner = H
	head_organ = owner.get_organ("head")
	check_whitelist = check_species_whitelist
	whitelist = species_whitelist
	blacklist = species_blacklist

/datum/ui_module/appearance_changer/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("race")
			if(can_change(APPEARANCE_RACE) && (params["race"] in valid_species))
				var/datum/species/S = GLOB.all_species[params["race"]]
				if(owner.set_species(S.type))
					cut_and_generate_data()
					// Species change creates new organs - runtimes ahoy if we forget this
					head_organ = owner.get_organ("head")

		if("gender")
			if(can_change(APPEARANCE_GENDER))
				if(owner.change_gender(params["gender"]))
					cut_and_generate_data()

		if("skin_tone")
			if(can_change_skin_tone())
				var/new_s_tone
				if(owner.dna.species.bodyflags & HAS_SKIN_TONE)
					new_s_tone = tgui_input_number(usr, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference", owner.s_tone, 220, 1)
				else if(owner.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
					var/prompt = "Choose your character's skin tone: 1-[length(owner.dna.species.icon_skin_tones)]\n(Light to Dark)"
					new_s_tone = tgui_input_number(usr, prompt, "Character Preference", owner.s_tone, length(owner.dna.species.icon_skin_tones), 1)

				if(!isnull(new_s_tone) && (!..()) && owner.change_skin_tone(new_s_tone))
					update_dna()

		if("skin_color")
			if(can_change_skin_color())
				var/new_skin = tgui_input_color(usr, "Choose your character's skin colour: ", "Skin Color", owner.skin_colour)
				if(!isnull(new_skin) && (!..()) && owner.change_skin_color(new_skin))
					update_dna()

		if("hair")
			if(can_change(APPEARANCE_HAIR) && (params["hair"] in valid_hairstyles))
				if(owner.change_hair(params["hair"]))
					update_dna()

		if("hair_color")
			if(can_change(APPEARANCE_HAIR_COLOR))
				var/new_hair = tgui_input_color(usr, "Please select hair color.", "Hair Color", head_organ.hair_colour)
				if(!isnull(new_hair) && (!..()) && owner.change_hair_color(new_hair))
					update_dna()

		if("secondary_hair_color")
			if(can_change(APPEARANCE_SECONDARY_HAIR_COLOR))
				var/new_hair = tgui_input_color(usr, "Please select secondary hair color.", "Secondary Hair Color", head_organ.sec_hair_colour)
				if(!isnull(new_hair) && (!..()) && owner.change_hair_color(new_hair, 1))
					update_dna()

		if("hair_gradient")
			if(can_change(APPEARANCE_HAIR) && length(valid_hairstyles))
				var/new_style = tgui_input_list(usr, "Please select gradient style", "Hair Gradient", GLOB.hair_gradients_list)
				if(!isnull(new_style))
					owner.change_hair_gradient(style = new_style)

		if("hair_gradient_offset")
			if(can_change(APPEARANCE_HAIR) && length(valid_hairstyles))
				var/new_offset = input("Please enter gradient offset as a comma-separated value (x,y). Example:\n0,0 (no offset)\n5,0 (5 pixels to the right)", "Hair Gradient", "[head_organ.h_grad_offset_x],[head_organ.h_grad_offset_y]") as null|text
				if(!isnull(new_offset))
					owner.change_hair_gradient(offset_raw = new_offset)

		if("hair_gradient_colour")
			if(can_change(APPEARANCE_HAIR) && length(valid_hairstyles))
				var/new_color = tgui_input_color(usr, "Please select gradient color.", "Hair Gradient", head_organ.h_grad_colour)
				if(!isnull(new_color))
					owner.change_hair_gradient(color = new_color)

		if("hair_gradient_alpha")
			if(can_change(APPEARANCE_HAIR) && length(valid_hairstyles))
				var/new_alpha = input("Please enter gradient alpha (0-255).", "Hair Gradient", head_organ.h_grad_alpha) as null|num
				if(!isnull(new_alpha))
					owner.change_hair_gradient(alpha = new_alpha)

		if("facial_hair")
			if(can_change(APPEARANCE_FACIAL_HAIR) && (params["facial_hair"] in valid_facial_hairstyles))
				if(owner.change_facial_hair(params["facial_hair"]))
					update_dna()

		if("facial_hair_color")
			if(can_change(APPEARANCE_FACIAL_HAIR_COLOR))
				var/new_facial = tgui_input_color(usr, "Please select facial hair color.", "Facial Hair Color", head_organ.facial_colour)
				if(!isnull(new_facial) && (!..()) && owner.change_facial_hair_color(new_facial))
					update_dna()

		if("secondary_facial_hair_color")
			if(can_change(APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR))
				var/new_facial = tgui_input_color(usr, "Please select secondary facial hair color.", "Secondary Facial Hair Color", head_organ.sec_facial_colour)
				if(!isnull(new_facial) && (!..()) && owner.change_facial_hair_color(new_facial, 1))
					update_dna()

		if("eye_color")
			if(can_change(APPEARANCE_EYE_COLOR))
				var/obj/item/organ/internal/eyes/eyes_organ = owner.get_int_organ(/obj/item/organ/internal/eyes)
				var/new_eyes = tgui_input_color(usr, "Please select eye color.", "Eye Color", eyes_organ.eye_color)
				if(!isnull(new_eyes) && (!..()) && owner.change_eye_color(new_eyes))
					update_dna()

		if("runechat_color")
			var/new_runechat_color = tgui_input_color(usr, "Please select runechat color.", "Runechat Color", owner.dna.chat_color)
			if(!isnull(new_runechat_color) && (!..()))
				owner.change_runechat_color(new_runechat_color)

		if("head_accessory")
			if(can_change_head_accessory() && (params["head_accessory"] in valid_head_accessories))
				if(owner.change_head_accessory(params["head_accessory"]))
					update_dna()

		if("head_accessory_color")
			if(can_change_head_accessory())
				var/new_head_accessory = tgui_input_color(usr, "Please select head accessory color.", "Head Accessory Color", head_organ.headacc_colour)
				if(!isnull(new_head_accessory) && (!..()) && owner.change_head_accessory_color(new_head_accessory))
					update_dna()

		if("head_marking")
			if(can_change_markings("head") && (params["head_marking"] in valid_head_marking_styles))
				if(owner.change_markings(params["head_marking"], "head"))
					update_dna()

		if("head_marking_color")
			if(can_change_markings("head"))
				var/new_markings = tgui_input_color(usr, "Please select head marking color.", "Marking Color", owner.m_colours["head"])
				if(new_markings && (!..()) && owner.change_marking_color(new_markings, "head"))
					update_dna()

		if("body_marking")
			if(can_change_markings("body") && (params["body_marking"] in valid_body_marking_styles))
				if(owner.change_markings(params["body_marking"], "body"))
					update_dna()

		if("body_marking_color")
			if(can_change_markings("body"))
				var/new_markings = tgui_input_color(usr, "Please select body marking color.", "Marking Color", owner.m_colours["body"])
				if(new_markings && (!..()) && owner.change_marking_color(new_markings, "body"))
					update_dna()

		if("tail_marking")
			if(can_change_markings("tail") && (params["tail_marking"] in valid_tail_marking_styles))
				if(owner.change_markings(params["tail_marking"], "tail"))
					update_dna()

		if("tail_marking_color")
			if(can_change_markings("tail"))
				var/new_markings = tgui_input_color(usr, "Please select tail marking color.", "Marking Color", owner.m_colours["tail"])
				if(new_markings && (!..()) && owner.change_marking_color(new_markings, "tail"))
					update_dna()

		if("body_accessory")
			if(can_change_body_accessory() && (params["body_accessory"] in valid_body_accessories))
				if(owner.change_body_accessory(params["body_accessory"]))
					update_dna()
					cut_and_generate_data()

		if("alt_head")
			if(can_change_alt_head() && (params["alt_head"] in valid_alt_head_styles))
				if(owner.change_alt_head(params["alt_head"]))
					update_dna()
					head_organ = owner.get_organ("head") //Update the head with the new information.
					cut_and_generate_data()


/datum/ui_module/appearance_changer/ui_state(mob/user)
	return GLOB.default_state

/datum/ui_module/appearance_changer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AppearanceChanger", name)
		ui.open()

/datum/ui_module/appearance_changer/ui_data(mob/user)
	generate_data(check_whitelist, whitelist, blacklist)
	var/list/data = list()

	data["specimen"] = owner.dna.species.name
	data["gender"] = owner.gender
	data["change_race"] = can_change(APPEARANCE_RACE)
	if(data["change_race"])
		var/list/species = list()
		for(var/specimen in valid_species)
			species += list(list("specimen" = specimen))
		data["species"] = species

	data["change_gender"] = can_change(APPEARANCE_GENDER)
	data["change_skin_tone"] = can_change_skin_tone()
	data["change_skin_color"] = can_change_skin_color()
	data["change_eye_color"] = can_change(APPEARANCE_EYE_COLOR)
	data["change_runechat_color"] = TRUE
	data["change_head_accessory"] = can_change_head_accessory()
	if(data["change_head_accessory"])
		var/list/head_accessory_styles = list()
		for(var/head_accessory_style in valid_head_accessories)
			head_accessory_styles += list(list("headaccessorystyle" = head_accessory_style))
		data["head_accessory_styles"] = head_accessory_styles
		data["head_accessory_style"] = head_organ ? head_organ.ha_style : "None"

	if(!(owner.dna.species.bodyflags & BALD))
		data["change_hair"] = can_change(APPEARANCE_HAIR)
		if(data["change_hair"])
			var/list/hair_styles = list()
			for(var/hair_style in valid_hairstyles)
				hair_styles += list(list("hairstyle" = hair_style))
			data["hair_styles"] = hair_styles
			data["hair_style"] = head_organ ? head_organ.h_style : "Skinhead"
		data["change_hair_color"] = can_change(APPEARANCE_HAIR_COLOR)
		data["change_secondary_hair_color"] = can_change(APPEARANCE_SECONDARY_HAIR_COLOR)

	if(!(owner.dna.species.bodyflags & SHAVED))
		data["change_facial_hair"] = can_change(APPEARANCE_FACIAL_HAIR)
		if(data["change_facial_hair"])
			var/list/facial_hair_styles = list()
			for(var/facial_hair_style in valid_facial_hairstyles)
				facial_hair_styles += list(list("facialhairstyle" = facial_hair_style))
			data["facial_hair_styles"] = facial_hair_styles
			data["facial_hair_style"] = head_organ ? head_organ.f_style : "Shaved"
		data["change_facial_hair_color"] = can_change(APPEARANCE_FACIAL_HAIR_COLOR)
		data["change_secondary_facial_hair_color"] = can_change(APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR)
		data["change_hair_gradient"] = can_change(APPEARANCE_HAIR) && length(valid_hairstyles)

	if(!ismachineperson(owner))
		data["change_head_markings"] = can_change_markings("head")
		if(data["change_head_markings"])
			var/m_style = owner.m_styles["head"]
			var/list/head_marking_styles = list()
			for(var/head_marking_style in valid_head_marking_styles)
				head_marking_styles += list(list("headmarkingstyle" = head_marking_style))
			data["head_marking_styles"] = head_marking_styles
			data["head_marking_style"] = m_style
		data["change_head_marking_color"] = can_change_markings("head")

	data["change_body_markings"] = can_change_markings("body")
	if(data["change_body_markings"])
		var/m_style = owner.m_styles["body"]
		var/list/body_marking_styles = list()
		for(var/body_marking_style in valid_body_marking_styles)
			body_marking_styles += list(list("bodymarkingstyle" = body_marking_style))
		data["body_marking_styles"] = body_marking_styles
		data["body_marking_style"] = m_style

	data["change_tail_markings"] = can_change_markings("tail")
	if(data["change_tail_markings"])
		var/m_style = owner.m_styles["tail"]
		var/list/tail_marking_styles = list()
		for(var/tail_marking_style in valid_tail_marking_styles)
			tail_marking_styles += list(list("tailmarkingstyle" = tail_marking_style))
		data["tail_marking_styles"] = tail_marking_styles
		data["tail_marking_style"] = m_style

	data["change_body_accessory"] = can_change_body_accessory()
	if(data["change_body_accessory"])
		var/list/body_accessory_styles = list()
		for(var/body_accessory_style in valid_body_accessories)
			body_accessory_styles += list(list("bodyaccessorystyle" = body_accessory_style))
		data["body_accessory_styles"] = body_accessory_styles
		data["body_accessory_style"] = owner.body_accessory ? owner.body_accessory.name : "None"

	data["change_alt_head"] = can_change_alt_head()
	if(data["change_alt_head"])
		var/list/alt_head_styles = list()
		for(var/alt_head_style in valid_alt_head_styles)
			alt_head_styles += list(list("altheadstyle" = alt_head_style))
		data["alt_head_styles"] = alt_head_styles
		data["alt_head_style"] = head_organ.alt_head

	data["change_head_accessory_color"] = can_change_head_accessory()
	data["change_body_marking_color"] = can_change_markings("body")
	data["change_tail_marking_color"] = can_change_markings("tail")

	return data

/datum/ui_module/appearance_changer/proc/update_dna()
	if(owner)
		owner.update_dna()

/datum/ui_module/appearance_changer/proc/can_change(flag)
	return owner && (flags & flag)

/datum/ui_module/appearance_changer/proc/can_change_skin_tone()
	return owner && (flags & APPEARANCE_SKIN) && ((owner.dna.species.bodyflags & HAS_SKIN_TONE) || (owner.dna.species.bodyflags & HAS_ICON_SKIN_TONE))

/datum/ui_module/appearance_changer/proc/can_change_skin_color()
	return owner && (flags & APPEARANCE_SKIN) && (owner.dna.species.bodyflags & HAS_SKIN_COLOR)

/datum/ui_module/appearance_changer/proc/can_change_head_accessory()
	if(!head_organ)
		stack_trace("[owner] Missing head!")
		return FALSE
	return owner && (flags & APPEARANCE_HEAD_ACCESSORY) && (head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)

/datum/ui_module/appearance_changer/proc/can_change_markings(location = "body")
	var/marking_flag = HAS_BODY_MARKINGS
	var/body_flags = owner.dna.species.bodyflags
	if(location == "head")
		if(!head_organ)
			log_debug("Missing head!")
			return FALSE
		body_flags = head_organ.dna.species.bodyflags
		marking_flag = HAS_HEAD_MARKINGS
	if(location == "body")
		marking_flag = HAS_BODY_MARKINGS
	if(location == "tail")
		marking_flag = HAS_TAIL_MARKINGS

	return owner && (flags & APPEARANCE_MARKINGS) && (body_flags & marking_flag)

/datum/ui_module/appearance_changer/proc/can_change_body_accessory()
	return owner && (flags & APPEARANCE_BODY_ACCESSORY) && (owner.dna.species.bodyflags & HAS_BODY_ACCESSORY)

/datum/ui_module/appearance_changer/proc/can_change_alt_head()
	if(!head_organ)
		log_debug("Missing head!")
		return FALSE
	return owner && (flags & APPEARANCE_ALT_HEAD) && (head_organ.dna.species.bodyflags & HAS_ALT_HEADS)

/datum/ui_module/appearance_changer/proc/cut_and_generate_data()
	// Making the assumption that the available species remain constant
	valid_hairstyles.Cut()
	valid_facial_hairstyles.Cut()
	valid_head_accessories.Cut()
	valid_head_marking_styles.Cut()
	valid_body_marking_styles.Cut()
	valid_tail_marking_styles.Cut()
	valid_body_accessories.Cut()
	valid_alt_head_styles.Cut()
	generate_data()

/datum/ui_module/appearance_changer/proc/generate_data()
	if(!owner)
		return
	if(!length(valid_species))
		valid_species = owner.generate_valid_species(check_whitelist, whitelist, blacklist)
	if(!length(valid_hairstyles) || !length(valid_facial_hairstyles))
		valid_hairstyles = owner.generate_valid_hairstyles()
		valid_facial_hairstyles = owner.generate_valid_facial_hairstyles()
	if(!length(valid_head_accessories))
		valid_head_accessories = owner.generate_valid_head_accessories()
	if(!length(valid_head_marking_styles))
		valid_head_marking_styles = owner.generate_valid_markings("head")
	if(!length(valid_body_marking_styles))
		valid_body_marking_styles = owner.generate_valid_markings("body")
	if(!length(valid_tail_marking_styles))
		valid_tail_marking_styles = owner.generate_valid_markings("tail")
	if(!length(valid_body_accessories))
		valid_body_accessories = owner.generate_valid_body_accessories()
	if(!length(valid_alt_head_styles))
		valid_alt_head_styles = owner.generate_valid_alt_heads()
