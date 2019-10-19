/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A, 1))
		return

	if(HULK in mutations)
		if(proximity) //no telekinetic hulk attack
			if(A.attack_hulk(src))
				return

	A.attack_hand(src)

/atom/proc/attack_hand(mob/user as mob)
	return

/*
/mob/living/carbon/human/RestrainedClickOn(var/atom/A) -- Handled by carbons
	return
*/

/mob/living/carbon/RestrainedClickOn(var/atom/A)
	return 0

/mob/living/carbon/human/RangedAttack(atom/A, params)
	. = ..()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A, 0)) // for magic gloves
			return

	if((LASER in mutations) && a_intent == INTENT_HARM)
		LaserEyes(A)

	if(TK in mutations)
		A.attack_tk(src)

	if(isturf(A) && get_dist(src, A) <= 1)
		Move_Pulled(A)

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(var/atom/A)
	A.attack_animal(src)

/mob/living/simple_animal/hostile/UnarmedAttack(var/atom/A)
	target = A
	AttackingTarget()

/atom/proc/attack_animal(mob/user)
	return

/mob/living/RestrainedClickOn(var/atom/A)
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

// pAIs are not intended to interact with anything in the world
/mob/living/silicon/pai/UnarmedAttack(var/atom/A)
	return
