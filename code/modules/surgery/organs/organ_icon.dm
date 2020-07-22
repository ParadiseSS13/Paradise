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
		if(dna.species && owner.dna.species && dna.species.name != owner.dna.species.name)
			return
		if(dna.unique_enzymes != owner.dna.unique_enzymes) // This isn't MY arm
			return

	icobase = new_icobase ? new_icobase : icobase
	deform	= new_deform ? new_deform : deform

/obj/item/organ/external/proc/sync_colour_to_human(var/mob/living/carbon/human/H)
	if(is_robotic() && !istype(dna.species, /datum/species/machine)) //machine people get skin color
		return
	if(dna.species && H.dna.species && dna.species.name != H.dna.species.name)
		return
	if(dna.unique_enzymes != H.dna.unique_enzymes) // This isn't MY arm
		if(!(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
			sync_colour_to_dna()
			return
	if(!isnull(H.s_tone) && ((H.dna.species.bodyflags & HAS_SKIN_TONE) || (H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)))
		s_col = null
		s_tone = H.s_tone
	if(H.dna.species.bodyflags & HAS_SKIN_COLOR)
		s_tone = null
		s_col = H.skin_colour
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/obj/item/organ/external/chest/C = H.get_organ("chest")
		change_organ_icobase(C.icobase, C.deform)

/obj/item/organ/external/proc/sync_colour_to_dna()
	if(is_robotic())
		return
	if(!isnull(dna.GetUIValue(DNA_UI_SKIN_TONE)) && ((dna.species.bodyflags & HAS_SKIN_TONE) || (dna.species.bodyflags & HAS_ICON_SKIN_TONE)))
		s_col = null
		s_tone = dna.GetUIValue(DNA_UI_SKIN_TONE)
	if(dna.species.bodyflags & HAS_SKIN_COLOR)
		s_tone = null
		s_col = rgb(dna.GetUIValue(DNA_UI_SKIN_R), dna.GetUIValue(DNA_UI_SKIN_G), dna.GetUIValue(DNA_UI_SKIN_B))

/obj/item/organ/external/head/sync_colour_to_human(var/mob/living/carbon/human/H)
	..()
	var/obj/item/organ/internal/eyes/eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)//owner.internal_bodyparts_by_name["eyes"]
	if(eyes) eyes.update_colour()

/obj/item/organ/external/head/remove(mob/living/user, ignore_children)
	get_icon()
	. = ..()

/obj/item/organ/external/proc/get_icon(skeletal, fat)
	// Kasparrov, you monster
	if(force_icon)
		mob_icon = new /icon(force_icon, "[icon_name]")
		if(istype(dna.species, /datum/species/machine)) //snowflake for IPC's, sorry.
			if(s_col)
				mob_icon.Blend(s_col, ICON_ADD)
	else
		var/new_icons = get_icon_state(skeletal)
		var/icon_file = new_icons[1]
		var/new_icon_state = new_icons[2]
		mob_icon = new /icon(icon_file, new_icon_state)
		if(!skeletal && !is_robotic())
			if(status & ORGAN_DEAD)
				mob_icon.ColorTone(rgb(10,50,0))
				mob_icon.SetIntensity(0.7)

			if(!isnull(s_tone))
				if(s_tone >= 0)
					mob_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
				else
					mob_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
			else if(s_col)
				mob_icon.Blend(s_col, ICON_ADD)

	if(owner) //Maintains overlays on disembodied parts.
		cut_overlays()

	dir = EAST
	icon = mob_icon

	return mob_icon

/obj/item/organ/external/head/get_icon()
	..()
	if(!owner)
		return

	if(dna.species.has_organ["eyes"])
		var/icon/eyes_icon = owner.get_eyecon()
		if(eyes_icon)
			mob_icon.Blend(eyes_icon, ICON_OVERLAY) //This is required since update_icons.dm relies on this proc to render non-shining eyes.
			add_overlay(eyes_icon)

	if(owner.lip_style && (LIPS in dna.species.species_traits))
		add_overlay(mutable_appearance('icons/mob/human_face.dmi', "lips_[owner.lip_style]_s")) //Hefty icon not necessary.

	var/head_marking = owner.m_styles["head"]
	if(head_marking)
		var/datum/sprite_accessory/head_marking_style = GLOB.marking_styles_list[head_marking]
		if(head_marking_style && head_marking_style.species_allowed && (dna.species.name in head_marking_style.species_allowed) && head_marking_style.marking_location == "head")
			var/icon/h_marking_s = new /icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
			if(head_marking_style.do_colouration)
				h_marking_s.Blend(owner.m_colours["head"], ICON_ADD)
			add_overlay(h_marking_s)

	if(!((owner.head && (owner.head.flags & BLOCKHAIR)) || (owner.wear_mask && (owner.wear_mask.flags & BLOCKHAIR)))) //Common restriction for all the below features.
		if(ha_style)
			var/datum/sprite_accessory/head_accessory_style = GLOB.head_accessory_styles_list[ha_style]
			if(head_accessory_style && head_accessory_style.species_allowed && (dna.species.name in head_accessory_style.species_allowed))
				var/icon/head_accessory_s = new /icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
				if(head_accessory_style.do_colouration)
					head_accessory_s.Blend(headacc_colour, ICON_ADD)
				add_overlay(head_accessory_s)

		if(f_style)
			var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
			if(facial_hair_style && ((facial_hair_style.species_allowed && (dna.species.name in facial_hair_style.species_allowed)) || (dna.species.bodyflags & ALL_RPARTS)))
				var/icon/facial_s = new /icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
				if(istype(dna.species, /datum/species/slime)) // I am el worstos
					facial_s.Blend("[owner.skin_colour]A0", ICON_AND) //A0 = 160 alpha.
				else if(facial_hair_style.do_colouration)
					facial_s.Blend(facial_colour, ICON_ADD)
				add_overlay(facial_s)

		if(h_style)
			if(!owner.isSynthetic() || (owner.isSynthetic() && ((owner.head && (owner.head.flags & BLOCKHEADHAIR)) || (owner.wear_mask && (owner.wear_mask.flags & BLOCKHEADHAIR)))))
				var/datum/sprite_accessory/hair_style = GLOB.hair_styles_full_list[h_style]
				if(hair_style && ((dna.species.name in hair_style.species_allowed) || (dna.species.bodyflags & ALL_RPARTS)))
					var/icon/hair_s = new /icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
					if(istype(dna.species, /datum/species/slime)) // I am el worstos
						hair_s.Blend("[owner.skin_colour]A0", ICON_AND) //A0 = 160 alpha.
					else if(hair_style.do_colouration)
						hair_s.Blend(hair_colour, ICON_ADD)
					add_overlay(hair_s)

	return mob_icon //Don't need to blend the above into this as it's handled in human/update_icons(). The overlays are for rendering stuff on disembodied heads.

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
		if(limb_name == "head")
			var/obj/item/organ/external/head/head_organ = src
			head_organ.handle_alt_icon()

		new_icon_state = "[icon_name][gender ? "_[gender]" : ""]"

		if(skeletal)
			icon_file = 'icons/mob/human_races/r_skeleton.dmi'
		else if(is_robotic())
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
	if(fat && !skeletal && !is_robotic() && (CAN_BE_FAT in dna.species.species_traits))
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
