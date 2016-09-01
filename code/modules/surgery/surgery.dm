///Datum Surgery Helpers//
/datum/surgery
	var/name
	var/status = 1
	var/list/steps = list()
	/*
	var/eyes	=	0
	var/face	=	0
	var/appendix =	0
	var/ribcage =	0
	var/head_reattach = 0									//Steps in a surgery
	*/

	var/can_cancel = 1
	var/step_in_progress = 0
	var/list/in_progress = list()									//Actively performing a Surgery
	var/location = "chest"										//Surgery location
	var/requires_organic_bodypart = 1							//Prevents you from performing an operation on robotic limbs
	var/list/possible_locs = list() 							//Multiple locations -- c0
	var/obj/item/organ/organ_ref									//Operable body part
	var/current_organ = "organ"
	var/list/allowed_mob = list(/mob/living/carbon/human)

/datum/surgery/proc/can_start(mob/user, mob/living/carbon/target)
	// if 0 surgery wont show up in list
	// put special restrictions here
	return 1


/datum/surgery/proc/next_step(mob/user, mob/living/carbon/target)
	if(step_in_progress)	return

	var/datum/surgery_step/S = get_surgery_step()
	if(S)
		if(S.try_op(user, target, user.zone_sel.selecting, user.get_active_hand(), src))
			return 1
	return 0

/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[status]
	return new step_type


/datum/surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries -= src
	qdel(src)



/* SURGERY STEPS */
/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	// type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	var/implement_type = null

	// duration of the step
	var/time = 10

	var/name
	var/accept_hand = 0				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = 0

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

	var/list/allowed_mob = list()
	var/list/disallowed_mob = list()


/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/success = 0
	if(accept_hand)
		if(!tool)
			success = 1
	if(accept_any_item)
		if(tool && tool_quality(tool))
			success = 1
	else
		for(var/path in allowed_tools)
			if(istype(tool, path))
				implement_type = path
				if(tool_quality(tool))
					success = 1

	if(success)
		if(target_zone == surgery.location)
			initiate(user, target, target_zone, tool, surgery)
			return 1//returns 1 so we don't stab the guy in the dick or wherever.
	if(isrobot(user) && user.a_intent != I_HARM) //to save asimov borgs a LOT of heartache
		return 1
	return 0

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!can_use(user, target, target_zone, tool, surgery))
		return
	surgery.step_in_progress = 1

	if(begin_step(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = 0
		return

	var/advance = 0
	var/prob_chance = 100

	if(implement_type)	//this means it isn't a require nd or any item step.
		prob_chance = min(allowed_tools[implement_type], 100)
	prob_chance *= get_location_modifier(target)

	if(prob_chance > 100)//if we are using a super tool
		time = time/prob_chance //PLACEHOLDER VALUES
	
	if(do_after(user, time, target = target))


		if(prob(prob_chance) || isrobot(user))
			if(end_step(user, target, target_zone, tool, surgery))
				advance = 1
		else
			if(fail_step(user, target, target_zone, tool, surgery))
				advance = 1

		if(advance)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete(target)

	surgery.step_in_progress = 0

//returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	for(var/T in allowed_tools)
		if(istype(tool,T))
			return allowed_tools[T]
	return 0

// Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return 0

	if(allowed_mob)//can i just remove this and/or change it?
		for(var/species in allowed_mob)
			if(target.get_species() == species)
				return 1

	if(disallowed_mob)
		for(var/species in disallowed_mob)
			if(target.get_species() == species)
				return 0

	return 1

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	return 1

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(ishuman(target))
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(can_infect && affected)
			spread_germs_to_organ(affected, user)
	if(ishuman(user) && !(istype(target,/mob/living/carbon/alien)) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level)
			H.bloody_hands(target,0)
		if(blood_level > 1)
			H.bloody_body(target,0)
	return

// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	return null


/proc/spread_germs_to_organ(obj/item/organ/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E)) return
//	to_chat(world, "Germ spread: [E] : [E.owner]")
	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level
	if(!(E.status & ORGAN_ROBOT)) //Germs on robotic limbs bad
		E.germ_level = max(germ_level,E.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.


/proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while(gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1
