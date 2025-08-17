// Обновление иконок для кастомных рас
/datum/character_save/update_preview_icon(for_observer=0)
	. = .. ()
	// Это ужасно,но так можно кастомным расам выдавать кастомные глаза (я хз, почему сработало так, нужны разьяснения)
	var/datum/species/selected_specie = GLOB.all_species[species]
	if(!istype(selected_specie, /datum/species/serpentid))
		return

	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)

	// Переменные взяты с оффов, обновил
	var/gender = "m"
	if(body_type == FEMALE)
		gender = "f"

	var/icon/icobase = selected_specie.icobase
	preview_icon = new /icon(icobase, "torso_[gender]")
	preview_icon.Blend(new /icon(icobase, "groin_[gender]"), ICON_OVERLAY)
	preview_icon.Blend(new /icon(icobase, "head_[gender]"), ICON_OVERLAY)
	for(var/name in list("chest", "groin", "head", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "l_arm", "l_hand"))
		if(organ_data[name] == "amputated")
			continue
		if(organ_data[name] == "cyborg")
			var/datum/robolimb/R
			if(rlimb_data[name]) R = GLOB.all_robolimbs[rlimb_data[name]]
			if(!R) R = GLOB.basic_robolimb
			if(name == "chest")
				name = "torso"
			preview_icon.Blend(icon(R.icon, "[name]"), ICON_OVERLAY) // This doesn't check gendered_icon. Not an issue while only limbs can be robotic.
			continue
		preview_icon.Blend(new /icon(icobase, "[name]"), ICON_OVERLAY)

	// Skin color
	if(selected_specie && (selected_specie.bodyflags & HAS_SKIN_COLOR))
		preview_icon.Blend(s_colour, ICON_ADD)

	// Skin tone
	if(selected_specie && (selected_specie.bodyflags & HAS_SKIN_TONE))
		if(s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	var/icon/face_s = new/icon("icon" = selected_specie.eyes_icon, "icon_state" = selected_specie.eyes)
	var/icon/eyes_s = new/icon("icon" = selected_specie.eyes_icon, "icon_state" = selected_specie ? selected_specie.eyes : "eyes_s")
	eyes_s.Blend(e_colour, ICON_ADD)
	face_s.Blend(eyes_s, ICON_OVERLAY)

	preview_icon.Blend(face_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)
