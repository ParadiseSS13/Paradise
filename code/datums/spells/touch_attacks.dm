/datum/spell/touch
	var/hand_path = /obj/item/melee/touch_attack
	var/obj/item/melee/touch_attack/attached_hand = null
	var/on_remove_message = TRUE

/datum/spell/touch/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/touch/Click(mob/user = usr)
	if(attached_hand)
		discharge_hand(user, TRUE)
		return FALSE
	charge_hand(user)

/datum/spell/touch/proc/charge_hand(mob/living/carbon/user)
	var/hand_handled = 1
	attached_hand = new hand_path(src)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(discharge_hand))
	if(isalien(user))
		user.put_in_hands(attached_hand)
		return
	if(user.hand) 	//left active hand
		if(!user.equip_to_slot_if_possible(attached_hand, ITEM_SLOT_LEFT_HAND, FALSE, TRUE))
			if(!user.equip_to_slot_if_possible(attached_hand, ITEM_SLOT_RIGHT_HAND, FALSE, TRUE))
				hand_handled = 0
	else			//right active hand
		if(!user.equip_to_slot_if_possible(attached_hand, ITEM_SLOT_RIGHT_HAND, FALSE, TRUE))
			if(!user.equip_to_slot_if_possible(attached_hand, ITEM_SLOT_LEFT_HAND, FALSE, TRUE))
				hand_handled = 0
	if(!hand_handled)
		qdel(attached_hand)
		attached_hand = null
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return 0
	to_chat(user, "<span class='notice'>You channel the power of the spell to your hand.</span>")
	return 1

/datum/spell/touch/proc/discharge_hand(atom/target, any = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/user = action.owner
	if(!istype(attached_hand))
		return
	if(!any && attached_hand != user.get_active_hand())
		return
	QDEL_NULL(attached_hand)
	if(on_remove_message)
		to_chat(user, "<span class='notice'>You draw the power out of your hand.</span>")


/datum/spell/touch/disintegrate
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	hand_path = /obj/item/melee/touch_attack/disintegrate

	base_cooldown = 600
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "gib"

/datum/spell/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell charges your hand with the power to turn victims into inert statues for a long period of time."
	hand_path = /obj/item/melee/touch_attack/fleshtostone

	base_cooldown = 600
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "statue"

/datum/spell/touch/plushify
	name = "Plushify"
	desc = "This spell charges your hand with the power to turn your victims into marketable plushies!"
	hand_path = /obj/item/melee/touch_attack/plushify

	base_cooldown = 600
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "plush"
