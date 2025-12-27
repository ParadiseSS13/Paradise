//Hardsuit toggle code


/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	suit_toggled = FALSE
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self__legacy__attackchain(H)
		H.transfer_item_to(helmet, src, force = TRUE)
		H.update_inv_wear_suit()
		to_chat(H, SPAN_NOTICE("The helmet on the hardsuit disengages."))
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		helmet.forceMove(src)

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		return
	if(!suit_toggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				to_chat(H, SPAN_WARNING("You must be wearing [src] to engage the helmet!"))
				return
			if(H.head)
				to_chat(H, SPAN_WARNING("You're already wearing something on your head!"))
				return
			else if(H.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD, FALSE, FALSE))
				to_chat(H, SPAN_NOTICE("You engage the helmet on the hardsuit."))
				suit_toggled = TRUE
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		RemoveHelmet()
