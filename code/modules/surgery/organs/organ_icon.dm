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

/obj/item/organ/external/proc/change_organ_icobase(var/new_icobase, var/new_deform, var/owner_sensitive) //Change the icobase/deform of this organ. If owner_sensitive is set, that means the proc won't mess with frankenstein limbs.
	if(owner_sensitive) //This and the below statements mean that the icobase/deform will only get updated if the limb is the same species as and is owned by the mob it's attached to.
		if(species && owner.species && species.name != owner.species.name)
			return
		if(dna.unique_enzymes != owner.dna.unique_enzymes) // This isn't MY arm
			return

	icobase = new_icobase ? new_icobase : icobase
	deform	= new_deform ? new_deform : deform

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
	if(H.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/obj/item/organ/external/chest/C = H.get_organ("chest")
		change_organ_icobase(C.icobase, C.deform)

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
	var/obj/item/organ/internal/eyes/eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)//owner.internal_bodyparts_by_name["eyes"]
	if(eyes) eyes.update_colour()

/obj/item/organ/external/head/remove()
	get_icon()
	. = ..()

/obj/item/organ/external/proc/get_icon(skeletal, fat)
	// Kasparrov, you monster
	if(istext(species))
		species = all_species[species]
	if(force_icon)
		mob_icon = new /icon(force_icon, "[icon_name]")
		if(species && species.name == "Machine") //snowflake for IPC's, sorry.
			if(s_col && s_col.len >= 3)
				mob_icon.Blend(rgb(s_col[1], s_col[2], s_col[3]), ICON_ADD)
	else
		var/new_icons = get_icon_state(skeletal)
		var/icon_file = new_icons[1]
		var/new_icon_state = new_icons[2]
		mob_icon = new /icon(icon_file, new_icon_state)
		if(!skeletal && !(status & ORGAN_ROBOT))
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

/obj/item/organ/external/head/get_icon()

	..()
	overlays.Cut()
	if(!owner)
		return

	if(species.has_organ["eyes"])
		var/obj/item/organ/internal/eyes/eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)
		var/obj/item/organ/internal/cyberimp/eyes/eye_implant = owner.get_int_organ(/obj/item/organ/internal/cyberimp/eyes)
		if(species.eyes)
			var/icon/eyes_icon = new/icon('icons/mob/human_face.dmi', species.eyes)
			if(eye_implant) // Eye implants override native DNA eye color
				eyes_icon.Blend(rgb(eye_implant.eye_colour[1],eye_implant.eye_colour[2],eye_implant.eye_colour[3]), ICON_ADD)
			else if(eyes)
				eyes_icon.Blend(rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3]), ICON_ADD)
			else
				eyes_icon.Blend(rgb(128,0,0), ICON_ADD)
			mob_icon.Blend(eyes_icon, ICON_OVERLAY)
			overlays |= eyes_icon

	if(owner.lip_style && (species && (species.flags & HAS_LIPS)))
		var/icon/lip_icon = new/icon('icons/mob/human_face.dmi', "lips_[owner.lip_style]_s")
		overlays |= lip_icon
		mob_icon.Blend(lip_icon, ICON_OVERLAY)

	var/head_marking = owner.m_styles["head"]
	if(head_marking && head_marking != "None")
		var/datum/sprite_accessory/head_marking_style = marking_styles_list[head_marking]
		if(head_marking_style && head_marking_style.species_allowed && (species.name in head_marking_style.species_allowed) && head_marking_style.marking_location == "head")
			var/icon/h_marking_s = new/icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
			if(head_marking_style.do_colouration)
				h_marking_s.Blend(owner.m_colours["head"], ICON_ADD)
			overlays |= h_marking_s

	if(ha_style)
		var/datum/sprite_accessory/head_accessory_style = head_accessory_styles_list[ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed && (species.name in head_accessory_style.species_allowed))
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			if(head_accessory_style.do_colouration)
				head_accessory_s.Blend(rgb(r_headacc, g_headacc, b_headacc), ICON_ADD)
			overlays |= head_accessory_s

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style && ((facial_hair_style.species_allowed && (species.name in facial_hair_style.species_allowed)) || (src.species.flags & ALL_RPARTS)))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(species.name == "Slime People") // I am el worstos
				facial_s.Blend(rgb(owner.r_skin, owner.g_skin, owner.b_skin, 160), ICON_AND)
			else if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			overlays |= facial_s

	if(h_style && !(owner.head && (owner.head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style && ((species.name in hair_style.species_allowed) || (src.species.flags & ALL_RPARTS)))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(species.name == "Slime People") // I am el worstos
				hair_s.Blend(rgb(owner.r_skin, owner.g_skin, owner.b_skin, 160), ICON_AND)
			else if(hair_style.do_colouration)
				hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			overlays |= hair_s

	return mob_icon

/obj/item/organ/external/proc/get_icon_state(skeletal)
	var/gender
	var/icon_file
	var/new_icon_state
	if(!dna)
		icon_file = 'icons/mob/human_races/r_human.dmi'
		new_icon_state = "[icon_name][gendered_icon ? "_f" : ""]"
	else
		if(gendered_icon)
			if(dna.GetUIState(DNA_UI_GENDER))
				gender = "f"
			else
				gender = "m"
		if(limb_name == "head" && !is_stump() && !(status & ORGAN_DESTROYED))
			var/obj/item/organ/external/head/head_organ = src
			head_organ.handle_alt_icon()

		new_icon_state = "[icon_name][gender ? "_[gender]" : ""]"

		if(skeletal)
			icon_file = 'icons/mob/human_races/r_skeleton.dmi'
		else if(status & ORGAN_ROBOT)
			icon_file = 'icons/mob/human_races/robotic.dmi'
		else
			if(status & ORGAN_MUTATED)
				icon_file = deform
			else
				// Congratulations, you are normal
				icon_file = icobase
	return list(icon_file, new_icon_state)

/obj/item/organ/external/chest/get_icon_state(skeletal)
	var/result = ..()
	if(fat && !skeletal && !(status & ORGAN_ROBOT) && (species.flags & CAN_BE_FAT))
		result[2] += "_fat"
	return result


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
/obj/item/organ/external/update_icon()
	var/n_is = damage_state_text()
	if(n_is != damage_state)
		damage_state = n_is
		return 1
	return 0
