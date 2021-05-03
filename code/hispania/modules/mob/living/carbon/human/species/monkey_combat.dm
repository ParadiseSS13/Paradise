/proc/IsLesserBeing(mob/living/carbon/human/H)
	if(ismonkeybasic(H))
		return TRUE
	if(iswolpin(H))
		return TRUE
	if(isneara(H))
		return TRUE
	if(isfarwa(H))
		return TRUE
	if(isstok(H))
		return TRUE
	return FALSE

/mob/living/carbon/human
	var/aggressive=0 // set to 1 using VV for an angry monkey
	var/frustration=0

	var/melee_damage_lower = 4
	var/melee_damage_upper = 10
	var/attacktext = "bites"
	var/attack_sound = 'sound/weapons/bite.ogg'
	var/obj_damage = 0 //how much damage this simple animal does to objects, if any
	var/armour_penetration = 0
	var/melee_damage_type = BRUTE

	var/pickupTimer = 0
	var/list/enemies = list()
	var/mob/living/target
	var/obj/item/pickupTarget
	var/mode = MONKEY_IDLE
	var/list/myPath = list()
	var/list/blacklistItems = list()
	var/maxStepsTick = 6
	var/best_force = 8
	var/resisting = FALSE
	var/pickpocketing = FALSE
	//var/disposing_body = FALSE
	//var/obj/machinery/disposal/bodyDisposal = null

/mob/living/carbon/human/proc/IsStandingStill()
	return resisting || pickpocketing //|| disposing_body

// blocks
// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/human/proc/walk2derpless(target)
	if(!target || IsStandingStill())
		walk_to(src,0)
		return FALSE

	if(stat || paralysis || lying)
		walk_to(src,0)
		return FALSE

	walk_to(src,get_turf(target),1,5)

	return TRUE

/mob/living/carbon/human/proc/equip_item(obj/item/I)
	if(I.loc == src)
		return TRUE

	if(istype(I, /obj/item/twohanded/required/kirbyplants))
		blacklistItems[I] ++
		return FALSE

	if(I.anchored)
		blacklistItems[I] ++
		return FALSE

	// WEAPONS
	if(istype(I, /obj/item/melee) || istype(I, /obj/item/kitchen/knife))
		var/obj/item/W = I
		if(W.force >= best_force)
			put_in_hands(W)
			best_force = W.force
			return TRUE

	// CLOTHING
	else if(istype(I,/obj/item/clothing))
		var/obj/item/clothing/C = I
		monkeyDrop(C)
		pickup_and_wear(C)
		return TRUE

	// EVERYTHING ELSE
	else
		put_in_hands(I)
		return TRUE

	blacklistItems[I] ++
	return FALSE

/mob/living/carbon/human/proc/pickup_and_wear(obj/item/clothing/C)
	if(!equip_to_appropriate_slot(C))
		monkeyDrop(get_item_by_slot(C)) // remove the existing item if worn
		sleep(5)
		equip_to_appropriate_slot(C)

/mob/living/carbon/human/proc/should_target(mob/living/L)

	if(L == src)
		return FALSE

	if(enemies[L])
		return TRUE

	// target non-monkey mobs when aggressive, with a small probability of monkey v monkey
	if(aggressive && (!istype(L, /mob/living/carbon/human/) || prob(MONKEY_AGGRESSIVE_MVM_PROB)))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/handle_combat()
	if(incapacitated(TRUE, TRUE)) // No vamos a checar si esta esposado o agarrado.
		walk_to(src,0)
		return FALSE

	if(on_fire || buckled || restrained())
		if(!resisting && prob(MONKEY_RESIST_PROB))
			resisting = TRUE
			walk_to(src,0)
			resist()
	else
		resisting = FALSE

	// have we been disarmed
	if(!locate(/obj/item/melee) in get_both_hands(src))
		best_force = 8

	if(restrained() || blacklistItems[pickupTarget])
		pickupTarget = null

	if(!resisting && pickupTarget)
		pickupTimer++

		// next to target
		if(Adjacent(pickupTarget) || Adjacent(pickupTarget.loc))
			walk2derpless(pickupTarget.loc)

			// who cares about these items, i want that one!
			drop_r_hand()
			drop_l_hand()

			// on floor
			if(isturf(pickupTarget.loc))
				equip_item(pickupTarget)
				pickupTarget = null
				pickupTimer = 0

			// in someones hand
			else if(ismob(pickupTarget.loc))
				var/mob/M = pickupTarget.loc
				if(!pickpocketing)
					pickpocketing = TRUE
					M.visible_message("[src] starts trying to take [pickupTarget] from [M]", "[src] tries to take [pickupTarget]!")
					pickpocket(M)

		else
			if(pickupTimer >= 8)
				blacklistItems[pickupTarget] ++
				pickupTarget = null
				pickupTimer = 0
			else
				walk2derpless(pickupTarget.loc)
		return TRUE

	switch(mode)
		if(MONKEY_IDLE)		// idle

			var/list/around = view(src, MONKEY_ENEMY_VISION)
			//bodyDisposal = locate(/obj/machinery/disposal/) in around

			// scan for enemies
			for(var/mob/living/L in around)
				if( should_target(L) )
					if(L.stat == CONSCIOUS)
						retaliate(L)
						return TRUE
					/*
					else if(bodyDisposal)
						target = L
						mode = MONKEY_DISPOSE
						return TRUE
					*/

			// pickup any nearby objects
			if(!pickupTarget && prob(MONKEY_PICKUP_PROB))
				var/obj/item/I = locate(/obj/item/) in oview(5,src)
				if(I && !blacklistItems[I])
					pickupTarget = I

			// I WANNA STEAL
			if(!pickupTarget && prob(MONKEY_STEAL_PROB))
				var/mob/living/carbon/human/H = locate(/mob/living/carbon/human/) in oview(5,src)
				if(H)
					pickupTarget = pick(get_both_hands(H))

			// clear any combat walking
			if(!resisting)
				walk_to(src,0)

			return IsStandingStill()

		if(MONKEY_HUNT)		// hunting for attacker
			/*if(health < MONKEY_FLEE_HEALTH)
				mode = MONKEY_FLEE
				return TRUE*/

			// nuh uh you don't pull me!
			if(pulledby)
				if(Adjacent(pulledby))
					a_intent = INTENT_DISARM
					monkey_attack(pulledby)
					retaliate(pulledby)
					return TRUE

			if(target != null )
				walk2derpless(target)

			//drop shitty items that wont help him
			if(locate(/obj/item) in get_both_hands(src))
				var/obj/item/I = locate(/obj/item) in get_both_hands(src)
				if(I.force == 0)
					unEquip(I)

			// pickup any nearby weapon
			if(!pickupTarget && prob(MONKEY_WEAPON_PROB))
				var/obj/item/W = locate(/obj/item/melee/) in oview(7,src)
				if(W && !blacklistItems[W] && W.force > best_force)
					pickupTarget = W

			// recruit other monkies
			var/list/around = view(src, MONKEY_ENEMY_VISION)
			for(var/mob/living/carbon/human/M in around)
				if(M.mode == MONKEY_IDLE && prob(MONKEY_RECRUIT_PROB) && IsLesserBeing(M))
					M.emote("scream")
					M.target = target
					M.mode = MONKEY_HUNT

			// switch targets
			for(var/mob/living/L in around)
				if(L != target && should_target(L) && L.stat == CONSCIOUS && prob(MONKEY_SWITCH_TARGET_PROB))
					target = L
					return TRUE

			// if can't reach target for long enough, go idle
			if(frustration >= MONKEY_HUNT_FRUSTRATION_LIMIT)
				back_to_idle()
				return TRUE

			if(target && target.stat == CONSCIOUS)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))	// if right next to perp

					// check if target has a weapon
					var/obj/item/melee/W = locate(/obj/item/melee) in get_both_hands(target)

					// if the target has a weapon, chance to disarm them
					if(W && prob(MONKEY_ATTACK_DISARM_PROB))
						pickupTarget = W
						a_intent = INTENT_DISARM
						monkey_attack(target)

					else
						a_intent = INTENT_HARM
						monkey_attack(target)

					return TRUE

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

	if(incapacitated(TRUE,TRUE)) // TABLING
		walk_to(src,0)
		return FALSE

	return IsStandingStill()

/mob/living/carbon/human/proc/pickpocket(mob/M)
	if(do_after(src, MONKEY_ITEM_SNATCH_DELAY) && pickupTarget)
		for(var/obj/item/I in get_both_hands(M))
			if(I == pickupTarget)
				M.visible_message("<span class='danger'>[src] snatches [pickupTarget] from [M].</span>", "<span class='userdanger'>[src] snatched [pickupTarget]!</span>")
				M.unEquip(pickupTarget)
				if(locate(pickupTarget) in oview(3))
					equip_item(pickupTarget)
	pickpocketing = FALSE
	pickupTarget = null
	pickupTimer = 0

/*
/mob/living/carbon/human/proc/stuff_mob_in()
	if(bodyDisposal && target && Adjacent(bodyDisposal))
		bodyDisposal.MouseDrop_T(target, src)
	disposing_body = FALSE
	back_to_idle()
*/

/mob/living/carbon/human/proc/back_to_idle()

	if(pulling)
		stop_pulling()

	mode = MONKEY_IDLE
	target = null
	a_intent = INTENT_HELP
	frustration = 0
	walk_to(src,0)

// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/mob/living/carbon/human/proc/monkey_attack(mob/living/L)
	var/obj/item/melee/Weapon = locate(/obj/item) in get_both_hands(src)

	// attack with weapon if we have one
	if(Weapon)
		L.attackby(Weapon, src)
	else
		L.attack_animal(src)

	// no de-aggro
	if(aggressive)
		return

	// if we arn't enemies, we were likely recruited to attack this target, jobs done if we calm down so go back to idle
	if(!enemies[L])
		if(target == L && prob(MONKEY_HATRED_REDUCTION_PROB))
			back_to_idle()
		return // already de-aggroed

	if(prob(MONKEY_HATRED_REDUCTION_PROB))
		enemies[L] --

	// if we are not angry at our target, go back to idle
	if(enemies[L] <= 0)
		enemies.Remove(L)
		if(target == L)
			back_to_idle()

// get angry are a mob
/mob/living/carbon/human/proc/retaliate(mob/living/L)
	if(!IsLesserBeing(src)) // Por si las moscas
		return
	mode = MONKEY_HUNT
	target = L
	enemies[L] += MONKEY_HATRED_AMOUNT

	if(a_intent != INTENT_HARM)
		emote("scream")
		a_intent = INTENT_HARM

/mob/living/carbon/human/proc/on_attack_hand(mob/living/L)
	if(IsLesserBeing(src))
		if(L.a_intent == INTENT_HARM && prob(MONKEY_RETALIATE_HARM_PROB))
			retaliate(L)
		else if(L.a_intent == INTENT_DISARM && prob(MONKEY_RETALIATE_DISARM_PROB))
			retaliate(L)

/mob/living/carbon/human/proc/on_attack_animal(mob/living/L)
	if(IsLesserBeing(src))
		if(L.a_intent == INTENT_HARM && prob(MONKEY_RETALIATE_HARM_PROB))
			retaliate(L)
		else if(L.a_intent == INTENT_DISARM && prob(MONKEY_RETALIATE_DISARM_PROB))
			retaliate(L)

/mob/living/carbon/human/attackby(obj/item/W, mob/user, params)
	..()
	if(IsLesserBeing(src) && W.force && !target && W.damtype != STAMINA)
		retaliate(user)

/datum/species/monkey/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	. = ..()
	if(istype(P ,/obj/item/projectile/beam) || istype(P,/obj/item/projectile/bullet))
		if((P.damage_type == BURN) || (P.damage_type == BRUTE))
			if(!P.nodamage && P.damage < H.health)
				H.retaliate(P.firer)

/mob/living/carbon/human/proc/on_hitby(atom/movable/AM, skipcatch = 0, hitpush = 1, blocked = 0, datum/thrownthing/throwingdatum)
	if(IsLesserBeing(src) && istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.throwforce < src.health && I.thrownby && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)

/mob/living/carbon/human/proc/knockOver(mob/living/carbon/C)
	C.visible_message("<span class='warning'>[pick( \
					  "[C] dives out of [src]'s way!", \
					  "[C] stumbles over [src]!", \
					  "[C] jumps out of [src]'s path!", \
					  "[C] trips over [src] and falls!", \
					  "[C] topples over [src]!", \
					  "[C] leaps out of [src]'s way!")]</span>")
	C.Weaken(2)

/mob/living/carbon/human/Crossed(atom/movable/AM)
	if(IsLesserBeing(src) && !stat && !paralysis && !restrained() && !lying && !weakened && ishuman(AM) && target)
		knockOver(AM)
		return
	..()

/mob/living/carbon/human/proc/monkeyDrop(obj/item/A)
	if(A)
		unEquip(A, 1)
		update_icons()

/mob/living/carbon/human/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(IsLesserBeing(src))
		if(!no_effect && !visual_effect_icon)
			visual_effect_icon = ATTACK_EFFECT_BITE
		var/obj/item/melee/Weapon = locate(/obj/item) in get_both_hands(src)
		if(Weapon)
			visual_effect_icon = null
	..()

/obj/item/proc/monkey_retaliation(mob/living/carbon/target, mob/living/carbon/user)
	if(IsLesserBeing(target) && prob(MONKEY_CUFF_OR_SYRINGE_RETALIATION_PROB))
		var/mob/living/carbon/human/M = target
		M.visible_message("[M] looks angry!")
		M.retaliate(user)
