/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood

	var/germ_level = 0		// INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE

	proc/process()
		return 0

	proc/receive_chem(chemical as obj)
		return 0

/datum/organ/proc/get_icon()
	return icon('icons/mob/human.dmi',"blank")

//Germs
/datum/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/datum/organ/O = pick(organs)
		O.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/datum/organ/proc/add_autopsy_data(var/used_weapon, var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

/mob/living/carbon/human/var/list/organs = list()
/mob/living/carbon/human/var/list/organs_by_name = list() // map organ names to organs
/mob/living/carbon/human/var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs()
	number_wounds = 0
	var/leg_tally = 2
	var/force_process = 0
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick
	if(force_process)
		bad_external_organs.Cut()
		for(var/datum/organ/external/Ex in organs)
			bad_external_organs += Ex

	//processing internal organs is pretty cheap, do that first.
	for(var/name in internal_organs_by_name)
		var/datum/organ/internal/I = internal_organs_by_name[name]
		I.process()

	//Check arms and legs for existence
	can_stand = 2 //can stand on both legs
	var/datum/organ/external/F = organs_by_name["l_foot"]
	if(F.status & ORGAN_DESTROYED)
		can_stand--

	F = organs_by_name["r_foot"]
	if(F.status & ORGAN_DESTROYED)
		can_stand--

	if(!force_process && !bad_external_organs.len)
		return

	for(var/datum/organ/external/E in bad_external_organs)
		if(!E)
			continue
		if(!E.need_process())
			bad_external_organs -= E
			continue
		else
			E.process()
			number_wounds += E.number_wounds

			if (!lying && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if (E.is_broken() && E.internal_organs && prob(15))
					var/datum/organ/internal/I = pick(E.internal_organs)
					custom_pain("You feel broken bones moving in your [E.display_name]!", 1)
					I.take_damage(rand(3,5))

				//Moving makes open wounds get infected much faster
				if (E.wounds.len)
					for(var/datum/wound/W in E.wounds)
						if (W.infection_check())
							W.germ_level += 1

			if(E.name in list("l_leg","l_foot","r_leg","r_foot") && !lying)
				if (!E.is_usable() || E.is_malfunctioning() || (E.is_broken() && !(E.status & ORGAN_SPLINTED)))
					leg_tally--			// let it fail even if just foot&leg

	// standing is poor
	if(leg_tally <= 0 && !paralysis && !(lying || resting) && prob(5))
		if(species && species.flags & NO_PAIN)
			emote("scream")
		emote("collapse")
		paralysis = 10


