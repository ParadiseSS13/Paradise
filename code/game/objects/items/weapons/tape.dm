/obj/item/stack/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	singular_name = "tape roll"
	w_class = WEIGHT_CLASS_TINY
	amount = 25
	max_amount = 25

/obj/item/stack/tape_roll/New(loc, amount=null)
	..()

	update_icon()

/obj/item/stack/tape_roll/attack(mob/living/carbon/human/M, mob/living/user)
	if(!istype(M)) //What good is a duct tape mask if you are unable to speak?
		return
	if(M.wear_mask)
		to_chat(user, "Remove [M.p_their()] mask first!")
		return
	if(amount < 2)
		to_chat(user, "You'll need more tape for this!")
		return
	if(!M.check_has_mouth())
		to_chat(user, "[M.p_they(TRUE)] [M.p_have()] no mouth to tape over!")
		return
	user.visible_message(span_warning("[user] is taping [M]'s mouth closed!"),
	span_notice("You try to tape [M == user ? "your own" : "[M]'s"] mouth shut!"),
	span_warning("You hear tape ripping."))
	if(!do_after(user, 50, target = M))
		return
	if(!use(2))
		to_chat(user, span_notice("You don't have enough tape!"))
		return
	if(M.wear_mask)
		to_chat(user, span_notice("[M == user ? user : M]'s mouth is already covered!"))
		return
	user.visible_message(span_warning("[user] tapes [M]'s mouth shut!"),
	span_notice("You cover [M == user ? "your own" : "[M]'s"] mouth with a piece of duct tape.[M == user ? null : " That will shut them up."]"))
	var/obj/item/clothing/mask/muzzle/G = new /obj/item/clothing/mask/muzzle/tapegag
	M.equip_to_slot(G, slot_wear_mask)
	G.add_fingerprint(user)

/obj/item/stack/tape_roll/update_icon()
	var/amount = get_amount()
	if((amount <= 2) && (amount > 0))
		icon_state = "taperoll"
	if((amount <= 4) && (amount > 2))
		icon_state = "taperoll-2"
	if((amount <= 6) && (amount > 4))
		icon_state = "taperoll-3"
	if((amount > 6))
		icon_state = "taperoll-4"
	else
		icon_state = "taperoll-4"
	..()
