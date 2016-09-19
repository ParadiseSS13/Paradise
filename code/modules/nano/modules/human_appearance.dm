/datum/nano_module/appearance_changer
	name = "Appearance Editor"
	var/flags = APPEARANCE_ALL_HAIR
	var/mob/living/carbon/human/owner = null
	var/obj/item/organ/external/head/head_organ = null
	var/list/valid_species = list()
	var/list/valid_hairstyles = list()
	var/list/valid_facial_hairstyles = list()
	var/list/valid_head_accessories = list()
	var/list/valid_marking_styles = list()
	var/list/valid_body_accessories = list()

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
			if(owner.change_species(href_list["race"]))
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
			if(owner.species.bodyflags & HAS_SKIN_TONE)
				new_s_tone = input(usr, "Choose your character's skin tone:\n(Light 1 - 220 Dark)", "Skin Tone", owner.s_tone) as num|null
				if(isnum(new_s_tone) && can_still_topic(state))
					new_s_tone = 35 - max(min(round(new_s_tone), 220),1)
			else if(owner.species.bodyflags & HAS_ICON_SKIN_TONE)
				var/const/MAX_LINE_ENTRIES = 4
				var/prompt = "Choose your character's skin tone: 1-[owner.species.icon_skin_tones.len]\n("
				for(var/i = 1; i <= owner.species.icon_skin_tones.len; i++)
					if(i > MAX_LINE_ENTRIES && !((i - 1) % MAX_LINE_ENTRIES))
						prompt += "\n"
					prompt += "[i] = [owner.species.icon_skin_tones[i]]"
					if(i != owner.species.icon_skin_tones.len)
						prompt += ", "
				prompt += ")"

				new_s_tone = input(usr, prompt, "Skin Tone", owner.s_tone) as num|null
				if(isnum(new_s_tone) && can_still_topic(state))
					new_s_tone = max(min(round(new_s_tone), owner.species.icon_skin_tones.len), 1)

			if(new_s_tone)
				return owner.change_skin_tone(new_s_tone)
	if(href_list["skin_color"])
		if(can_change_skin_color())
			var/new_skin = input(usr, "Choose your character's skin colour: ", "Skin Color", rgb(owner.r_skin, owner.g_skin, owner.b_skin)) as color|null
			if(new_skin && can_still_topic(state))
				var/r_skin = hex2num(copytext(new_skin, 2, 4))
				var/g_skin = hex2num(copytext(new_skin, 4, 6))
				var/b_skin = hex2num(copytext(new_skin, 6, 8))
				if(owner.change_skin_color(r_skin, g_skin, b_skin))
					update_dna()
					return 1
	if(href_list["hair"])
		if(can_change(APPEARANCE_HAIR) && (href_list["hair"] in valid_hairstyles))
			if(owner.change_hair(href_list["hair"]))
				update_dna()
				return 1
	if(href_list["hair_color"])
		if(can_change(APPEARANCE_HAIR_COLOR))
			var/new_hair = input("Please select hair color.", "Hair Color", rgb(head_organ.r_hair, head_organ.g_hair, head_organ.b_hair)) as color|null
			if(new_hair && can_still_topic(state))
				var/r_hair = hex2num(copytext(new_hair, 2, 4))
				var/g_hair = hex2num(copytext(new_hair, 4, 6))
				var/b_hair = hex2num(copytext(new_hair, 6, 8))
				if(owner.change_hair_color(r_hair, g_hair, b_hair))
					update_dna()
					return 1
	if(href_list["facial_hair"])
		if(can_change(APPEARANCE_FACIAL_HAIR) && (href_list["facial_hair"] in valid_facial_hairstyles))
			if(owner.change_facial_hair(href_list["facial_hair"]))
				update_dna()
				return 1
	if(href_list["facial_hair_color"])
		if(can_change(APPEARANCE_FACIAL_HAIR_COLOR))
			var/new_facial = input("Please select facial hair color.", "Facial Hair Color", rgb(head_organ.r_facial, head_organ.g_facial, head_organ.b_facial)) as color|null
			if(new_facial && can_still_topic(state))
				var/r_facial = hex2num(copytext(new_facial, 2, 4))
				var/g_facial = hex2num(copytext(new_facial, 4, 6))
				var/b_facial = hex2num(copytext(new_facial, 6, 8))
				if(owner.change_facial_hair_color(r_facial, g_facial, b_facial))
					update_dna()
					return 1
	if(href_list["eye_color"])
		if(can_change(APPEARANCE_EYE_COLOR))
			var/obj/item/organ/internal/eyes/eyes_organ = owner.get_int_organ(/obj/item/organ/internal/eyes)
			var/eyes_red = 0
			var/eyes_green = 0
			var/eyes_blue = 0
			if(eyes_organ)
				eyes_red = eyes_organ.eye_colour[1]
				eyes_green = eyes_organ.eye_colour[2]
				eyes_blue = eyes_organ.eye_colour[3]
			var/new_eyes = input("Please select eye color.", "Eye Color", rgb(eyes_red, eyes_green, eyes_blue)) as color|null
			if(new_eyes && can_still_topic(state))
				var/r_eyes = hex2num(copytext(new_eyes, 2, 4))
				var/g_eyes = hex2num(copytext(new_eyes, 4, 6))
				var/b_eyes = hex2num(copytext(new_eyes, 6, 8))
				if(owner.change_eye_color(r_eyes, g_eyes, b_eyes))
					update_dna()
					return 1
	if(href_list["head_accessory"])
		if(can_change_head_accessory() && (href_list["head_accessory"] in valid_head_accessories))
			if(owner.change_head_accessory(href_list["head_accessory"]))
				update_dna()
				return 1
	if(href_list["head_accessory_color"])
		if(can_change_head_accessory())
			var/new_head_accessory = input("Please select head accessory color.", "Head Accessory Color", rgb(head_organ.r_headacc, head_organ.g_headacc, head_organ.b_headacc)) as color|null
			if(new_head_accessory && can_still_topic(state))
				var/r_headacc = hex2num(copytext(new_head_accessory, 2, 4))
				var/g_headacc = hex2num(copytext(new_head_accessory, 4, 6))
				var/b_headacc = hex2num(copytext(new_head_accessory, 6, 8))
				if(owner.change_head_accessory_color(r_headacc, g_headacc, b_headacc))
					update_dna()
					return 1
	if(href_list["marking"])
		if(can_change_markings() && (href_list["marking"] in valid_marking_styles))
			if(owner.change_markings(href_list["marking"]))
				update_dna()
				return 1
	if(href_list["marking_color"])
		if(can_change_markings())
			var/new_markings = input("Please select marking color.", "Marking Color", rgb(owner.r_markings, owner.g_markings, owner.b_markings)) as color|null
			if(new_markings && can_still_topic(state))
				var/r_markings = hex2num(copytext(new_markings, 2, 4))
				var/g_markings = hex2num(copytext(new_markings, 4, 6))
				var/b_markings = hex2num(copytext(new_markings, 6, 8))
				if(owner.change_marking_color(r_markings, g_markings, b_markings))
					update_dna()
					return 1
	if(href_list["body_accessory"])
		if(can_change_body_accessory() && (href_list["body_accessory"] in valid_body_accessories))
			if(owner.change_body_accessory(href_list["body_accessory"]))
				update_dna()
				return 1

	return 0

/datum/nano_module/appearance_changer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	generate_data(check_whitelist, whitelist, blacklist)
	var/data[0]

	data["specimen"] = owner.species.name
	data["gender"] = owner.gender
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

	data["change_markings"] = can_change_markings()
	if(data["change_markings"])
		var/marking_styles[0]
		for(var/marking_style in valid_marking_styles)
			marking_styles[++marking_styles.len] = list("markingstyle" = marking_style)
		data["marking_styles"] = marking_styles
		data["marking_style"] = owner.m_style

	data["change_body_accessory"] = can_change_body_accessory()
	if(data["change_body_accessory"])
		var/body_accessory_styles[0]
		for(var/body_accessory_style in valid_body_accessories)
			body_accessory_styles[++body_accessory_styles.len] = list("bodyaccessorystyle" = body_accessory_style)
		data["body_accessory_styles"] = body_accessory_styles
		var/datum/body_accessory/BA
		if(owner.body_accessory)
			BA = owner.body_accessory.name
		data["body_accessory_style"] = BA

	data["change_head_accessory_color"] = can_change_head_accessory()
	data["change_hair_color"] = can_change(APPEARANCE_HAIR_COLOR)
	data["change_facial_hair_color"] = can_change(APPEARANCE_FACIAL_HAIR_COLOR)
	data["change_marking_color"] = can_change_markings()
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "appearance_changer.tmpl", "[src]", 800, 450, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/appearance_changer/proc/update_dna()
	if(owner && (flags & APPEARANCE_UPDATE_DNA))
		owner.update_dna()

/datum/nano_module/appearance_changer/proc/can_change(var/flag)
	return owner && (flags & flag)

/datum/nano_module/appearance_changer/proc/can_change_skin_tone()
	return owner && (flags & APPEARANCE_SKIN) && ((owner.species.bodyflags & HAS_SKIN_TONE) || (owner.species.bodyflags & HAS_ICON_SKIN_TONE))

/datum/nano_module/appearance_changer/proc/can_change_skin_color()
	return owner && (flags & APPEARANCE_SKIN) && (owner.species.bodyflags & HAS_SKIN_COLOR)

/datum/nano_module/appearance_changer/proc/can_change_head_accessory()
	if(!head_organ)
		log_runtime(EXCEPTION("Missing head!"), owner)
		return 0
	return owner && (flags & APPEARANCE_HEAD_ACCESSORY) && (head_organ.species.bodyflags & HAS_HEAD_ACCESSORY)

/datum/nano_module/appearance_changer/proc/can_change_markings()
	return owner && (flags & APPEARANCE_MARKINGS) && (owner.species.bodyflags & HAS_MARKINGS)

/datum/nano_module/appearance_changer/proc/can_change_body_accessory()
	return owner && (flags & APPEARANCE_BODY_ACCESSORY) && (owner.species.bodyflags & HAS_TAIL)

/datum/nano_module/appearance_changer/proc/cut_and_generate_data()
	// Making the assumption that the available species remain constant
	valid_hairstyles.Cut()
	valid_facial_hairstyles.Cut()
	valid_head_accessories.Cut()
	valid_marking_styles.Cut()
	valid_body_accessories.Cut()
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
	if(!valid_marking_styles.len)
		valid_marking_styles = owner.generate_valid_markings()
	if(!valid_body_accessories.len)
		valid_body_accessories = owner.generate_valid_body_accessories()
