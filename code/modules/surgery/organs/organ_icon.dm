var/global/list/limb_icon_cache = list()

/obj/item/organ/external/proc/compile_icon()
	// I do this so the head's overlays don't get obliterated
	for(var/child_i in child_icons)
		overlays -= child_i
	child_icons.Cut()
	 // This is a kludge, only one icon has more than one generation of children though.
	for(var/obj/item/organ/external/organ in contents)
		if(organ.children && organ.children.len)
			for(var/obj/item/organ/external/child in organ.children)
				overlays += child.mob_icon
				child_icons += child.mob_icon
		overlays += organ.mob_icon
		child_icons += organ.mob_icon

/obj/item/organ/external/proc/sync_colour_to_human(var/mob/living/carbon/human/H)
	if(status & ORGAN_ROBOT && !(species && species.name == "Machine")) //machine people get skin color
		return
	if(species && H.species && species.name != H.species.name)
		return
	if(dna.unique_enzymes != H.dna.unique_enzymes) // This isn't MY arm
		if(!(H.species.bodyflags & HAS_ICON_SKIN_TONE))
			sync_colour_to_dna()
			return
	if(!isnull(H.s_tone) && ((H.species.bodyflags & HAS_SKIN_TONE) || (H.species.bodyflags & HAS_ICON_SKIN_TONE)))
		s_col = null
		s_tone = H.s_tone
	if(H.species.bodyflags & HAS_SKIN_COLOR)
		s_tone = null
		s_col = list(H.r_skin, H.g_skin, H.b_skin)

/obj/item/organ/external/proc/sync_colour_to_dna()
	if(status & ORGAN_ROBOT)
		return
	if(!isnull(dna.GetUIValue(DNA_UI_SKIN_TONE)) && ((species.bodyflags & HAS_SKIN_TONE) || (species.bodyflags & HAS_ICON_SKIN_TONE)))
		s_col = null
		s_tone = dna.GetUIValue(DNA_UI_SKIN_TONE)
	if(species.flags & HAS_SKIN_COLOR)
		s_tone = null
		s_col = list(dna.GetUIValue(DNA_UI_SKIN_R), dna.GetUIValue(DNA_UI_SKIN_G), dna.GetUIValue(DNA_UI_SKIN_B))

/obj/item/organ/external/head/sync_colour_to_human(var/mob/living/carbon/human/H)
	..()
	var/obj/item/organ/internal/eyes/eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)//owner.internal_organs_by_name["eyes"]
	if(eyes) eyes.update_colour()

/obj/item/organ/external/head/remove()
	get_icon()
	..()

/obj/item/organ/external/head/get_icon()

	..()
	overlays.Cut()
	if(!owner)
		return
	var/obj/item/organ/external/head/H = owner.get_organ("head")

	if(species.has_organ["eyes"])
		var/obj/item/organ/internal/eyes/eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)//owner.internal_organs_by_name["eyes"]
		if(species.eyes)
			var/icon/eyes_icon = new/icon('icons/mob/human_face.dmi', species.eyes)
			if(eyes)
				eyes_icon.Blend(rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3]), ICON_ADD)
			else
				eyes_icon.Blend(rgb(128,0,0), ICON_ADD)
			mob_icon.Blend(eyes_icon, ICON_OVERLAY)
			overlays |= eyes_icon

	if(owner.lip_style && (species && (species.flags & HAS_LIPS)))
		var/icon/lip_icon = new/icon('icons/mob/human_face.dmi', "lips_[owner.lip_style]_s")
		overlays |= lip_icon
		mob_icon.Blend(lip_icon, ICON_OVERLAY)

	if(owner.m_style)
		var/datum/sprite_accessory/marking_style = marking_styles_list[owner.m_style]
		if(marking_style && marking_style.species_allowed && (species.name in marking_style.species_allowed) && marking_style.marking_location == "head")
			var/icon/markings_s = new/icon("icon" = marking_style.icon, "icon_state" = "[marking_style.icon_state]_s")
			if(marking_style.do_colouration)
				markings_s.Blend(rgb(owner.r_markings, owner.g_markings, owner.b_markings), ICON_ADD)
			overlays |= markings_s

	if(H.ha_style)
		var/datum/sprite_accessory/head_accessory_style = head_accessory_styles_list[H.ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed && (H.species.name in head_accessory_style.species_allowed))
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			if(head_accessory_style.do_colouration)
				head_accessory_s.Blend(rgb(H.r_headacc, H.g_headacc, H.b_headacc), ICON_ADD)
			overlays |= head_accessory_s

	if(H.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
		if(facial_hair_style && ((facial_hair_style.species_allowed && (H.species.name in facial_hair_style.species_allowed)) || (src.species.flags & ALL_RPARTS)))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(H.species.name == "Slime People") // I am el worstos
				facial_s.Blend(rgb(owner.r_skin, owner.g_skin, owner.b_skin, 160), ICON_AND)
			else if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)
			overlays |= facial_s

	if(H.h_style && !(owner.head && (owner.head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
		if(hair_style && ((H.species.name in hair_style.species_allowed) || (src.species.flags & ALL_RPARTS)))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(H.species.name == "Slime People") // I am el worstos
				hair_s.Blend(rgb(owner.r_skin, owner.g_skin, owner.b_skin, 160), ICON_AND)
			else if(hair_style.do_colouration)
				hair_s.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)
			overlays |= hair_s

	return mob_icon

/obj/item/organ/external/proc/get_icon(var/skeletal)

	var/gender
	if(force_icon)
		mob_icon = new /icon(force_icon, "[icon_name]")
		if(species && species.name == "Machine")	//snowflake for IPC's, sorry.
			if(s_col && s_col.len >= 3)
				mob_icon.Blend(rgb(s_col[1], s_col[2], s_col[3]), ICON_ADD)
	else
		if(!dna)
			mob_icon = new /icon('icons/mob/human_races/r_human.dmi', "[icon_name][gendered_icon ? "_f" : ""]")
		else

			if(gendered_icon)
				if(dna.GetUIState(DNA_UI_GENDER))
					gender = "f"
				else
					gender = "m"

			if(skeletal)
				mob_icon = new /icon('icons/mob/human_races/r_skeleton.dmi', "[icon_name][gender ? "_[gender]" : ""]")
			else if(status & ORGAN_ROBOT)
				mob_icon = new /icon('icons/mob/human_races/robotic.dmi', "[icon_name][gender ? "_[gender]" : ""]")
			else
				if (status & ORGAN_MUTATED)
					mob_icon = new /icon(species.deform, "[icon_name][gender ? "_[gender]" : ""]")
				else
					mob_icon = new /icon(species.icobase, "[icon_name][gender ? "_[gender]" : ""]")

				if(status & ORGAN_DEAD)
					mob_icon.ColorTone(rgb(10,50,0))
					mob_icon.SetIntensity(0.7)

				if(!isnull(s_tone))
					if(s_tone >= 0)
						mob_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
					else
						mob_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
				else if(s_col && s_col.len >= 3)
					mob_icon.Blend(rgb(s_col[1], s_col[2], s_col[3]), ICON_ADD)

	dir = EAST
	icon = mob_icon

	return mob_icon

// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
/obj/item/organ/external/update_icon()
	var/n_is = damage_state_text()
	if (n_is != damage_state)
		damage_state = n_is
		return 1
	return 0
