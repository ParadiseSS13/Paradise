/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity, params)
	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A, 1))
		return

	if(HAS_TRAIT(src, TRAIT_HULK))
		if(proximity) //no telekinetic hulk attack
			if(A.attack_hulk(src))
				return

	if(buckled && isstructure(buckled))
		var/obj/structure/S = buckled
		if(S.prevents_buckled_mobs_attacking())
			return

	if(SEND_SIGNAL(A, COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY, src) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return

	A.attack_hand(src, params)

/atom/proc/attack_hand(mob/user as mob, params)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/*
/mob/living/carbon/human/RestrainedClickOn(atom/A) -- Handled by carbons
	return
*/

/mob/living/carbon/RestrainedClickOn(atom/A)
	return 0

/mob/living/carbon/human/RangedAttack(atom/A, params)
	. = ..()
	if(.)
		return
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A, 0)) // for magic gloves
			return

	if(HAS_TRAIT(src, TRAIT_LASEREYES) && a_intent == INTENT_HARM)
		LaserEyes(A)

	if(HAS_TRAIT(src, TRAIT_TELEKINESIS) && telekinesis_range_check(src, A))
		A.attack_tk(src)

	if(isturf(A) && get_dist(src, A) <= 1)
		Move_Pulled(A)
/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/target, proximity_flag, modifiers)
	var/sigreturn = SEND_SIGNAL(src, COMSIG_LIVING_UNARMED_ATTACK, target, proximity_flag, modifiers)
	if(sigreturn & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(sigreturn & COMPONENT_SKIP_ATTACK)
		return FALSE

	resolve_unarmed_attack(target, modifiers)
	return TRUE

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A)
	target = A
	AttackingTarget()

/mob/living/proc/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_animal(src, modifiers)

/atom/proc/attack_animal(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)

///When a basic mob attacks something, either by AI or user.
/atom/proc/attack_basic_mob(mob/user, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_BASIC_MOB, user) & COMPONENT_BASIC_ATTACK_CANCEL_CHAIN)
		return
	return handle_basic_attack(user, modifiers) //return value of attack animal, this is how much damage was dealt to the attacked thing

///This exists so stuff can override the default call of attack_animal for attack_basic_mob
///Remove this when simple animals are removed and everything can be handled on attack basic mob.
/atom/proc/handle_basic_attack(user, modifiers)
	return attack_animal(user, modifiers)

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(atom/A)
	A.attack_alien(src)

/atom/proc/attack_alien(mob/living/carbon/alien/user)
	attack_hand(user)

/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A)
	A.attack_larva(src)

/atom/proc/attack_larva(mob/user)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A)
	A.attack_slime(src)

/atom/proc/attack_slime(mob/user)
	return

/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return

/mob/new_player/can_use_clickbinds()
	return FALSE

// pAIs are not intended to interact with anything in the world
/mob/living/silicon/pai/UnarmedAttack(atom/A)
	return
