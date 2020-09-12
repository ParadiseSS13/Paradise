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
				var/new_s_tone = null
				if(owner.dna.species.bodyflags & HAS_SKIN_TONE)
					new_s_tone = input(usr, "Choose your character's skin tone:\n(Light 1 - 220 Dark)", "Skin Tone", owner.s_tone) as num|null
					if(isnum(new_s_tone) && (!..()))
						new_s_tone = 35 - max(min(round(new_s_tone), 220),1)
				else if(owner.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
					var/const/MAX_LINE_ENTRIES = 4
					var/prompt = "Choose your character's skin tone: 1-[length(owner.dna.species.icon_skin_tones)]\n("
					for(var/i in 1 to length(owner.dna.species.icon_skin_tones))
						if(i > MAX_LINE_ENTRIES && !((i - 1) % MAX_LINE_ENTRIES))
							prompt += "\n"
						prompt += "[i] = [owner.dna.species.icon_skin_tones[i]]"
						if(i != length(owner.dna.species.icon_skin_tones))
							prompt += ", "
					prompt += ")"

					new_s_tone = input(usr, prompt, "Skin Tone", owner.s_tone) as num|null
					if(isnum(new_s_tone) && (!..()))
						new_s_tone = max(min(round(new_s_tone), length(owner.dna.species.icon_skin_tones)), 1)

				if(new_s_tone)
					owner.change_skin_tone(new_s_tone)

		if("skin_color")
			if(can_change_skin_color())
				var/new_skin = input(usr, "Choose your character's skin colour: ", "Skin Color", owner.skin_colour) as color|null
				if(new_skin && (!..()) && owner.change_skin_color(new_skin))
					update_dna()

		if("hair")
			if(can_change(APPEARANCE_HAIR) && (params["hair"] in valid_hairstyles))
				if(owner.change_hair(params["hair"]))
					update_dna()

		if("hair_color")
			if(can_change(APPEARANCE_HAIR_COLOR))
				var/new_hair = input("Please select hair color.", "Hair Color", head_organ.hair_colour) as color|null
				if(new_hair && (!..()) && owner.change_hair_color(new_hair))
					update_dna()

		if("secondary_hair_color")
			if(can_change(APPEARANCE_SECONDARY_HAIR_COLOR))
				var/new_hair = input("Please select secondary hair color.", "Secondary Hair Color", head_organ.sec_hair_colour) as color|null
				if(new_hair && (!..()) && owner.change_hair_color(new_hair, 1))
					update_dna()

		if("facial_hair")
			if(can_change(APPEARANCE_FACIAL_HAIR) && (params["facial_hair"] in valid_facial_hairstyles))
				if(owner.change_facial_hair(params["facial_hair"]))
					update_dna()

		if("facial_hair_color")
			if(can_change(APPEARANCE_FACIAL_HAIR_COLOR))
				var/new_facial = input("Please select facial hair color.", "Facial Hair Color", head_organ.facial_colour) as color|null
				if(new_facial && (!..()) && owner.change_facial_hair_color(new_facial))
					update_dna()

		if("secondary_facial_hair_color")
			if(can_change(APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR))
				var/new_facial = input("Please select secondary facial hair color.", "Secondary Facial Hair Color", head_organ.sec_facial_colour) as color|null
				if(new_facial && (!..()) && owner.change_facial_hair_color(new_facial, 1))
					update_dna()

		if("eye_color")
			if(can_change(APPEARANCE_EYE_COLOR))
				var/obj/item/organ/internal/eyes/eyes_organ = owner.get_int_organ(/obj/item/organ/internal/eyes)
				var/new_eyes = input("Please select eye color.", "Eye Color", eyes_organ.eye_colour) as color|null
				if(new_eyes && (!..()) && owner.change_eye_color(new_eyes))
					update_dna()

		if("head_accessory")
			if(can_change_head_accessory() && (params["head_accessory"] in valid_head_accessories))
				if(owner.change_head_accessory(params["head_accessory"]))
					update_dna()

		if("head_accessory_color")
			if(can_change_head_accessory())
				var/new_head_accessory = input("Please select head accessory color.", "Head Accessory Color", head_organ.headacc_colour) as color|null
				if(new_head_accessory && (!..()) && owner.change_head_accessory_color(new_head_accessory))
					update_dna()

		if("head_marking")
			if(can_change_markings("head") && (params["head_marking"] in valid_head_marking_styles))
				if(owner.change_markings(params["head_marking"], "head"))
					update_dna()

		if("head_marking_color")
			if(can_change_markings("head"))
				var/new_markings = input("Please select head marking color.", "Marking Color", owner.m_colours["head"]) as color|null
				if(new_markings && (!..()) && owner.change_marking_color(new_markings, "head"))
					update_dna()

		if("body_marking")
			if(can_change_markings("body") && (params["body_marking"] in valid_body_marking_styles))
				if(owner.change_markings(params["body_marking"], "body"))
					update_dna()

		if("body_marking_color")
			if(can_change_markings("body"))
				var/new_markings = input("Please select body marking color.", "Marking Color", owner.m_colours["body"]) as color|null
				if(new_markings && (!..()) && owner.change_marking_color(new_markings, "body"))
					update_dna()

		if("tail_marking")
			if(can_change_markings("tail") && (params["tail_marking"] in valid_tail_marking_styles))
				if(owner.change_markings(params["tail_marking"], "tail"))
					update_dna()

		if("tail_marking_color")
			if(can_change_markings("tail"))
				var/new_markings = input("Please select tail marking color.", "Marking Color", owner.m_colours["tail"]) as color|null
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


/datum/ui_module/appearance_changer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AppearanceChanger", name, 800, 450, master_ui, state)
		ui.open()

/datum/ui_module/appearance_changer/ui_data(mob/user)
	generate_data(check_whitelist, whitelist, blacklist)
	var/list/data = list()

	data["specimen"] = owner.dna.species.name
	data["gender"] = owner.gender
	data["has_gender"] = owner.dna.species.has_gender
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
	data["change_head_accessory"] = can_change_head_accessory()
	if(data["change_head_accessory"])
		var/list/head_accessory_styles = list()
		for(var/head_accessory_style in valid_head_accessories)
			head_accessory_styles += list(list("headaccessorystyle" = head_accessory_style))
		data["head_accessory_styles"] = head_accessory_styles
		data["head_accessory_style"] = head_organ ? head_organ.ha_style : "None"

	data["change_hair"] = can_change(APPEARANCE_HAIR)
	if(data["change_hair"])
		var/list/hair_styles = list()
		for(var/hair_style in valid_hairstyles)
			hair_styles += list(list("hairstyle" = hair_style))
		data["hair_styles"] = hair_styles
		data["hair_style"] = head_organ ? head_organ.h_style : "Skinhead"

	data["change_facial_hair"] = can_change(APPEARANCE_FACIAL_HAIR)
	if(data["change_facial_hair"])
		var/list/facial_hair_styles = list()
		for(var/facial_hair_style in valid_facial_hairstyles)
			facial_hair_styles += list(list("facialhairstyle" = facial_hair_style))
		data["facial_hair_styles"] = facial_hair_styles
		data["facial_hair_style"] = head_organ ? head_organ.f_style : "Shaved"

	data["change_head_markings"] = can_change_markings("head")
	if(data["change_head_markings"])
		var/m_style = owner.m_styles["head"]
		var/list/head_marking_styles = list()
		for(var/head_marking_style in valid_head_marking_styles)
			head_marking_styles += list(list("headmarkingstyle" = head_marking_style))
		data["head_marking_styles"] = head_marking_styles
		data["head_marking_style"] = m_style

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
	data["change_hair_color"] = can_change(APPEARANCE_HAIR_COLOR)
	data["change_secondary_hair_color"] = can_change(APPEARANCE_SECONDARY_HAIR_COLOR)
	data["change_facial_hair_color"] = can_change(APPEARANCE_FACIAL_HAIR_COLOR)
	data["change_secondary_facial_hair_color"] = can_change(APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR)
	data["change_head_marking_color"] = can_change_markings("head")
	data["change_body_marking_color"] = can_change_markings("body")
	data["change_tail_marking_color"] = can_change_markings("tail")

	return data

/datum/ui_module/appearance_changer/proc/update_dna()
	if(owner && (flags & APPEARANCE_UPDATE_DNA))
		owner.update_dna()

/datum/ui_module/appearance_changer/proc/can_change(flag)
	return owner && (flags & flag)

/datum/ui_module/appearance_changer/proc/can_change_skin_tone()
	return owner && (flags & APPEARANCE_SKIN) && owner.dna && ((owner.dna.species.bodyflags & HAS_SKIN_TONE) || (owner.dna.species.bodyflags & HAS_ICON_SKIN_TONE))

/datum/ui_module/appearance_changer/proc/can_change_skin_color()
	return owner && (flags & APPEARANCE_SKIN) && owner.dna && (owner.dna.species.bodyflags & HAS_SKIN_COLOR)

/datum/ui_module/appearance_changer/proc/can_change_head_accessory()
	if(!head_organ)
		log_runtime(EXCEPTION("Missing head!"), owner)
		return FALSE
	if(!head_organ.dna)
		log_runtime(EXCEPTION("Missing head DNA!"), owner)
		return FALSE
	return owner && (flags & APPEARANCE_HEAD_ACCESSORY) && (head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)

/datum/ui_module/appearance_changer/proc/can_change_markings(location = "body")
	var/marking_flag = HAS_BODY_MARKINGS
	var/body_flags = owner.dna.species.bodyflags
	if(location == "head")
		if(!head_organ)
			log_debug("Missing head!")
			return FALSE
		if(!head_organ.dna)
			log_debug("Missing head DNA!")
			return FALSE
		body_flags = head_organ.dna.species.bodyflags
		marking_flag = HAS_HEAD_MARKINGS
	if(location == "body")
		marking_flag = HAS_BODY_MARKINGS
	if(location == "tail")
		marking_flag = HAS_TAIL_MARKINGS

	return owner && (flags & APPEARANCE_MARKINGS) && (body_flags & marking_flag)

/datum/ui_module/appearance_changer/proc/can_change_body_accessory()
	return owner && (flags & APPEARANCE_BODY_ACCESSORY) && (owner.dna.species.bodyflags & HAS_TAIL)

/datum/ui_module/appearance_changer/proc/can_change_alt_head()
	if(!head_organ)
		log_debug("Missing head!")
		return FALSE
	if(!head_organ.dna)
		log_debug("Missing head DNA!")
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
