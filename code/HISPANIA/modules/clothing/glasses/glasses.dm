/obj/item/clothing/glasses/welding/superior
	..()
	var/HUDType = DATA_HUD_DIAGNOSTIC
	var/itemequipped = FALSE
	var/on = FALSE

/obj/item/clothing/glasses/welding/superior/equipped(mob/living/carbon/human/user, slot)
	..()
	var/datum/atom_hud/H = huds[HUDType]
	if(slot == slot_glasses)
		if(!on)
			H.add_hud_to(user)
		else
			H.remove_hud_from(user)

/obj/item/clothing/glasses/welding/superior/item_action_slot_check(slot)
	var/mob/living/carbon/user = usr
	var/datum/atom_hud/H = huds[HUDType]
	if(slot == slot_glasses)
		itemequipped = TRUE
		if(!on)
			H.add_hud_to(user)
//		else
//			H.remove_hud_from(user)
		return TRUE
	else
		itemequipped = FALSE
		H.remove_hud_from(user)
		return FALSE

/obj/item/clothing/glasses/welding/superior/toggle()
	..()
	var/mob/living/carbon/user = usr
	var/datum/atom_hud/H = huds[HUDType]
	if(up)
		on = TRUE
		if(itemequipped)
			H.remove_hud_from(user)
	else
		on = FALSE
		if(itemequipped)
			H.add_hud_to(user)

/obj/item/clothing/glasses/welding/superior/dropped(mob/living/carbon/human/user)
	..()
	if(HUDType && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = huds[HUDType]
		H.remove_hud_from(user)

