/****************************************************
				INTERNAL ORGANS
****************************************************/

/datum/organ/internal
	// amount of damage to the organ
	var/damage = 0
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/parent_organ = "chest"
	var/desc = ""
	var/list/emplevel = list(0,0,0)  // [1] is the highest amount of emp damage, [3] is the least
	var/damagelevel = 1

/datum/organ/internal/proc/rejuvenate()
	damage=0

/datum/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/datum/organ/internal/proc/is_broken()
	return damage >= min_broken_damage

/datum/organ/internal/New(mob/living/carbon/human/H)
	..()
	if(H)
		var/datum/organ/internal/check = H.internal_organs_by_name[name]
		if(check)
			remove(H)
		add(H)


/datum/organ/internal/process()
	//Process infections

	if (owner.species && owner.species.flags & IS_PLANT)
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

		if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
			germ_level--

		if (germ_level >= INFECTION_LEVEL_ONE/2)
			//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
			if(antibiotics < 5 && prob(round(germ_level/6)))
				germ_level++

		if (germ_level >= INFECTION_LEVEL_TWO)
			var/datum/organ/external/parent = owner.get_organ(parent_organ)
			//spread germs
			if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
				parent.germ_level++

			if (prob(3))	//about once every 30 seconds
				take_damage(1,silent=prob(30))

/datum/organ/internal/proc/take_damage(amount, var/silent=0)

	damage += amount * damagelevel

	var/datum/organ/external/parent = owner.get_organ(parent_organ)
	if (!silent)
		owner.custom_pain("Something inside your [parent.display_name] hurts a lot.", 1)

/datum/organ/internal/proc/emp_act(severity)

	if(emplevel[1])
		take_damage(emplevel[severity])

/datum/organ/internal/proc/mechanize() //Being used to make robutt hearts, etc

/datum/organ/internal/proc/mechassist() //Used to add things like pacemakers, etc

/datum/organ/internal/proc/remove(var/mob/living/carbon/human/H)
	if(H)
		var/datum/organ/internal/toremove = H.internal_organs_by_name[name]
		if(toremove)
			var/datum/organ/external/E = H.organs_by_name[toremove.parent_organ]
			for (var/datum/organ/internal/I in E.internal_organs)
				if (I == toremove)
					I = null

	return

/datum/organ/internal/proc/add(var/mob/living/carbon/human/H)
	var/datum/organ/external/P = H.organs_by_name[parent_organ]
	if(P)
		if(P.internal_organs == null)
			P.internal_organs = list()
		P.internal_organs += src
	H.internal_organs_by_name[name] = src
	owner = H
	return

/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/

/datum/organ/internal/heart
	name = "heart"
	parent_organ = "chest"

/datum/organ/internal/heart/robotic
	damagelevel = 0.8
	emplevel = list(40,15,10)
	desc = "Mechanical"

/datum/organ/internal/heart/robotic/process()
	germ_level = 0
	return

/datum/organ/internal/heart/mechanize()
	new /datum/organ/internal/heart/robotic(owner)
	return

/datum/organ/internal/heart/assisted
	min_bruised_damage = 15
	min_broken_damage = 35
	emplevel = list(20,7,3)
	desc = "Assisted"

/datum/organ/internal/heart/mechassist()
	new /datum/organ/internal/heart/assisted(owner)
	return

/datum/organ/internal/lungs
	name = "lungs"
	parent_organ = "chest"

/datum/organ/internal/lungs/process()
	..()
	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			spawn owner.emote("me", 1, "coughs up blood!")
			owner.drip(10)
		if(prob(4))
			spawn owner.emote("me", 1, "gasps for air!")
			owner.losebreath += 15

/datum/organ/internal/lungs/robotic
	damagelevel = 0.8
	emplevel = list(40,15,10)
	desc = "Mechanical"

/datum/organ/internal/lungs/robotic/process()
	germ_level = 0
	return

/datum/organ/internal/lungs/mechanize()
	new /datum/organ/internal/lungs/robotic(owner)
	return

/datum/organ/internal/lungs/assisted
	min_bruised_damage = 15
	min_broken_damage = 35
	emplevel = list(20,7,3)
	desc = "Assisted"

/datum/organ/internal/lungs/mechassist()
	new /datum/organ/internal/lungs/assisted(owner)
	return

/datum/organ/internal/liver
	name = "liver"
	parent_organ = "chest"
	var/process_accuracy = 10

/datum/organ/internal/liver/process()
	..()
	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			owner << "\red Your skin itches."
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % process_accuracy == 0)
		if(src.damage < 0)
			src.damage = 0

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * process_accuracy
			//Damaged one shares the fun
			else
				var/datum/organ/internal/O = pick(owner.internal_organs_by_name)
				if(O)
					O.damage += 0.2  * process_accuracy

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
			src.damage -= 0.2 * process_accuracy

		// Damaged liver means some chemicals are very dangerous
		if(src.damage >= src.min_bruised_damage)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/ethanol))
					owner.adjustToxLoss(0.1 * process_accuracy)

			// Can't cope with toxins at all
			for(var/toxin in list("toxin", "plasma", "sacid", "pacid", "cyanide", "lexorin", "amatoxin", "chloralhydrate", "carpotoxin", "zombiepowder", "mindbreaker"))
				if(owner.reagents.has_reagent(toxin))
					owner.adjustToxLoss(0.3 * process_accuracy)

/datum/organ/internal/liver/robotic
	damagelevel = 0.8
	emplevel = list(40,15,10)

/datum/organ/internal/liver/robotic/process()
	germ_level = 0
	return

/datum/organ/internal/liver/mechanize()
	new /datum/organ/internal/liver/robotic(owner)
	return

/datum/organ/internal/liver/assisted
	min_bruised_damage = 15
	min_broken_damage = 35
	emplevel = list(20,7,3)
	desc = "Assisted"

/datum/organ/internal/liver/mechassist()
	new /datum/organ/internal/liver/assisted(owner)
	return

/datum/organ/internal/kidney
	name = "kidney"
	parent_organ = "chest"

/datum/organ/internal/kidney/robotic
	damagelevel = 0.8
	emplevel = list(40,15,10)
	desc = "Mechanical"

/datum/organ/internal/kidney/robotic/process()
	germ_level = 0
	return

/datum/organ/internal/kidney/mechanize()
	new /datum/organ/internal/kidney/robotic(owner)
	return

/datum/organ/internal/kidney/assisted
	min_bruised_damage = 15
	min_broken_damage = 35
	emplevel = list(20,7,3)
	desc = "Assisted"

/datum/organ/internal/kidney/mechassist()
	new /datum/organ/internal/kidney/assisted(owner)
	return

/datum/organ/internal/brain
	name = "brain"
	parent_organ = "head"

/datum/organ/internal/brain/robotic
	damagelevel = 0.8
	emplevel = list(40,15,10)
	desc = "Mechanical"

/datum/organ/internal/brain/robotic/process()
	germ_level = 0
	return

/datum/organ/internal/brain/mechanize()
	new /datum/organ/internal/brain/robotic(owner)
	return

/datum/organ/internal/brain/assisted
	min_bruised_damage = 15
	min_broken_damage = 35
	emplevel = list(20,7,3)
	desc = "Assisted"

/datum/organ/internal/brain/mechassist()
	new /datum/organ/internal/brain/assisted(owner)
	return

/datum/organ/internal/eyes
	name = "eyes"
	parent_organ = "head"

/datum/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20

/datum/organ/internal/eyes/robotic
	damagelevel = 0.8
	emplevel = list(40,15,10)
	desc = "Mechanical"

/datum/organ/internal/eyes/robotic/process()
	germ_level = 0
	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20

/datum/organ/internal/eyes/mechanize()
	new /datum/organ/internal/eyes/robotic(owner)
	return

/datum/organ/internal/eyes/assisted
	min_bruised_damage = 15
	min_broken_damage = 35
	emplevel = list(20,7,3)
	desc = "Assisted"

/datum/organ/internal/eyes/mechassist()
	new /datum/organ/internal/eyes/assisted(owner)
	return