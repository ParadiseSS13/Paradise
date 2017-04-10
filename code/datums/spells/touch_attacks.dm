/obj/effect/proc_holder/spell/targeted/touch
	var/hand_path = /obj/item/weapon/melee/touch_attack
	var/obj/item/weapon/melee/touch_attack/attached_hand = null
	invocation_type = "none" //you scream on connecting, not summoning
	include_user = 1
	range = -1

/obj/effect/proc_holder/spell/targeted/touch/Click(mob/user = usr)
	if(attached_hand)
		qdel(attached_hand)
		charge_counter = charge_max
		attached_hand = null
		to_chat(user, "<span class='notice'>You draw the power out of your hand.</span>")
		return 0
	..()

/obj/effect/proc_holder/spell/targeted/touch/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/target in targets)
		if(!attached_hand)
			if(!ChargeHand(target))
				return 0
	while(attached_hand) //hibernate untill the spell is actually used
		charge_counter = 0
		sleep(1)

/obj/effect/proc_holder/spell/targeted/touch/proc/ChargeHand(mob/living/carbon/user)
	var/hand_handled = 1
	attached_hand = new hand_path(src)
	if(user.hand) 	//left active hand
		if(!user.equip_to_slot_if_possible(attached_hand, slot_l_hand, 0, 1, 1))
			if(!user.equip_to_slot_if_possible(attached_hand, slot_r_hand, 0, 1, 1))
				hand_handled = 0
	else			//right active hand
		if(!user.equip_to_slot_if_possible(attached_hand, slot_r_hand, 0, 1, 1))
			if(!user.equip_to_slot_if_possible(attached_hand, slot_l_hand, 0, 1, 1))
				hand_handled = 0
	if(!hand_handled)
		qdel(attached_hand)
		charge_counter = charge_max
		attached_hand = null
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return 0
	to_chat(user, "<span class='notice'>You channel the power of the spell to your hand.</span>")
	return 1


/obj/effect/proc_holder/spell/targeted/touch/disintegrate
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	hand_path = /obj/item/weapon/melee/touch_attack/disintegrate

	school = "evocation"
	charge_max = 600
	clothes_req = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "gib"

/obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell charges your hand with the power to turn victims into inert statues for a long period of time."
	hand_path = /obj/item/weapon/melee/touch_attack/fleshtostone

	school = "transmutation"
	charge_max = 600
	clothes_req = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "statue"
