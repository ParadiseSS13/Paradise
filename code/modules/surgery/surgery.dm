///Datum Surgery Helpers//
/datum/surgery
	var/name
	var/status = 1
	var/current_stage = SURGERY_STAGE_START

	var/can_cancel = 1
	var/step_in_progress = FALSE
	var/list/in_progress = list()									//Actively performing a Surgery
	var/location = "chest"										//Surgery location
	var/obj/item/organ/organ_ref									//Operable body part
	var/current_organ = "organ"
	var/list/allowed_mob = list(/mob/living/carbon/human)

/datum/surgery/proc/can_start(mob/user, mob/living/carbon/target)
	// if 0 surgery wont show up in list
	// put special restrictions here
	return 1


/datum/surgery/proc/next_step(mob/user, mob/living/carbon/target, obj/item/tool)
	if(step_in_progress)	return FALSE
	. = TRUE // Person 
	var/list/steps = get_surgery_steps(user, target, tool)
	var/datum/surgery_step/S
	if(steps.len == 0)
		return FALSE // No surgery steps. So stab that person in the ****
	if(steps.len == 1)
		S = steps[steps[1]]
	else
		var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in steps
		if(P && user && user.Adjacent(target) && tool == user.get_active_hand() && can_operate(target))
			S = steps[P]
	if(S)
		S = new S.type() // Make a new step. Don't fuck this one up
		step_in_progress = TRUE
		if(S.try_op(user, target, user.zone_selected, tool, src))
			if(S.next_surgery_stage != SURGERY_STAGE_SAME)
				current_stage = S.next_surgery_stage
		step_in_progress = FALSE

/datum/surgery/proc/get_surgery_steps(mob/user, mob/living/carbon/target, obj/item/tool)
	var/list/possible_steps = list()
	var/selected_zone = user.zone_selected
	var/list/all_steps = GLOB.surgery_steps[current_stage] + GLOB.surgery_steps[SURGERY_STAGE_ALWAYS]

	for(var/datum/surgery_step/S in all_steps)
		if(S.possible_locs?.len && !(selected_zone in S.possible_locs))
			continue
		if((S.accept_hand && !tool) || (tool && (S.accept_any_item \
			|| (S.allowed_surgery_behaviour in tool.surgery_behaviours))))
			if(S.can_use(user, target, location, tool, src))
				possible_steps[S.name] = S

	return possible_steps
	

/datum/surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries -= src
	qdel(src)



/* SURGERY STEPS */
/datum/surgery_step
	var/priority = 0	//steps with higher priority will be put higher in the possible steps list

	var/allowed_surgery_behaviour = null // The behaviours allowed for the surgery step

	var/surgery_start_stage = null 			// The stage that the surgery should be in should this step be an option
	var/next_surgery_stage = null 			// The stage surgery will be in after this step completes
	var/list/possible_locs = null 			//Multiple locations -- c0
	var/requires_organic_bodypart = TRUE	//Prevents you from performing an operation on robotic limbs
	// duration of the step
	var/time = 10

	var/name
	var/accept_hand = 0				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = 0

	var/pain = TRUE
	// evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

/datum/surgery_step/New()
	. = ..()
	if(!islist(surgery_start_stage))
		surgery_start_stage = list(surgery_start_stage)

/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/success = FALSE
	
	if(target_zone != surgery.location)
		return FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE
	if(accept_any_item)
		if(tool)
			success = TRUE
	else
		if(allowed_surgery_behaviour in tool.surgery_behaviours)
			success = TRUE

	if(success)
		return initiate(user, target, target_zone, tool, surgery) //returns TRUE so we don't stab the guy in the dick or wherever.
	return FALSE

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!can_use(user, target, target_zone, tool, surgery))
		return

	var/speed_mod = 1

	if(begin_step(user, target, target_zone, tool, surgery) == -1)
		return

	if(tool)
		speed_mod = tool.toolspeed

	if(do_after(user, time * speed_mod, target = target))
		var/advance = FALSE
		var/prob_chance = 100

		if(allowed_surgery_behaviour)
			prob_chance = tool.surgery_behaviours[allowed_surgery_behaviour]
		prob_chance *= get_location_modifier(target)


		if(pain)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target //typecast to human
				prob_chance *= get_pain_modifier(H)//operating on conscious people is hard.

		if(prob(prob_chance) || isrobot(user))
			if(end_step(user, target, target_zone, tool, surgery))
				advance = TRUE
		else
			if(fail_step(user, target, target_zone, tool, surgery))
				advance = TRUE
		
		return advance


// Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return FALSE
	return TRUE

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	return 1

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(ishuman(target))
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(can_infect && affected)
			spread_germs_to_organ(affected, user, tool)
	if(ishuman(user) && !(istype(target,/mob/living/carbon/alien)) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level)
			H.bloody_hands(target,0)
		if(blood_level > 1)
			H.bloody_body(target,0)
	return

// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	return null

/proc/spread_germs_to_organ(obj/item/organ/E, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(E) || E.is_robotic() || E.sterile)
		return

	var/germ_level = user.germ_level

	//germ spread from surgeon touching the patient
	if(user.gloves)
		germ_level = user.gloves.germ_level
	E.germ_level = max(germ_level, E.germ_level)
	spread_germs_by_incision(E, tool) //germ spread from environement to patient

/proc/spread_germs_by_incision(obj/item/organ/external/E,obj/item/tool)
	if(!istype(E, /obj/item/organ/external))
		return

	var/germs = 0

	for(var/mob/living/carbon/human/H in view(2, E.loc))//germs from people
		if(AStar(E.loc, H.loc, /turf/proc/Distance, 2, simulated_only = 0))
			if(!((BREATHLESS in H.mutations) || (NO_BREATHE in H.dna.species.species_traits)) && !H.wear_mask) //wearing a mask helps preventing people from breathing cooties into open incisions
				germs += H.germ_level * 0.25

	for(var/obj/effect/decal/cleanable/M in view(2, E.loc))//germs from messes
		if(AStar(E.loc, M.loc, /turf/proc/Distance, 2, simulated_only = 0))
			germs++

	if(tool.blood_DNA && tool.blood_DNA.len) //germs from blood-stained tools
		germs += 30

	if(E.internal_organs.len)
		germs = germs / (E.internal_organs.len + 1) // +1 for the external limb this eventually applies to; let's not multiply germs now.
		for(var/obj/item/organ/internal/O in E.internal_organs)
			if(!O.is_robotic())
				O.germ_level += germs

	E.germ_level += germs

/*
/proc/sort_surgeries()
	var/gap = GLOB.surgery_steps.len
	var/swapped = 1
	while(gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= GLOB.surgery_steps.len; i++)
			var/datum/surgery_step/l = GLOB.surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = GLOB.surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				GLOB.surgery_steps.Swap(i, gap + i)
				swapped = 1
*/