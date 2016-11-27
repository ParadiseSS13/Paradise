/mob/living/carbon/human/proc/change_appearance(var/flags = APPEARANCE_ALL_HAIR, var/location = src, var/mob/user = src, var/check_species_whitelist = 1, var/list/species_whitelist = list(), var/list/species_blacklist = list(), var/datum/topic_state/state = default_state)
	var/datum/nano_module/appearance_changer/AC = new(location, src, check_species_whitelist, species_whitelist, species_blacklist)
	AC.flags = flags
	AC.ui_interact(user, state = state)

/mob/living/carbon/human/proc/change_species(var/new_species)
	if(!new_species || species == new_species || !(new_species in all_species))
		return

	set_species(new_species, null, 1)
	reset_hair()
	if(species.bodyflags & HAS_MARKINGS)
		reset_markings()

	return 1

/mob/living/carbon/human/proc/change_gender(var/new_gender, var/update_dna = 1)
	var/obj/item/organ/external/head/H = organs_by_name["head"]
	if(gender == new_gender)
		return

	gender = new_gender

	var/datum/sprite_accessory/hair/current_hair = hair_styles_list[H.h_style]
	if(current_hair.gender != NEUTER && current_hair.gender != gender)
		reset_head_hair()

	var/datum/sprite_accessory/hair/current_fhair = facial_hair_styles_list[H.f_style]
	if(current_fhair.gender != NEUTER && current_fhair.gender != gender)
		reset_facial_hair()

	if(update_dna)
		update_dna()
	sync_organ_dna(assimilate = 0)
	update_body()
	return 1

/mob/living/carbon/human/proc/change_hair(var/hair_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!hair_style || !H || H.h_style == hair_style || !(hair_style in hair_styles_list))
		return

	H.h_style = hair_style

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair(var/facial_hair_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!facial_hair_style || !H || H.f_style == facial_hair_style || !(facial_hair_style in facial_hair_styles_list))
		return

	H.f_style = facial_hair_style

	update_fhair()
	return 1

/mob/living/carbon/human/proc/change_head_accessory(var/head_accessory_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!head_accessory_style || !H || H.ha_style == head_accessory_style || !(head_accessory_style in head_accessory_styles_list))
		return

	H.ha_style = head_accessory_style

	update_head_accessory()
	return 1

/mob/living/carbon/human/proc/change_markings(var/marking_style, var/location = "body")
	if(!marking_style || m_styles[location] == marking_style || !(marking_style in marking_styles_list))
		return

	var/datum/sprite_accessory/body_markings/marking = marking_styles_list[marking_style]
	if(marking.name != "None" && marking.marking_location != location)
		return

	var/obj/item/organ/external/head/head_organ = get_organ("head")
	if(location == "head")
		if(!head_organ)
			return

		if(head_organ.alt_head && head_organ.alt_head != "None")
			var/datum/sprite_accessory/body_markings/head/H = marking_styles_list[marking_style]
			if(marking.name != "None" && (!H.heads_allowed || (!("All" in H.heads_allowed) && !(head_organ.alt_head in H.heads_allowed))))
				return
		else
			if(!head_organ.alt_head || head_organ.alt_head == "None")
				head_organ.alt_head = "None"
				var/datum/sprite_accessory/body_markings/head/H = marking_styles_list[marking_style]
				if(H.heads_allowed && !("All" in H.heads_allowed))
					return

	if(location == "tail" && marking.name != "None")
		var/datum/sprite_accessory/body_markings/tail/tail_marking = marking_styles_list[marking_style]
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
	return 1

/mob/living/carbon/human/proc/change_body_accessory(var/body_accessory_style)
	var/found
	if(!body_accessory_style || (body_accessory && body_accessory.name == body_accessory_style))
		return

	for(var/B in body_accessory_by_name)
		if(B == body_accessory_style)
			body_accessory = body_accessory_by_name[body_accessory_style]
			found = 1

	if(!found)
		return

	m_styles["tail"] = "None"
	update_tail_layer()
	return 1

/mob/living/carbon/human/proc/change_alt_head(var/alternate_head)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H || H.alt_head == alternate_head || (H.status & ORGAN_ROBOT) || (!(species.bodyflags & HAS_ALT_HEADS) && alternate_head != "None") || !(alternate_head in alt_heads_list))
		return

	H.alt_head = alternate_head

	//Handle head markings if they're incompatible with the new alt head.
	if(m_styles["head"])
		var/head_marking = m_styles["head"]
		var/datum/sprite_accessory/body_markings/head/head_marking_style = marking_styles_list[head_marking]
		if(!head_marking_style.heads_allowed || (!("All" in head_marking_style.heads_allowed) && !(H.alt_head in head_marking_style.heads_allowed)))
			m_styles["head"] = "None"
			update_markings()

	update_body(1, 1) //Update the body and force limb icon regeneration to update the head with the new icon.
	if(wear_mask)
		update_inv_wear_mask()
	return 1

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
	if(valid_hairstyles.len)
		H.h_style = pick(valid_hairstyles)
	else
		//this shouldn't happen
		H.h_style = "Bald"

	update_hair()

/mob/living/carbon/human/proc/reset_facial_hair()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return
	var/list/valid_facial_hairstyles = generate_valid_facial_hairstyles()
	if(valid_facial_hairstyles.len)
		H.f_style = pick(valid_facial_hairstyles)
	else
		//this shouldn't happen
		H.f_style = "Shaved"
	update_fhair()

/mob/living/carbon/human/proc/reset_markings(var/location)
	var/list/valid_markings

	if(location)
		valid_markings = generate_valid_markings(location)
		if(valid_markings.len)
			m_styles[location] = pick(valid_markings)
		else
			//this shouldn't happen
			m_styles[location] = "None"
	else
		for(var/m_location in list("head", "body", "tail"))
			valid_markings = generate_valid_markings(m_location)
			if(valid_markings.len)
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
	if(valid_head_accessories.len)
		H.ha_style = pick(valid_head_accessories)
	else
		//this shouldn't happen
		H.ha_style = "None"
	update_head_accessory()

/mob/living/carbon/human/proc/change_eye_color(var/red, var/green, var/blue, update_dna = 1)
	// Update the main DNA datum, then sync the change across the organs
	var/obj/item/organ/internal/eyes/eyes_organ = get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes_organ)
		var/eyes_red = eyes_organ.eye_colour[1]
		var/eyes_green = eyes_organ.eye_colour[2]
		var/eyes_blue = eyes_organ.eye_colour[3]
		if(red == eyes_red && green == eyes_green && blue == eyes_blue)
			return

		eyes_organ.eye_colour[1] = red
		eyes_organ.eye_colour[2] = green
		eyes_organ.eye_colour[3] = blue
		dna.eye_color_to_dna(eyes_organ)
		eyes_organ.set_dna(dna)

	if(update_dna)
		update_dna()
	sync_organ_dna(assimilate=0)
	update_eyes()
	update_body()
	return 1

/mob/living/carbon/human/proc/change_hair_color(var/red, var/green, var/blue, var/secondary)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(!secondary)
		if(red == H.r_hair && green == H.g_hair && blue == H.b_hair)
			return

		H.r_hair = red
		H.g_hair = green
		H.b_hair = blue
	else
		if(red == H.r_hair_sec && green == H.g_hair_sec && blue == H.b_hair_sec)
			return

		H.r_hair_sec = red
		H.g_hair_sec = green
		H.b_hair_sec = blue

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair_color(var/red, var/green, var/blue, var/secondary)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(!secondary)
		if(red == H.r_facial && green == H.g_facial && blue == H.b_facial)
			return

		H.r_facial = red
		H.g_facial = green
		H.b_facial = blue
	else
		if(red == H.r_facial_sec && green == H.g_facial_sec && blue == H.b_facial_sec)
			return

		H.r_facial_sec = red
		H.g_facial_sec = green
		H.b_facial_sec = blue

	update_fhair()
	return 1

/mob/living/carbon/human/proc/change_head_accessory_color(var/red, var/green, var/blue)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return

	if(red == H.r_headacc && green == H.g_headacc && blue == H.b_headacc)
		return

	H.r_headacc = red
	H.g_headacc = green
	H.b_headacc = blue

	update_head_accessory()
	return 1

/mob/living/carbon/human/proc/change_marking_color(var/colour, var/location = "body")
	if(colour == m_colours[location])
		return

	m_colours[location] = colour

	if(location == "tail")
		update_tail_layer()
	else
		update_markings()
	return 1


/mob/living/carbon/human/proc/change_skin_color(var/red, var/green, var/blue)
	if(red == r_skin && green == g_skin && blue == b_skin || !(species.bodyflags & HAS_SKIN_COLOR))
		return

	r_skin = red
	g_skin = green
	b_skin = blue

	force_update_limbs()
	update_body()
	return 1

/mob/living/carbon/human/proc/change_skin_tone(var/tone)
	if(s_tone == tone || !((species.bodyflags & HAS_SKIN_TONE) || (species.bodyflags & HAS_ICON_SKIN_TONE)))
		return

	s_tone = tone

	force_update_limbs()
	update_body()
	return 1

/mob/living/carbon/human/proc/update_dna()
	check_dna()
	dna.ready_dna(src)

/mob/living/carbon/human/proc/generate_valid_species(var/check_whitelist = 1, var/list/whitelist = list(), var/list/blacklist = list())
	var/list/valid_species = new()
	for(var/current_species_name in all_species)
		var/datum/species/current_species = all_species[current_species_name]

		if(check_whitelist && config.usealienwhitelist && !check_rights(R_ADMIN, 0, src)) //If we're using the whitelist, make sure to check it!
			if(whitelist.len && !(current_species_name in whitelist))
				continue
			if(blacklist.len && (current_species_name in blacklist))
				continue
			if((current_species.flags & IS_WHITELISTED) && !is_alien_whitelisted(src, current_species_name))
				continue

		valid_species += current_species_name

	return valid_species

/mob/living/carbon/human/proc/generate_valid_hairstyles()
	var/list/valid_hairstyles = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no hair.

	for(var/hairstyle in hair_styles_list)
		var/datum/sprite_accessory/S = hair_styles_list[hairstyle]

		if(hairstyle == "Bald") //Just in case.
			valid_hairstyles += hairstyle
			continue
		if((H.gender == MALE && S.gender == FEMALE) || (H.gender == FEMALE && S.gender == MALE))
			continue
		if(H.species.flags & ALL_RPARTS) //If the user is a species who can have a robotic head...
			var/datum/robolimb/robohead = all_robolimbs[H.model]
			if((H.species.name in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_hairstyles += hairstyle //Give them their hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
					valid_hairstyles += hairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(H.species.name in S.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
				valid_hairstyles += hairstyle

	return valid_hairstyles

/mob/living/carbon/human/proc/generate_valid_facial_hairstyles()
	var/list/valid_facial_hairstyles = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no hair.

	for(var/facialhairstyle in facial_hair_styles_list)
		var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]

		if(facialhairstyle == "Shaved") //Just in case.
			valid_facial_hairstyles += facialhairstyle
			continue
		if((H.gender == MALE && S.gender == FEMALE) || (H.gender == FEMALE && S.gender == MALE))
			continue
		if(H.species.flags & ALL_RPARTS) //If the user is a species who can have a robotic head...
			var/datum/robolimb/robohead = all_robolimbs[H.model]
			if(H.species.name in S.species_allowed) //If this is a facial hair style native to the user's species...
				if((H.species.name in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
					valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
					valid_facial_hairstyles += facialhairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(H.species.name in S.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
				valid_facial_hairstyles += facialhairstyle

	return valid_facial_hairstyles

/mob/living/carbon/human/proc/generate_valid_head_accessories()
	var/list/valid_head_accessories = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no head accessory.

	for(var/head_accessory in head_accessory_styles_list)
		var/datum/sprite_accessory/S = head_accessory_styles_list[head_accessory]

		if(!(H.species.name in S.species_allowed)) //If the user's head is not of a species the head accessory style allows, skip it. Otherwise, add it to the list.
			continue
		valid_head_accessories += head_accessory

	return valid_head_accessories

/mob/living/carbon/human/proc/generate_valid_markings(var/location = "body")
	var/list/valid_markings = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H && location == "head")
		return //No head, no head markings.

	for(var/marking in marking_styles_list)
		var/datum/sprite_accessory/body_markings/S = marking_styles_list[marking]
		if(S.name == "None")
			valid_markings += marking
			continue
		if(S.marking_location != location) //If the marking isn't for the location we desire, skip.
			continue
		if(!(species.name in S.species_allowed)) //If the user is not of a species the marking style allows, skip it. Otherwise, add it to the list.
			continue
		if(location == "tail")
			if(!body_accessory)
				if(S.tails_allowed)
					continue
			else
				if(!S.tails_allowed || !(body_accessory.name in S.tails_allowed))
					continue
		if(location == "head")
			var/datum/sprite_accessory/body_markings/head/M = marking_styles_list[S.name]
			if(H.species.flags & ALL_RPARTS)//If the user is a species that can have a robotic head...
				var/datum/robolimb/robohead = all_robolimbs[H.model]
				if(!(S.models_allowed && (robohead.company in S.models_allowed))) //Make sure they don't get markings incompatible with their head.
					continue
			else if(H.alt_head && H.alt_head != "None") //If the user's got an alt head, validate markings for that head.
				if(!M.heads_allowed || (!("All" in M.heads_allowed) && !(H.alt_head in M.heads_allowed)))
					continue
			else
				if(M.heads_allowed && !("All" in M.heads_allowed))
					continue
		valid_markings += marking

	return valid_markings

/mob/living/carbon/human/proc/generate_valid_body_accessories()
	var/list/valid_body_accessories = new()
	for(var/B in body_accessory_by_name)
		var/datum/body_accessory/A = body_accessory_by_name[B]
		if(check_rights(R_ADMIN, 0, src))
			valid_body_accessories = body_accessory_by_name.Copy()
		else
			if(!istype(A))
				valid_body_accessories["None"] = "None" //The only null entry should be the "None" option.
				continue
			if(species.name in A.allowed_species) //If the user is not of a species the body accessory style allows, skip it. Otherwise, add it to the list.
				valid_body_accessories += B

	return valid_body_accessories

/mob/living/carbon/human/proc/generate_valid_alt_heads()
	var/list/valid_alt_heads = list()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H)
		return //No head, no alt heads.
	valid_alt_heads["None"] = alt_heads_list["None"] //The only null entry should be the "None" option, and there should always be a "None" option.
	for(var/alternate_head in alt_heads_list)
		var/datum/sprite_accessory/alt_heads/head = alt_heads_list[alternate_head]
		if(!(H.species.name in head.species_allowed))
			continue

		valid_alt_heads += alternate_head

	return valid_alt_heads