/mob/living/carbon/human/movement_delay()
	var/tally = 0
	if(status_flags & GOTTAGOFAST)
		tally -= 1
	if(status_flags & GOTTAGOREALLYFAST)
		tally -= 2

	if(species.slowdown)
		if(src.species.name == "Wryn")		//handles Wryn specific movement
			if(!istype(get_turf(src), /turf/space))		//Space is 20c whut..
				var/loc_temp = T0C
				var/datum/gas_mixture/environment = loc.return_air()
				if(istype(src.loc, /obj/mecha))
					var/obj/mecha/M = src.loc
					loc_temp =  M.return_temperature()
				else
					loc_temp = environment.temperature

				switch(loc_temp)			//messy switch statement to assign the proper speed
					if(0 to 213.15)			tally = -6	 //you deserve this, god speed to you
					if(213.15 to 250.15) 	tally = -5	 //must get colder..
					if(260.15 to 273.15)	tally = -4
					if(273.15 to 283.15) 	tally = -3	 //pretty fast, though will likely never happen
					if(283.15 to 300.15)	tally = 2	 //slower than humans at normal room temperatures
					if(300.15 to 310.15)	tally = 5
					if(317.15 to 400)		tally = 8
					else					tally = 12	//Stop running into fire you stupid bug
			else
				tally = -7
		else
			tally = species.slowdown

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.

	if((RUN in mutations)) return -1

	var/health_deficiency = (100 - health + staminaloss)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	if(halloss >= 10) tally += (halloss / 10)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70)
		tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(!buckled || (buckled && !istype(buckled, /obj/structure/stool/bed/chair/wheelchair)))
		if(shoes)
			tally += shoes.slowdown

/*
		for(var/organ_name in list("l_foot","r_foot","l_leg","r_leg"))
			var/obj/item/organ/external/E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				tally += 4
			else if(E.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(E.status & ORGAN_BROKEN)
				tally += 1.5
*/

	if(buckled && istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
		for(var/organ_name in list("l_hand","r_hand","l_arm","r_arm"))
			var/obj/item/organ/external/E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				tally += 4
			else if(E.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(E.status & ORGAN_BROKEN)
				tally += 1.5

	if(shock_stage >= 10) tally += 3

	if(back)
		tally += back.slowdown


	if(FAT in src.mutations)
		tally += 1.5
	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	tally += 2*stance_damage //damaged/missing feet or legs is slow

	if(RUN in mutations)
		tally = 0
	if(status_flags & IGNORESLOWDOWN) // make sure this is always at the end so we don't have ignore slowdown getting ignored itself
		tally = 0

	return (tally+config.human_delay)

/mob/living/carbon/human/Process_Spacemove(var/check_drift = 0)
	//Can we act
	if(restrained())	return 0

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = back
		if(((!check_drift) || (check_drift && J.stabilization_on)) && (!lying) && (J.allow_thrust(0.01, src)))
			inertia_dir = 0
			return 1
	//If no working jetpack or magboots then use the other checks
	if(..())	return 1
	return 0


/mob/living/carbon/human/Process_Spaceslipping(var/prob_slip = 5)
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0 // Changing this to zero to make it line up with the comment, and also, make more sense.

	//Do we have magboots or such on if so no slip
	if(istype(shoes, /obj/item/clothing/shoes/magboots) && (shoes.flags & NOSLIP))
		prob_slip = 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= 2)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= 2)	prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()
