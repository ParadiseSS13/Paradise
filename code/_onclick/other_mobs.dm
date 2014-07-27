/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(var/atom/A, var/proximity)
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	if(proximity && istype(G) && G.Touch(A,1))
		return

	A.attack_hand(src)
/atom/proc/attack_hand(mob/user as mob)
	return

/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	return



// Commented out to prevent overwriting RangedAttack in click.dm ~ Bone White
/*
/mob/living/carbon/human/RangedAttack(var/atom/A)
	if(!gloves && !mutations.len) return
	var/obj/item/clothing/gloves/G = gloves
	if((M_LASER in mutations) && a_intent == "harm")
		LaserEyes(A) // moved into a proc below

	else if(istype(G) && G.Touch(A,0)) // for magic gloves
		return

	else if(M_TK in mutations)
		switch(get_dist(src,A))
			if(1 to 5) // not adjacent may mean blocked by window
				next_move += 2
			if(5 to 7)
				next_move += 5
			if(8 to 15)
				next_move += 10
			if(16 to 128)
				return
		A.attack_tk(src)
*/

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(var/atom/A)
	A.attack_animal(src)
/atom/proc/attack_animal(mob/user as mob)
	return
/mob/living/RestrainedClickOn(var/atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(var/atom/A)
	A.attack_paw(src)
/atom/proc/attack_paw(mob/user as mob)
	return

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(var/atom/A)
	if(a_intent != "harm" || !ismob(A)) return
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = ran_zone(pick("chest", "l_hand", "r_hand", "l_leg", "r_leg"))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[name] has bit [ML]!</B>", 1)
		if(armor >= 2) return
	else
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[src] has attempted to bite [ML]!</B>", 1)

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(var/atom/A)
	A.attack_alien(src)
/atom/proc/attack_alien(mob/user as mob)
	attack_paw(user)
	return
/mob/living/carbon/alien/RestrainedClickOn(var/atom/A)
	return

/mob/living/carbon/alien/humanoid/RangedAttack(var/atom/A)
	if(!large  && a_intent == "harm")
		Neurotox(A)
		return
	else if(large && a_intent == "harm")
		NeuroAOE(A)
		return


/mob/living/carbon/alien/humanoid/proc/Neurotox(atom/A)
	if(world.time < next_attack)
		return

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A) // Get the tile infront of the move, based on their direction

	if(!isturf(U) || !isturf(T))
		return

	var/obj/item/projectile/bullet/neurotoxin/NT = new /obj/item/projectile/bullet/neurotoxin(loc)
	NT.firer = src
//	NT.def_zone = get_organ_target()
	NT.original = A
	NT.current = T
	NT.yo = U.y - T.y
	NT.xo = U.x - T.x
	spawn( 1)
		NT.process()
	next_attack = world.time + 100

/mob/living/carbon/alien/humanoid/proc/NeuroAOE(atom/A)
	if(world.time < next_attack)
		return

	var/direction = get_dir(src,A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))

	var/list/the_targets = list(T,T1,T2)

	for(var/a=0, a<5, a++)
		spawn(0)
			var/obj/effect/effect/water/D = new /obj/effect/effect/water( get_turf(src) )
			D.color = "#00FF21"
			var/turf/my_target = pick(the_targets)
			for(var/b=0, b<5, b++)
				if(!step_towards(D,my_target))	return
				if(!D) return
//				D.reagents.reaction(get_turf(D))
				for(var/atom/atm in get_turf(D))
					if(!D) return
					if(istype(atm, /mob/living/carbon/alien))
						return
					if(istype(atm, /mob/living/carbon))
						var/mob/living/carbon/C = atm
						if(ishuman(C))
							var/mob/living/carbon/human/H = C
							if(istype(H.wear_suit, /obj/item/clothing/suit/space) && istype(H.head, /obj/item/clothing/head/helmet/space))
								return
						else
							C.Weaken(5)
							C.adjustToxLoss(20)
							C << "You were drenched with neurotoxin!"
//					D.reagents.reaction(atm, TOUCH)                      // Touch, since we sprayed it.
				if(D.loc == my_target) break
				sleep(2)
	next_attack = world.time + 100


// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(var/atom/A)
	A.attack_larva(src)
/atom/proc/attack_larva(mob/user as mob)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/carbon/slime/UnarmedAttack(var/atom/A)
	A.attack_slime(src)
/atom/proc/attack_slime(mob/user as mob)
	return
/mob/living/carbon/slime/RestrainedClickOn(var/atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return
