/mob/living/carbon/human/proc/change_appearance(var/flags = APPEARANCE_ALL_HAIR, var/location = src, var/mob/user = src, var/check_species_whitelist = 1, var/list/species_whitelist = list(), var/list/species_blacklist = list(), var/datum/topic_state/state = default_state)
	var/datum/nano_module/appearance_changer/AC = new(location, src, check_species_whitelist, species_whitelist, species_blacklist)
	AC.flags = flags
	AC.ui_interact(user, state = state)

/mob/living/carbon/human/proc/change_species(var/new_species)
	if(!new_species)
		return

	if(species == new_species)
		return

	if(!(new_species in all_species))
		return

	set_species(new_species)
	reset_hair()
	return 1

/mob/living/carbon/human/proc/change_gender(var/gender, var/update_dna = 1)
	var/obj/item/organ/external/head/H = organs_by_name["head"]
	if(src.gender == gender)
		return

	src.gender = gender

	var/datum/sprite_accessory/hair/current_hair = hair_styles_list[H.h_style]
	if(current_hair.gender != NEUTER && current_hair.gender != src.gender)
		reset_head_hair()

	var/datum/sprite_accessory/hair/current_fhair = facial_hair_styles_list[H.f_style]
	if(current_fhair.gender != NEUTER && current_fhair.gender != src.gender)
		reset_facial_hair()

	if(update_dna)
		update_dna()
	sync_organ_dna(assimilate = 0)
	update_body()
	return 1

/mob/living/carbon/human/proc/change_hair(var/hair_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!hair_style)
		return

	if(H.h_style == hair_style)
		return

	if(!(hair_style in hair_styles_list))
		return

	H.h_style = hair_style

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair(var/facial_hair_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!facial_hair_style)
		return

	if(H.f_style == facial_hair_style)
		return

	if(!(facial_hair_style in facial_hair_styles_list))
		return

	H.f_style = facial_hair_style

	update_fhair()
	return 1

/mob/living/carbon/human/proc/change_head_accessory(var/head_accessory_style)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!head_accessory_style)
		return

	if(H.ha_style == head_accessory_style)
		return

	if(!(head_accessory_style in head_accessory_styles_list))
		return

	H.ha_style = head_accessory_style

	update_head_accessory()
	return 1

/mob/living/carbon/human/proc/change_markings(var/marking_style)
	if(!marking_style)
		return

	if(src.m_style == marking_style)
		return

	if(!(marking_style in marking_styles_list))
		return

	src.m_style = marking_style

	update_markings()
	return 1

/mob/living/carbon/human/proc/change_body_accessory(var/body_accessory_style)
	var/found
	if(!body_accessory_style)
		return

	if(src.body_accessory)
		if(src.body_accessory.name == body_accessory_style)
			return

	for(var/B in body_accessory_by_name)
		if(B == body_accessory_style)
			src.body_accessory = body_accessory_by_name[body_accessory_style]
			found = 1

	if(!found)
		return

	update_tail_layer()
	return 1

/mob/living/carbon/human/proc/reset_hair()
	reset_head_hair()
	reset_facial_hair()
	reset_head_accessory()
	if(m_style && m_style != "None") //Resets the markings if they were head markings.
		var/datum/sprite_accessory/marking_style = marking_styles_list[m_style]
		if(marking_style && marking_style.marking_location == "head")
			reset_markings()

/mob/living/carbon/human/proc/reset_head_hair()
	var/obj/item/organ/external/head/H = get_organ("head")
	var/list/valid_hairstyles = generate_valid_hairstyles()
	if(valid_hairstyles.len)
		H.h_style = pick(valid_hairstyles)
	else
		//this shouldn't happen
		H.h_style = "Bald"

	update_hair()

/mob/living/carbon/human/proc/reset_facial_hair()
	var/obj/item/organ/external/head/H = get_organ("head")
	var/list/valid_facial_hairstyles = generate_valid_facial_hairstyles()
	if(valid_facial_hairstyles.len)
		H.f_style = pick(valid_facial_hairstyles)
	else
		//this shouldn't happen
		H.f_style = "Shaved"
	update_fhair()

/mob/living/carbon/human/proc/reset_markings()
	var/list/valid_markings = generate_valid_markings()
	if(valid_markings.len)
		m_style = pick(valid_markings)
	else
		//this shouldn't happen
		m_style = "None"
	update_markings()

/mob/living/carbon/human/proc/reset_head_accessory()
	var/obj/item/organ/external/head/H = get_organ("head")
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

/mob/living/carbon/human/proc/change_hair_color(var/red, var/green, var/blue)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(red == H.r_hair && green == H.g_hair && blue == H.b_hair)
		return

	H.r_hair = red
	H.g_hair = green
	H.b_hair = blue

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair_color(var/red, var/green, var/blue)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(red == H.r_facial && green == H.g_facial && blue == H.b_facial)
		return

	H.r_facial = red
	H.g_facial = green
	H.b_facial = blue

	update_fhair()
	return 1

/mob/living/carbon/human/proc/change_head_accessory_color(var/red, var/green, var/blue)
	var/obj/item/organ/external/head/H = get_organ("head")
	if(red == H.r_headacc && green == H.g_headacc && blue == H.b_headacc)
		return

	H.r_headacc = red
	H.g_headacc = green
	H.b_headacc = blue

	update_head_accessory()
	return 1

/mob/living/carbon/human/proc/change_marking_color(var/red, var/green, var/blue)
	if(red == r_markings && green == g_markings && blue == b_markings)
		return

	r_markings = red
	g_markings = green
	b_markings = blue

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
	for(var/hairstyle in hair_styles_list)
		var/datum/sprite_accessory/S = hair_styles_list[hairstyle]

		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if(H.species.flags & ALL_RPARTS) //If the user is a species who can have a robotic head...
			var/datum/robolimb/robohead = all_robolimbs[H.model]
			if(!H)
				return
			if(H.species.name in S.species_allowed) //If this is a hairstyle native to the user's species...
				if(robohead.is_monitor && (robohead.company in S.models_allowed)) //Check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
					valid_hairstyles += hairstyle //Give them their hairstyles if they do.
					continue
				else //If they don't have the default head, they shouldn't be getting any hairstyles they wouldn't normally.
					continue
			else
				if(robohead.is_monitor) //If the hair style is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
					continue
				else
					if("Human" in S.species_allowed) //If the user has a robotic head and the hairstyle can fit humans, let them use it as a wig for their humanoid robot head.
						valid_hairstyles += hairstyle
					continue
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(!(H.species.name in S.species_allowed)) //If the user's head is not of a species the hair style allows, skip it. Otherwise, add it to the list.
				continue
			valid_hairstyles += hairstyle

	return valid_hairstyles

/mob/living/carbon/human/proc/generate_valid_facial_hairstyles()
	var/list/valid_facial_hairstyles = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	for(var/facialhairstyle in facial_hair_styles_list)
		var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]

		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if(H.species.flags & ALL_RPARTS) //If the user is a species who can have a robotic head...
			var/datum/robolimb/robohead = all_robolimbs[H.model]
			if(!H)
				continue // No head, no hair
			if(H.species.name in S.species_allowed) //If this is a facial hair style native to the user's species...
				if(robohead.is_monitor && (robohead.company in S.models_allowed)) //Check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
					valid_facial_hairstyles += facialhairstyle //Give them their facial hair styles if they do.
					continue
				else //If they don't have the default head, they shouldn't be getting any facial hair styles they wouldn't normally.
					continue
			else

				if(robohead.is_monitor) //If the facial hair style is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
					continue
				else
					if("Human" in S.species_allowed) //If the user has a robotic head and the facial hair style can fit humans, let them use it as a postiche for their humanoid robot head.
						valid_facial_hairstyles += facialhairstyle
					continue
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(!(H.species.name in S.species_allowed)) //If the user's head is not of a species the facial hair style allows, skip it. Otherwise, add it to the list.
				continue
			valid_facial_hairstyles += facialhairstyle

	return valid_facial_hairstyles

/mob/living/carbon/human/proc/generate_valid_head_accessories()
	var/list/valid_head_accessories = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	for(var/head_accessory in head_accessory_styles_list)
		var/datum/sprite_accessory/S = head_accessory_styles_list[head_accessory]

		if(!(H.species.name in S.species_allowed)) //If the user's head is not of a species the head accessory style allows, skip it. Otherwise, add it to the list.
			continue
		valid_head_accessories += head_accessory

	return valid_head_accessories

/mob/living/carbon/human/proc/generate_valid_markings()
	var/list/valid_markings = new()
	var/obj/item/organ/external/head/H = get_organ("head")
	for(var/marking in marking_styles_list)
		var/datum/sprite_accessory/S = marking_styles_list[marking]

		if(!(species.name in S.species_allowed)) //If the user's head is not of a species the marking style allows, skip it. Otherwise, add it to the list.
			continue
		if(H.species.flags & ALL_RPARTS) //If the user is a species that can have a robotic head...
			var/datum/robolimb/robohead = all_robolimbs[H.model]
			if(!(S.models_allowed && (robohead.company in S.models_allowed))) //Make sure they don't get markings incompatible with their head.
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
				valid_body_accessories += "None" //The only null entry should be the "None" option.
				continue
			if(!(species.name in A.allowed_species)) //If the user is not of a species the body accessory style allows, skip it. Otherwise, add it to the list.
				continue
			valid_body_accessories += B

	return valid_body_accessories
