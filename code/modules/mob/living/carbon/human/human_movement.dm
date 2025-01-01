/mob/living/carbon/human/movement_delay()
	. = 0
	. += ..()
	. += GLOB.configuration.movement.human_delay
	. += dna.species.movement_delay(src)

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return HAS_TRAIT(src, TRAIT_MAGPULSE)

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(.) // did we actually move?
		if(!IS_HORIZONTAL(src) && !buckled && !throwing)
			for(var/obj/item/organ/external/splinted in splinted_limbs)
				splinted.update_splints()

	if(!has_gravity(loc))
		return

	var/obj/item/clothing/shoes/S = shoes

	if(S && !IS_HORIZONTAL(src) && loc == NewLoc)
		SEND_SIGNAL(S, COMSIG_SHOES_STEP_ACTION)

	//Bloody footprints
	var/turf/T = get_turf(src)
	var/obj/item/organ/external/l_foot = get_organ("l_foot")
	var/obj/item/organ/external/r_foot = get_organ("r_foot")
	var/hasfeet = TRUE
	if(!l_foot && !r_foot)
		hasfeet = FALSE

	if(shoes)
		if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
			for(var/obj/effect/decal/cleanable/blood/footprints/oldFP in T)
				if(oldFP && oldFP.blood_state == S.blood_state && oldFP.basecolor == S.blood_color)
					return
			//No oldFP or it's a different kind of blood
			S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state] - BLOOD_LOSS_PER_STEP)
			if(S.bloody_shoes[S.blood_state] > BLOOD_LOSS_IN_SPREAD)
				createFootprintsFrom(shoes, dir, T)
			update_inv_shoes()
	else if(hasfeet)
		if(bloody_feet && bloody_feet[blood_state])
			for(var/obj/effect/decal/cleanable/blood/footprints/oldFP in T)
				if(oldFP && oldFP.blood_state == blood_state && oldFP.basecolor == feet_blood_color)
					return
			bloody_feet[blood_state] = max(0, bloody_feet[blood_state] - BLOOD_LOSS_PER_STEP)
			if(bloody_feet[blood_state] > BLOOD_LOSS_IN_SPREAD)
				createFootprintsFrom(src, dir, T)
			update_inv_shoes()
