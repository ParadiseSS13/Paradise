/obj/item/stack/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	singular_name = "tape roll"
	w_class = WEIGHT_CLASS_TINY
	amount = 25
	max_amount = 25

/obj/item/stack/tape_roll/Initialize(mapload, loc, amount)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/tape_roll/interact_with_atom(atom/target, mob/living/user, list/modifiers)	
	if(!ishuman(target)) // What good is a duct tape mask if you are unable to speak?
		return ..()

	var/mob/living/carbon/human/H = target
	if(H.wear_mask)
		to_chat(user, SPAN_WARNING("Remove [H.p_their()] mask first!"))
		return ITEM_INTERACT_COMPLETE

	if(amount < 2)
		to_chat(user, SPAN_WARNING("You'll need more tape for this!"))
		return ITEM_INTERACT_COMPLETE

	if(!H.check_has_mouth())
		to_chat(user, "[H.p_they(TRUE)] [H.p_have()] no mouth to tape over!")
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_WARNING("[user] is taping [H]'s mouth closed!"),
		SPAN_NOTICE("You try to tape [H == user ? "your own" : "[H]'s"] mouth shut!"),
		SPAN_WARNING("You hear tape ripping.")
		)
	if(!do_after(user, 5 SECONDS, target = H))
		return ITEM_INTERACT_COMPLETE

	if(!use(2))
		to_chat(user, SPAN_NOTICE("You don't have enough tape!"))
		return ITEM_INTERACT_COMPLETE

	if(H.wear_mask)
		to_chat(user, SPAN_NOTICE("[H == user ? user : H]'s mouth is already covered!"))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(SPAN_WARNING("[user] tapes [H]'s mouth shut!"),
	SPAN_NOTICE("You cover [H == user ? "your own" : "[H]'s"] mouth with a piece of duct tape.[H == user ? null : " That will shut them up."]"))
	var/obj/item/clothing/mask/muzzle/G = new /obj/item/clothing/mask/muzzle/tapegag
	H.equip_to_slot(G, ITEM_SLOT_MASK)
	G.add_fingerprint(user)

/obj/item/stack/tape_roll/update_icon_state()
	var/amount = get_amount()
	if((amount <= 2) && (amount > 0))
		icon_state = "taperoll"
	if((amount <= 4) && (amount > 2))
		icon_state = "taperoll-2"
	if((amount <= 6) && (amount > 4))
		icon_state = "taperoll-3"
	if(amount > 6)
		icon_state = "taperoll-4"
	else
		icon_state = "taperoll-4"
