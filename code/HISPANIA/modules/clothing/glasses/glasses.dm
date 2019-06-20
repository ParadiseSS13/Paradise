/obj/item/clothing/glasses/welding/superior
	..()
	var/HUDType = DATA_HUD_DIAGNOSTIC


///obj/item/clothing/glasses/welding/superior/equipped(mob/living/carbon/human/user, slot)
//	..()
//	if(HUDType && slot == slot_glasses)
//		var/datum/atom_hud/H = huds[HUDType]
//		H.add_hud_to(user)

/obj/item/clothing/glasses/welding/superior/toggle()
	..()
	var/mob/living/carbon/user = usr
	var/datum/atom_hud/H = huds[HUDType]
	if(up)
		H.add_hud_to(user)
	else
		H.remove_hud_from(user)

/obj/item/clothing/glasses/welding/superior/dropped(mob/living/carbon/human/user)
	..()
	if(HUDType && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = huds[HUDType]
		H.remove_hud_from(user)

