/obj/item/stack/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	singular_name = "tape roll"
	w_class = WEIGHT_CLASS_TINY
	amount = 10
	max_amount = 10

/obj/item/stack/tape_roll/New(var/loc, var/amount=null)
	..()

	update_icon()

/obj/item/stack/tape_roll/attack(mob/living/carbon/human/M, mob/living/user)
	if(!istype(M)) //What good is a duct tape mask if you are unable to speak?
		return
	if(M.wear_mask)
		to_chat(user, "Remove [M.p_their()] mask first!")
	else if(amount < 2)
		to_chat(user, "You'll need more tape for this!")
	else if(!M.check_has_mouth())
		to_chat(user, "[M.p_they(TRUE)] [M.p_have()] no mouth to tape over!")
	else
		if(M == user)
			to_chat(user, "You try to tape your own mouth shut.")
		else
			to_chat(user, "You try to tape [M]'s mouth shut.")
			M.visible_message("<span class='warning'>[user] tries to tape [M]'s mouth closed!</span>")
		if(do_after(user, 50, target = M))
			if(M == user)
				to_chat(user, "You cover your own mouth with a piece of duct tape.")
			else
				to_chat(user, "You cover [M]'s mouth with a piece of duct tape. That will shut [M.p_them()] up!")
				M.visible_message("<span class='warning'>[user] tapes [M]'s mouth shut!</span>")
			var/obj/item/clothing/mask/muzzle/G = new /obj/item/clothing/mask/muzzle/tapegag
			M.equip_to_slot(G, slot_wear_mask)
			G.add_fingerprint(user)
			amount = amount - 2
	if(amount <= 0)
		user.unEquip(src, 1)
		qdel(src)

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

/obj/item/stack/tape_roll/afterattack(obj/item/I, mob/user, proximity, params)
	..()
	if(!proximity || !istype(I))
		return
	var/list/clickparams = params2list(params)
	var/x_offset = text2num(clickparams["icon-x"])
	var/y_offset = text2num(clickparams["icon-y"])
	if(I.GetComponent(/datum/component/ducttape))
		to_chat(user, "<span class='notice'>[I] already has some tape attached!</span>")
		return
	if(use(1))
		to_chat(user, "<span class='notice'>You apply some tape to [I].</span>")
		I.AddComponent(/datum/component/ducttape, I, user, x_offset, y_offset)
		I.anchored = TRUE
		user.transfer_fingerprints_to(src)
	else
		to_chat(user, "<span class='notice'>You don't have enough tape to do that!</span>")
