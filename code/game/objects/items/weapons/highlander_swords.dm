
//Highlander Style Martial Art
//	Prevents use of guns, but makes the highlander impervious to ranged attacks. Their bravery in battle shields them from the weapons of COWARDS!

/datum/martial_art/highlander
	name = "Highlander Style"
	deflection_chance = 100
	no_guns = TRUE
	no_guns_message = "You'd never stoop so low as to use the weapon of a COWARD!"


//Highlander Claymore
//	Grants the wielder the Highlander Style Martial Art

/obj/item/claymore/highlander
	name = "\improper Highlander claymore"
	desc = "Imbues the wielder with legendary martial prowress and a nigh-unquenchable thirst for glorious battle!"
	var/datum/martial_art/highlander/style = new

/obj/item/claymore/highlander/Destroy()
	if(ishuman(loc))	//just in case it gets destroyed while in someone's possession, such as due to acid or something?
		var/mob/living/carbon/human/H = loc
		style.remove(H)
	QDEL_NULL(style)
	return ..()

/obj/item/claymore/highlander/equipped(mob/user, slot)
	if(!ishuman(user) || !user.mind)
		return
	var/mob/living/carbon/human/H = user
	if(slot & ITEM_SLOT_BOTH_HANDS)
		if(H.mind.martial_art != style)
			style.teach(H, TRUE)
			to_chat(H, "<span class='notice'>THERE CAN ONLY BE ONE!</span>")
	else if(H.mind.martial_art && H.mind.martial_art == style)
		style.remove(H)
		var/obj/item/claymore/highlander/sword = H.is_in_hands(/obj/item/claymore/highlander)
		if(sword)
			//if we have a highlander sword in the other hand, relearn the style from that sword.
			sword.style.teach(H, TRUE)

/obj/item/claymore/highlander/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.mind.martial_art == style)
		style.remove(H)
	var/obj/item/claymore/highlander/sword = H.is_in_hands(/obj/item/claymore/highlander)
	if(sword)
		//if we have a highlander sword in the other hand, relearn the style from that sword.
		sword.style.teach(H, TRUE)
