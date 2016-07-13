//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	action_button_name = "Adjust hood"
	var/obj/item/clothing/head/hood
	var/hoodtype = /obj/item/clothing/head/winterhood //so the chaplain hoodie or other hoodies can override this

/obj/item/clothing/suit/hooded/New()
	MakeHood()
	verbs -= /obj/item/clothing/suit/verb/openjacket //you can't unbutton those, deal with it
	..()

/obj/item/clothing/suit/hooded/Destroy()
	qdel(hood)
	return ..()

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/W = new hoodtype(src)
		hood = W

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	icon_state = "[initial(icon_state)]"
	suit_adjusted = 0
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.unEquip(hood, 1)
		H.update_inv_wear_suit()
	hood.loc = src

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/verb/Hooderize(var/mob/user)
	set name = "Adjust the hood"
	set category = "Object"
	set src in usr
	if(!isliving(usr))
		return
	if(usr.stat)
		return
	ToggleHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!suit_adjusted)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.wear_suit != src)
				to_chat(H,"<span class='warning'>You must be wearing [src] to put up the hood!</span>")
				return
			if(H.head)
				to_chat(H,"<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(hood,slot_head,0,0,1))
				suit_adjusted = 1
				icon_state = "[initial(icon_state)]_hood"
				H.update_inv_wear_suit()
	else
		RemoveHood()
