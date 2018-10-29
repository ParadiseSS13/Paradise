/datum/nano_module/appearance_changer
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

/datum/nano_module/appearance_changer/New(var/location, var/mob/living/carbon/human/H, var/check_species_whitelist = 1, var/list/species_whitelist = list(), var/list/species_blacklist = list())
	..()
	owner = H
	head_organ = owner.get_organ("head")
	src.check_whitelist = check_species_whitelist
	src.whitelist = species_whitelist
	src.blacklist = species_blacklist

/datum/nano_module/appearance_changer/Topic(ref, href_list, var/nowindow, var/datum/topic_state/state = default_state)
	if(..())
		return 1

	if(href_list["race"])
		if(can_change(APPEARANCE_RACE) && (href_list["race"] in valid_species))
			var/datum/species/S = GLOB.all_species[href_list["race"]]
			if(owner.set_species(S.type))
				cut_and_generate_data()
				// Species change creates new organs - runtimes ahoy if we forget this
				head_organ = owner.get_organ("head")
				return 1
	if(href_list["gender"])
		if(can_change(APPEARANCE_GENDER))
			if(owner.change_gender(href_list["gender"]))
				cut_and_generate_data()
				return 1
	if(href_list["skin_tone"])
		if(can_change_skin_tone())
			var/new_s_tone = null
			if(owner.dna.species.bodyflags & HAS_SKIN_TONE)
				new_s_tone = input(usr, "Choose your character's skin tone:\n(Light 1 - 220 Dark)", "Skin Tone", owner.s_tone) as num|null
				if(isnum(new_s_tone) && can_still_topic(state))
					new_s_tone = 35 - max(min(round(new_s_tone), 220),1)
			else if(owner.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
				var/const/MAX_LINE_ENTRIES = 4
				var/prompt = "Choose your character's skin tone: 1-[owner.dna.species.icon_skin_tones.len]\n("
				for(var/i = 1 to owner.dna.species.icon_skin_tones.len)
					if(i > MAX_LINE_ENTRIES && !((i - 1) % MAX_LINE_ENTRIES))
						prompt += "\n"
					prompt += "[i] = [owner.dna.species.icon_skin_tones[i]]"
					if(i != owner.dna.species.icon_skin_tones.len)
						prompt += ", "
				prompt += ")"

				new_s_tone = input(usr, prompt, "Skin Tone", owner.s_tone) as num|null
				if(isnum(new_s_tone) && can_still_topic(state))
					new_s_tone = max(min(round(new_s_tone), owner.dna.species.icon_skin_tones.len), 1)

			if(new_s_tone)
				return owner.change_skin_tone(new_s_tone)
	if(href_list["skin_color"])
		if(can_change_skin_color())
			var/new_skin = input(usr, "Choose your character's skin colour: ", "Skin Color", owner.skin_colour) as color|null
			if(new_skin && can_still_topic(state) && owner.change_skin_color(new_skin))
				update_dna()
				return 1
	if(href_list["hair"])
		if(can_change(APPEARANCE_HAIR) && (href_list["hair"] in valid_hairstyles))
			if(owner.change_hair(href_list["hair"]))
				update_dna()
				return 1
	if(href_list["hair_color"])
		if(can_change(APPEARANCE_HAIR_COLOR))
			var/new_hair = input("Please select hair color.", "Hair Color", head_organ.hair_colour) as color|null
			if(new_hair && can_still_topic(state) && owner.change_hair_color(new_hair))
				update_dna()
				return 1
	if(href_list["secondary_hair_color"])
		if(can_change(APPEARANCE_SECONDARY_HAIR_COLOR))
			var/new_hair = input("Please select secondary hair color.", "Secondary Hair Color", head_organ.sec_hair_colour) as color|null
			if(new_hair && can_still_topic(state) && owner.change_hair_color(new_hair, 1))
				update_dna()
				return 1
	if(href_list["facial_hair"])
		if(can_change(APPEARANCE_FACIAL_HAIR) && (href_list["facial_hair"] in valid_facial_hairstyles))
			if(owner.change_facial_hair(href_list["facial_hair"]))
				update_dna()
				return 1
	if(href_list["facial_hair_color"])
		if(can_change(APPEARANCE_FACIAL_HAIR_COLOR))
			var/new_facial = input("Please select facial hair color.", "Facial Hair Color", head_organ.facial_colour) as color|null
			if(new_facial && can_still_topic(state) && owner.change_facial_hair_color(new_facial))
				update_dna()
				return 1
	if(href_list["secondary_facial_hair_color"])
		if(can_change(APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR))
			var/new_facial = input("Please select secondary facial hair color.", "Secondary Facial Hair Color", head_organ.sec_facial_colour) as color|null
			if(new_facial && can_still_topic(state) && owner.change_facial_hair_color(new_facial, 1))
				update_dna()
				return 1
	if(href_list["eye_color"])
		if(can_change(APPEARANCE_EYE_COLOR))
			var/obj/item/organ/internal/eyes/eyes_organ = owner.get_int_organ(/obj/item/organ/internal/eyes)
			var/new_eyes = input("Please select eye color.", "Eye Color", eyes_organ.eye_colour) as color|null
			if(new_eyes && can_still_topic(state) && owner.change_eye_color(new_eyes))
				update_dna()
				return 1
	if(href_list["head_accessory"])
		if(can_change_head_accessory() && (href_list["head_accessory"] in valid_head_accessories))
			if(owner.change_head_accessory(href_list["head_accessory"]))
				update_dna()
				return 1
	if(href_list["head_accessory_color"])
		if(can_change_head_accessory())
			var/new_head_accessory = input("Please select head accessory color.", "Head Accessory Color", head_organ.headacc_colour) as color|null
			if(new_head_accessory && can_still_topic(state) && owner.change_head_accessory_color(new_head_accessory))
				update_dna()
				return 1
	if(href_list["head_marking"])
		if(can_change_markings("head") && (href_list["head_marking"] in valid_head_marking_styles))
			if(owner.change_markings(href_list["head_marking"], "head"))
				update_dna()
				return 1
	if(href_list["head_marking_color"])
		if(can_change_markings("head"))
			var/new_markings = input("Please select head marking color.", "Marking Color", owner.m_colours["head"]) as color|null
			if(new_markings && can_still_topic(state) && owner.change_marking_color(new_markings, "head"))
				update_dna()
				return 1
	if(href_list["body_marking"])
		if(can_change_markings("body") && (href_list["body_marking"] in valid_body_marking_styles))
			if(owner.change_markings(href_list["body_marking"], "body"))
				update_dna()
				return 1
	if(href_list["body_marking_color"])
		if(can_change_markings("body"))
			var/new_markings = input("Please select body marking color.", "Marking Color", owner.m_colours["body"]) as color|null
			if(new_markings && can_still_topic(state) && owner.change_marking_color(new_markings, "body"))
				update_dna()
				return 1
	if(href_list["tail_marking"])
		if(can_change_markings("tail") && (href_list["tail_marking"] in valid_tail_marking_styles))
			if(owner.change_markings(href_list["tail_marking"], "tail"))
				update_dna()
				return 1
	if(href_list["tail_marking_color"])
		if(can_change_markings("tail"))
			var/new_markings = input("Please select tail marking color.", "Marking Color", owner.m_colours["tail"]) as color|null
			if(new_markings && can_still_topic(state) && owner.change_marking_color(new_markings, "tail"))
				update_dna()
				return 1
	if(href_list["body_accessory"])
		if(can_change_body_accessory() && (href_list["body_accessory"] in valid_body_accessories))
			if(owner.change_body_accessory(href_list["body_accessory"]))
				update_dna()
				cut_and_generate_data()
				return 1
	if(href_list["alt_head"])
		if(can_change_alt_head() && (href_list["alt_head"] in valid_alt_head_styles))
			if(owner.change_alt_head(href_list["alt_head"]))
				update_dna()
				head_organ = owner.get_organ("head") //Update the head with the new information.
				cut_and_generate_data()
				return 1

	return 0

/datum/nano_module/appearance_changer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "appearance_changer.tmpl", "[src]", 800, 450, state = state)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/appearance_changer/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	generate_data(check_whitelist, whitelist, blacklist)
	var/data[0]

	data["specimen"] = owner.dna.species.name
	data["gender"] = owner.gender
	data["has_gender"] = owner.dna.species.has_gender
	data["change_race"] = can_change(APPEARANCE_RACE)
	if(data["change_race"])
		var/species[0]
		for(var/specimen in valid_species)
			species[++species.len] =	list("specimen" = specimen)
		data["species"] = species

	data["change_gender"] = can_change(APPEARANCE_GENDER)
	data["change_skin_tone"] = can_change_skin_tone()
	data["change_skin_color"] = can_change_skin_color()
	data["change_eye_color"] = can_change(APPEARANCE_EYE_COLOR)
	data["change_head_accessory"] = can_change_head_accessory()
	if(data["change_head_accessory"])
		var/head_accessory_styles[0]
		for(var/head_accessory_style in valid_head_accessories)
			head_accessory_styles[++head_accessory_styles.len] = list("headaccessorystyle" = head_accessory_style)
		data["head_accessory_styles"] = head_accessory_styles
		data["head_accessory_style"] = (head_organ ? head_organ.ha_style : "None")

	data["change_hair"] = can_change(APPEARANCE_HAIR)
	if(data["change_hair"])
		var/hair_styles[0]
		for(var/hair_style in valid_hairstyles)
			hair_styles[++hair_styles.len] = list("hairstyle" = hair_style)
		data["hair_styles"] = hair_styles
		data["hair_style"] = (head_organ ? head_organ.h_style : "Skinhead")

	data["change_facial_hair"] = can_change(APPEARANCE_FACIAL_HAIR)
	if(data["change_facial_hair"])
		var/facial_hair_styles[0]
		for(var/facial_hair_style in valid_facial_hairstyles)
			facial_hair_styles[++facial_hair_styles.len] = list("facialhairstyle" = facial_hair_style)
		data["facial_hair_styles"] = facial_hair_styles
		data["facial_hair_style"] = (head_organ ? head_organ.f_style : "Shaved")

	data["change_head_markings"] = can_change_markings("head")
	if(data["change_head_markings"])
		var/m_style = owner.m_styles["head"]
		var/head_marking_styles[0]
		for(var/head_marking_style in valid_head_marking_styles)
			head_marking_styles[++head_marking_styles.len] = list("headmarkingstyle" = head_marking_style)
		data["head_marking_styles"] = head_marking_styles
		data["head_marking_style"] = m_style

	data["change_body_markings"] = can_change_markings("body")
	if(data["change_body_markings"])
		var/m_style = owner.m_styles["body"]
		var/body_marking_styles[0]
		for(var/body_marking_style in valid_body_marking_styles)
			body_marking_styles[++body_marking_styles.len] = list("bodymarkingstyle" = body_marking_style)
		data["body_marking_styles"] = body_marking_styles
		data["body_marking_style"] = m_style

	data["change_tail_markings"] = can_change_markings("tail")
	if(data["change_tail_markings"])
		var/m_style = owner.m_styles["tail"]
		var/tail_marking_styles[0]
		for(var/tail_marking_style in valid_tail_marking_styles)
			tail_marking_styles[++tail_marking_styles.len] = list("tailmarkingstyle" = tail_marking_style)
		data["tail_marking_styles"] = tail_marking_styles
		data["tail_marking_style"] = m_style

	data["change_body_accessory"] = can_change_body_accessory()
	if(data["change_body_accessory"])
		var/body_accessory_styles[0]
		for(var/body_accessory_style in valid_body_accessories)
			body_accessory_styles[++body_accessory_styles.len] = list("bodyaccessorystyle" = body_accessory_style)
		data["body_accessory_styles"] = body_accessory_styles
		data["body_accessory_style"] = (owner.body_accessory ? owner.body_accessory.name : "None")

	data["change_alt_head"] = can_change_alt_head()
	if(data["change_alt_head"])
		var/alt_head_styles[0]
		for(var/alt_head_style in valid_alt_head_styles)
			alt_head_styles[++alt_head_styles.len] = list("altheadstyle" = alt_head_style)
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

/datum/nano_module/appearance_changer/proc/update_dna()
	if(owner && (flags & APPEARANCE_UPDATE_DNA))
		owner.update_dna()

/datum/nano_module/appearance_changer/proc/can_change(var/flag)
	return owner && (flags & flag)

/datum/nano_module/appearance_changer/proc/can_change_skin_tone()
	return owner && (flags & APPEARANCE_SKIN) && ((owner.dna.species.bodyflags & HAS_SKIN_TONE) || (owner.dna.species.bodyflags & HAS_ICON_SKIN_TONE))

/datum/nano_module/appearance_changer/proc/can_change_skin_color()
	return owner && (flags & APPEARANCE_SKIN) && (owner.dna.species.bodyflags & HAS_SKIN_COLOR)

/datum/nano_module/appearance_changer/proc/can_change_head_accessory()
	if(!head_organ)
		log_runtime(EXCEPTION("Missing head!"), owner)
		return 0
	return owner && (flags & APPEARANCE_HEAD_ACCESSORY) && (head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)

/datum/nano_module/appearance_changer/proc/can_change_markings(var/location = "body")
	var/marking_flag = HAS_BODY_MARKINGS
	var/body_flags = owner.dna.species.bodyflags
	if(location == "head")
		if(!head_organ)
			log_debug("Missing head!")
			return 0
		body_flags = head_organ.dna.species.bodyflags
		marking_flag = HAS_HEAD_MARKINGS
	if(location == "body")
		marking_flag = HAS_BODY_MARKINGS
	if(location == "tail")
		marking_flag = HAS_TAIL_MARKINGS

	return owner && (flags & APPEARANCE_MARKINGS) && (body_flags & marking_flag)

/datum/nano_module/appearance_changer/proc/can_change_body_accessory()
	return owner && (flags & APPEARANCE_BODY_ACCESSORY) && (owner.dna.species.bodyflags & HAS_TAIL)

/datum/nano_module/appearance_changer/proc/can_change_alt_head()
	if(!head_organ)
		log_debug("Missing head!")
		return 0
	return owner && (flags & APPEARANCE_ALT_HEAD) && (head_organ.dna.species.bodyflags & HAS_ALT_HEADS)

/datum/nano_module/appearance_changer/proc/cut_and_generate_data()
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

/datum/nano_module/appearance_changer/proc/generate_data()
	if(!owner)
		return
	if(!valid_species.len)
		valid_species = owner.generate_valid_species(check_whitelist, whitelist, blacklist)
	if(!valid_hairstyles.len || !valid_facial_hairstyles.len)
		valid_hairstyles = owner.generate_valid_hairstyles()
		valid_facial_hairstyles = owner.generate_valid_facial_hairstyles()
	if(!valid_head_accessories.len)
		valid_head_accessories = owner.generate_valid_head_accessories()
	if(!valid_head_marking_styles.len)
		valid_head_marking_styles = owner.generate_valid_markings("head")
	if(!valid_body_marking_styles.len)
		valid_body_marking_styles = owner.generate_valid_markings("body")
	if(!valid_tail_marking_styles.len)
		valid_tail_marking_styles = owner.generate_valid_markings("tail")
	if(!valid_body_accessories.len)
		valid_body_accessories = owner.generate_valid_body_accessories()
	if(!valid_alt_head_styles.len)
		valid_alt_head_styles = owner.generate_valid_alt_heads()
