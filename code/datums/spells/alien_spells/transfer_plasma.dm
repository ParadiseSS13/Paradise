/obj/effect/proc_holder/spell/touch/alien_spell/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfers plasma to a nearby alien"
	hand_path = "/obj/item/melee/touch_attack/alien/transfer_plasma"
	action_icon_state = "alien_transfer"
	on_gain_message = span_noticealien("You vomit some plasma in your hand and prepare to transfer it.")
	on_withdraw_message = span_noticealien("You decide not to use plasma for now...")
	plasma_cost = 0


/obj/effect/proc_holder/spell/touch/alien_spell/transfer_plasma/Click(mob/living/carbon/user = usr)
	if(attached_hand)
		return ..()

	var/amount = input("Amount:", "How much plasma to transfer?") as num
	if(!amount)
		return

	amount = abs(round(amount))

	if(user.get_plasma() < amount)
		to_chat(user, span_warning("You don't have that much plasma!"))
		return

	var/obj/item/melee/touch_attack/alien/transfer_plasma/transfer_hand = new hand_path(src, user, amount)

	// And code copypasta now!
	if(user.put_in_hands(transfer_hand, qdel_on_fail = TRUE))
		RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(discharge_hand))
		transfer_hand.plasma_amount = amount
		attached_hand = transfer_hand
		user.adjust_alien_plasma(-amount)

		if(on_gain_message)
			to_chat(user, on_gain_message)

		if(on_withdraw_message)
			transfer_hand.on_withdraw_message = on_withdraw_message
	else
		to_chat(user, span_warning("Your hands are full!"))


/obj/item/melee/touch_attack/alien/transfer_plasma
	name = "plasma transfer"
	desc = "Transfers plasma to another alien."
	icon_state = "alien_transfer"
	var/plasma_amount = 0


/obj/item/melee/touch_attack/alien/transfer_plasma/New(spell, owner, plasma)
	. = ..()
	name = "[name] ([plasma])"


/obj/item/melee/touch_attack/alien/transfer_plasma/Destroy()
	if(owner && is_withdraw)
		owner.adjust_alien_plasma(plasma_amount)
	return ..()


/obj/item/melee/touch_attack/alien/transfer_plasma/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user)
		return ..()

	if(!proximity || !isalien(target) || !iscarbon(user) || user.lying || user.handcuffed)
		return

	var/mob/living/carbon/transfering_to = target
	transfering_to.adjust_alien_plasma(plasma_amount)
	to_chat(user, span_noticealien("You have transfered [plasma_amount] plasma to [transfering_to]."))
	to_chat(transfering_to, span_noticealien("[user] has transfered [plasma_amount] plasma to you!"))
	..()

