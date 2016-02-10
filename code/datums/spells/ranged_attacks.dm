/*
While this is a confusing name, this is called "ranged" to oppose the "touch" attacks
"ranged" attacks are used to act as a single-use "gun" - so that fireball can be aimed
in some direction other than directly in front of you
*/
/obj/effect/proc_holder/spell/targeted/ranged
	var/hand_path = /obj/item/weapon/gun/magic/hand
	var/obj/item/weapon/gun/magic/hand/attached_hand = null
	include_user = 1
	range = -1

	school = "none"

/obj/effect/proc_holder/spell/targeted/ranged/Click(mob/user = usr)
	if(attached_hand)
		qdel(attached_hand)
		charge_counter = charge_max
		attached_hand = null
		user << "<span class='notice'>You draw the power out of your hand.</span>"
		return 0
	..()

/obj/effect/proc_holder/spell/targeted/ranged/cast(list/targets)
	for(var/mob/living/carbon/user in targets)
		if(!attached_hand)
			if(!ChargeHand(user))
				return 0
	while(attached_hand) //hibernate untill the spell is actually used
		charge_counter = 0
		sleep(1)

/obj/effect/proc_holder/spell/targeted/ranged/proc/ChargeHand(mob/living/carbon/user)
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
		user << "<span class='warning'>Your hands are full!</span>"
		return 0
	user << "<span class='notice'>You channel the power of the spell to your hand.</span>"
	return 1

/obj/effect/proc_holder/spell/targeted/ranged/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	hand_path = /obj/item/weapon/gun/magic/hand/fireball

	school = "evocation"
	charge_max = 60
	clothes_req = 0
	cooldown_min = 20 //10 deciseconds reduction per rank

	action_icon_state = "fireball"