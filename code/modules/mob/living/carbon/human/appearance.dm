/mob/living/carbon/human/proc/change_appearance(flags = APPEARANCE_ALL_HAIR, datum/location = src, mob/user = src, check_species_whitelist = TRUE, list/species_whitelist = list(), list/species_blacklist = list())
	var/datum/ui_module/appearance_changer/AC = new(location, src, check_species_whitelist, species_whitelist, species_blacklist)
	AC.flags = flags
	AC.ui_interact(user)

/mob/living/carbon/human/proc/change_gender(new_gender, update_dna = TRUE)
	if(gender == new_gender)
		return

	gender = new_gender

	if(update_dna)
		update_dna()
	sync_organ_dna(assimilate = FALSE)
	update_body()
	return TRUE

/mob/living/carbon/human/proc/change_body_type(new_body, update_dna = TRUE)
	if(!new_body || new_body == body_type)
		return

	body_type = new_body

	if(update_dna)
		update_dna()
	sync_organ_dna(FALSE)
	update_body(TRUE)

/mob/living/carbon/human/proc/change_hair(hair_style, fluff)
	var/obj/item/organ/external/head/H = get_organ("head")

	if(!hair_style || !H || H.h_style == hair_style)
		return
	if(!(fluff || (hair_style in GLOB.hair_styles_public_list)))
		return

	H.h_style = hair_style

	update_hair()
	update_inv_glasses()
	return TRUE

/mob/living/carbon/human/proc/change_facial_hair(facial_hair_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!facial_hair_style || !H || H.f_style == facial_hair_style || !(facial_hair_style in GLOB.facial_hair_styles_list))
		return

	H.f_style = facial_hair_style

	update_fhair()
	return TRUE

/mob/living/carbon/human/proc/change_head_accessory(head_accessory_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!head_accessory_style || !H || H.ha_style == head_accessory_style || !(head_accessory_style in GLOB.head_accessory_styles_list))
		return
	if(SEND_SIGNAL(src, COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY, head_accessory_style) & COMSIG_HUMAN_NO_CHANGE_APPEARANCE)
		return FALSE

	H.ha_style = head_accessory_style

	update_head_accessory()
	return TRUE

/mob/living/carbon/human/proc/change_markings(marking_style, location = "body")
	if(!marking_style || m_styles[location] == marking_style || !(marking_style in GLOB.marking_styles_list))
		return

	var/datum/sprite_accessory/body_markings/marking = GLOB.marking_styles_list[marking_style]
	if(marking.name != "None" && marking.marking_location != location)
		return

	var/obj/item/organ/external/head/head_organ = get_organ("head")
	if(location == "head")
		if(!head_organ)
			return

		if(head_organ.alt_head && head_organ.alt_head != "None")
			var/datum/sprite_accessory/body_markings/head/H = GLOB.marking_styles_list[marking_style]
			if(marking.name != "None" && (!H.heads_allowed || (!("All" in H.heads_allowed) && !(head_organ.alt_head in H.heads_allowed))))
				return
		else
			if(!head_organ.alt_head || head_organ.alt_head == "None")
				head_organ.alt_head = "None"
				var/datum/sprite_accessory/body_markings/head/H = GLOB.marking_styles_list[marking_style]
				if(H.heads_allowed && !("All" in H.heads_allowed))
					return

	if(location == "tail" && marking.name != "None")
		var/datum/sprite_accessory/body_markings/tail/tail_marking = GLOB.marking_styles_list[marking_style]
		if(!body_accessory)
			if(tail_marking.tails_allowed)
				return
		else
			if(!tail_marking.tails_allowed || !(body_accessory.name in tail_marking.tails_allowed))
				return

	m_styles[location] = marking_style

	if(location == "tail")
		stop_tail_wagging()
	else
		update_markings()
	return TRUE

/mob/living/carbon/human/proc/change_body_accessory(body_accessory_style)
	var/found
	if(!body_accessory_style || (body_accessory && body_accessory.name == body_accessory_style))
		return
	if(SEND_SIGNAL(src, COMSIG_HUMAN_CHANGE_BODY_ACCESSORY, body_accessory_style) & COMSIG_HUMAN_NO_CHANGE_APPEARANCE)
		return FALSE

	for(var/B in GLOB.body_accessory_by_name)
		if(B == body_accessory_style)
			body_accessory = GLOB.body_accessory_by_name[body_accessory_style]
			found = TRUE

	if(!found)
		return

	m_styles["tail"] = "None"
	update_tail_layer()
	update_wing_layer()
	return TRUE

/mob/living/carbon/human/proc/change_alt_head(alternate_head)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H || H.alt_head == alternate_head || H.is_robotic() || (!(dna.species.bodyflags & HAS_ALT_HEADS) && alternate_head != "None") || !(alternate_head in GLOB.alt_heads_list))
		return

	H.alt_head = alternate_head

	//Handle head markings if they're incompatible with the new alt head.
	if(m_styles["head"])
		var/head_marking = m_styles["head"]
		var/datum/sprite_accessory/body_markings/head/head_marking_style = GLOB.marking_styles_list[head_marking]
		if(!head_marking_style.heads_allowed || (!("All" in head_marking_style.heads_allowed) && !(H.alt_head in head_marking_style.heads_allowed)))
			m_styles["head"] = "None"
			update_markings()

	update_body(TRUE) //Update the body and force limb icon regeneration to update the head with the new icon.
	if(wear_mask)
		update_inv_wear_mask()
	return TRUE

/mob/living/carbon/human/proc/reset_hair()
	reset_head_hair()
	reset_facial_hair()
	reset_head_accessory()
	if(m_styles["head"] && m_styles["head"] != "None") //Resets head markings.
		reset_markings("head")

/mob/living/carbon/human/proc/reset_head_hair()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return
	var/list/valid_hairstyles = generate_valid_hairstyles()
	if(length(valid_hairstyles))
		H.h_style = pick(valid_hairstyles)
	else
		//this shouldn't happen
		H.h_style = "Bald"
	// Gradient
	H.h_grad_style = "None"
	H.h_grad_offset_x = 0
	H.h_grad_offset_y = 0
	H.h_grad_colour = "#000000"
	H.h_grad_alpha = 255

	update_hair()

/mob/living/carbon/human/proc/reset_facial_hair()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return
	var/list/valid_facial_hairstyles = generate_valid_facial_hairstyles()
	if(length(valid_facial_hairstyles))
		H.f_style = pick(valid_facial_hairstyles)
	else
		//this shouldn't happen
		H.f_style = "Shaved"
	update_fhair()

/mob/living/carbon/human/proc/reset_markings(location)
	var/list/valid_markings

	if(location)
		valid_markings = generate_valid_markings(location)
		if(length(valid_markings))
			m_styles[location] = pick(valid_markings)
		else
			//this shouldn't happen
			m_styles[location] = "None"
	else
		for(var/m_location in list("head", "body", "tail"))
			valid_markings = generate_valid_markings(m_location)
			if(length(valid_markings))
				m_styles[m_location] = pick(valid_markings)
			else
				//this shouldn't happen
				m_styles[m_location] = "None"

	update_markings()
	stop_tail_wagging()

/mob/living/carbon/human/proc/reset_head_accessory()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return
	var/list/valid_head_accessories = generate_valid_head_accessories()
	if(length(valid_head_accessories))
		H.ha_style = pick(valid_head_accessories)
	else
		//this shouldn't happen
		H.ha_style = "None"
	update_head_accessory()

/mob/living/carbon/human/proc/change_eye_color(colour = "#000000", update_dna = TRUE, skip_icons = FALSE)
	// Update the main DNA datum, then sync the change across the organs
	var/obj/item/organ/internal/eyes/eyes_organ = get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes_organ)
		if(colour == eyes_organ.eye_color)
			return

		eyes_organ.eye_color = colour
		dna.eye_color_to_dna(eyes_organ)
		eyes_organ.set_dna(dna)

	if(update_dna)
		update_dna()

	sync_organ_dna(assimilate = FALSE)
	if(!skip_icons)
		update_eyes()
		update_body()
	return TRUE

/mob/living/carbon/human/get_runechat_color()
	if(!dna) // Check for DNA in the case we somehow don't have a DNA set for this human.
		return ..()
	return dna.chat_color

/mob/living/carbon/human/proc/change_runechat_color(colour = "#000000")
	if(!dna)
		return
	if(colour == dna.chat_color)
		return
	dna.chat_color = colour
	update_dna()

/mob/living/carbon/human/proc/get_eye_color()
	var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
	if(E)
		return E.eye_color
	return FALSE

/mob/living/carbon/human/proc/change_hair_color(colour = "#000000", secondary)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(!secondary)
		if(colour == H.hair_colour)
			return

		H.hair_colour = colour
	else
		if(colour == H.sec_hair_colour)
			return

		H.sec_hair_colour = colour

	update_hair()
	return TRUE

/mob/living/carbon/human/proc/change_facial_hair_color(colour = "#000000", secondary)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(!secondary)
		if(colour == H.facial_colour)
			return

		H.facial_colour = colour
	else
		if(colour == H.sec_facial_colour)
			return

		H.sec_facial_colour = colour

	update_fhair()
	return TRUE

/mob/living/carbon/human/proc/change_head_accessory_color(colour = "#000000")
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(colour == H.headacc_colour)
		return

	H.headacc_colour = colour

	update_head_accessory()
	return TRUE

/mob/living/carbon/human/proc/change_marking_color(colour = "#000000", location = "body")
	if(colour == m_colours[location])
		return

	m_colours[location] = colour

	if(location == "tail")
		update_tail_layer()
	else
		update_markings()
	return TRUE


/mob/living/carbon/human/proc/change_skin_color(color = "#000000")
	if(!is_color_text(color) || color == skin_colour || !(dna.species.bodyflags & HAS_SKIN_COLOR))
		return

	skin_colour = color

	force_update_limbs()
	return TRUE

/// Tone must be between -185 and 220. commonly used in 1 to 220, see `random_skin_tone()` for species-specific values
/mob/living/carbon/human/proc/change_skin_tone(tone, override = FALSE)
	if(!isnum(tone) || !((dna.species.bodyflags & HAS_SKIN_TONE) || (dna.species.bodyflags & HAS_ICON_SKIN_TONE)))
		return

	if(tone in -185 to 220)
		if(dna.species.bodyflags & HAS_ICON_SKIN_TONE || override)
			s_tone = tone
		else
			s_tone = 35 - tone
		force_update_limbs()
		return TRUE

	CRASH("Skin tone values must be between -185 and 220!")

/mob/living/carbon/human/proc/change_hair_gradient(style, offset_raw, color, alpha)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(!isnull(style))
		H.h_grad_style = style
	if(!isnull(offset_raw))
		var/list/expl = splittext(offset_raw, ",")
		if(length(expl) == 2)
			H.h_grad_offset_x = clamp(text2num(expl[1]) || 0, -16, 16)
			H.h_grad_offset_y = clamp(text2num(expl[2]) || 0, -16, 16)
	if(!isnull(color))
		H.h_grad_colour = color
	if(!isnull(alpha))
		H.h_grad_alpha = clamp(alpha, 0, 255)

	update_hair()

/mob/living/carbon/human/proc/update_dna()
	check_dna()
	dna.ready_dna(src)
	SEND_SIGNAL(src, COMSIG_HUMAN_UPDATE_DNA)

/mob/living/carbon/human/proc/generate_valid_species(check_whitelist = TRUE, list/whitelist = list(), list/blacklist = list())
	var/list/valid_species = list()
	for(var/current_species_name in GLOB.all_species)
		if(check_whitelist && !check_rights(R_ADMIN, FALSE, src)) //If we're using the whitelist, make sure to check it!
			if(length(whitelist) && !(current_species_name in whitelist))
				continue
			if(length(blacklist) && (current_species_name in blacklist))
				continue
			if(!can_use_species(src, current_species_name))
				continue

		valid_species += current_species_name

	return sortTim(valid_species, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/generate_valid_hairstyles()
	var/list/valid_hairstyles = list()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no hair.

	for(var/hairstyle in GLOB.hair_styles_public_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_public_list[hairstyle]

		if(hairstyle == "Bald") //Just in case.
			valid_hairstyles += hairstyle
			continue
		if(H.dna.species.bodyflags & ALL_RPARTS) //If the user is a species who can have a robotic head...
			var/datum/robolimb/robohead = GLOB.all_robolimbs[H.model]
			if((H.dna.species.name in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_hairstyles += hairstyle //Give them their hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
					valid_hairstyles += hairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(H.dna.species.name in S.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
				valid_hairstyles += hairstyle

	return sortTim(valid_hairstyles, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/generate_valid_facial_hairstyles()
	var/list/valid_facial_hairstyles = list()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no hair.

	for(var/facialhairstyle in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]

		if(facialhairstyle == "Shaved") //Just in case.
			valid_facial_hairstyles += facialhairstyle
			continue
		if(H.dna.species.bodyflags & ALL_RPARTS) //If the user is a species who can have a robotic head...
			var/datum/robolimb/robohead = GLOB.all_robolimbs[H.model]
			if(H.dna.species.name in S.species_allowed) //If this is a facial hair style native to the user's species...
				if((H.dna.species.name in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
					valid_facial_hairstyles += facialhairstyle
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
					valid_facial_hairstyles += facialhairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(H.dna.species.name in S.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
				valid_facial_hairstyles += facialhairstyle

	return sortTim(valid_facial_hairstyles, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/generate_valid_head_accessories()
	var/list/valid_head_accessories = list()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no head accessory.

	for(var/head_accessory in GLOB.head_accessory_styles_list)
		var/datum/sprite_accessory/S = GLOB.head_accessory_styles_list[head_accessory]

		if(!(H.dna.species.name in S.species_allowed)) //If the user's head is not of a species the head accessory style allows, skip it. Otherwise, add it to the list.
			continue
		valid_head_accessories += head_accessory

	return sortTim(valid_head_accessories, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/generate_valid_markings(location = "body")
	var/list/valid_markings = list()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H && location == "head")
		return //No head, no head markings.

	for(var/marking in GLOB.marking_styles_list)
		var/datum/sprite_accessory/body_markings/S = GLOB.marking_styles_list[marking]
		if(S.name == "None")
			valid_markings += marking
			continue
		if(S.marking_location != location) //If the marking isn't for the location we desire, skip.
			continue
		if(!(dna.species.name in S.species_allowed)) //If the user is not of a species the marking style allows, skip it. Otherwise, add it to the list.
			continue
		if(location == "tail")
			if(!body_accessory)
				if(S.tails_allowed)
					continue
			else
				if(!S.tails_allowed || !(body_accessory.name in S.tails_allowed))
					continue
		if(location == "head")
			var/datum/sprite_accessory/body_markings/head/M = GLOB.marking_styles_list[S.name]
			if(H.dna.species.bodyflags & ALL_RPARTS) //If the user is a species that can have a robotic head...
				var/datum/robolimb/robohead = GLOB.all_robolimbs[H.model]
				if(!(S.models_allowed && (robohead.company in S.models_allowed))) //Make sure they don't get markings incompatible with their head.
					continue
			else if(H.alt_head && H.alt_head != "None") //If the user's got an alt head, validate markings for that head.
				if(!M.heads_allowed || (!("All" in M.heads_allowed) && !(H.alt_head in M.heads_allowed)))
					continue
			else
				if(M.heads_allowed && !("All" in M.heads_allowed))
					continue
		valid_markings += marking

	return sortTim(valid_markings, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/generate_valid_body_accessories()
	var/list/valid_body_accessories = list()
	for(var/B in GLOB.body_accessory_by_name)
		var/datum/body_accessory/A = GLOB.body_accessory_by_name[B]
		if(isnull(A))
			continue
		else if(check_rights(R_ADMIN, FALSE, src))
			valid_body_accessories = GLOB.body_accessory_by_name.Copy()
			break
		else if(dna.species.name in A.allowed_species) //If the user is not of a species the body accessory style allows, skip it. Otherwise, add it to the list.
			valid_body_accessories += B
	if(dna.species.optional_body_accessory)
		valid_body_accessories += "None"

	return sortTim(valid_body_accessories, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/generate_valid_alt_heads()
	var/list/valid_alt_heads = list()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no alt heads.
	valid_alt_heads["None"] = GLOB.alt_heads_list["None"] //The only null entry should be the "None" option, and there should always be a "None" option.
	for(var/alternate_head in GLOB.alt_heads_list)
		var/datum/sprite_accessory/alt_heads/head = GLOB.alt_heads_list[alternate_head]
		if(!(H.dna.species.name in head.species_allowed))
			continue

		valid_alt_heads += alternate_head

	return sortTim(valid_alt_heads, GLOBAL_PROC_REF(cmp_text_asc))

/mob/living/carbon/human/proc/get_blood_color()
	var/bloodcolor = "#A10808"
	var/list/b_data = get_blood_data(get_blood_id())
	if(b_data)
		bloodcolor = b_data["blood_color"]
	return bloodcolor
