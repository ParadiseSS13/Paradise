//Hardsuit toggle code
/obj/item/clothing/suit/space/hardsuit/New()
	MakeHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(helmet)
		helmet.suit = null
		QDEL_NULL(helmet)
	QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(suit)
		suit.helmet = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != slot_wear_suit)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	suittoggled = FALSE
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.unEquip(helmet, TRUE)
		helmet.forceMove(src)
		H.update_inv_wear_suit()
		to_chat(H, "<span class='notice'>The helmet on the hardsuit disengages.</span>")
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		helmet.forceMove(src)

/obj/item/clothing/suit/space/hardsuit/dropped()
	..()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				to_chat(H, "<span class='warning'>You must be wearing [src] to engage the helmet!</span>")
				return
			if(H.head)
				to_chat(H, "<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(helmet, slot_head, 0 ,0, 1))
				to_chat(H, "<span class='notice'>You engage the helmet on the hardsuit.</span>")
				suittoggled = TRUE
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		RemoveHelmet()