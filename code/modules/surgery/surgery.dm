///Datum Surgery Helpers//
/datum/active_surgery
	var/can_cancel = 1
	var/step_in_progress = 0								// Semaphore to make sure we don't trip over ourself
	var/location = "chest"									//Surgery location
	var/obj/item/organ/organ_ref							//Operable body part
	var/current_organ = "organ"
	var/datum/stack/surgery_stack/steps_stack
	var/list/next_possible_steps = list()
	var/datum/surgery_step/next_step_to_do					// What step we will perform when "next_step" is called

/datum/active_surgery/New()
	steps_stack = new()

/datum/active_surgery/Destroy()
	steps_stack.Clear()
	organ_ref = null
	..()

/datum/active_surgery/proc/next_step(mob/user, mob/living/carbon/target)
	if(step_in_progress)	return
	to_chat(world, "Trying to do surgery!") // FIXME world print

	if(!next_step_to_do) // We're not decided what we'll do next
		var/obj/item/current_tool = user.get_active_hand()
		var/list/step_candidates = list()

		if(next_possible_steps.len <= 0)
			log_runtime(EXCEPTION("The surgery stack on [target] somehow was empty, and we didn't have a step to do! Call the military! The cops! The FBI! All of them!"))
			log_debug("Stack state:")
			for(var/thing in steps_stack.stack)
				log_debug("[thing]")

		for(var/thing in next_possible_steps)
			var/datum/surgery_step/possible_step = new thing
			if(possible_step.tool_quality(current_tool))
				to_chat(world, "[current_tool] qualifies for step: '[possible_step]'") // FIXME world print
				step_candidates[possible_step.name] = thing
			else
				to_chat(world, "[current_tool] does not qualify for step: '[possible_step]'") // FIXME world print

			qdel(possible_step)


		if(step_candidates.len > 1)
			var/C = input("Perform which step?", "Surgery", null, null) as null|anything in step_candidates
			if(!C)
				return 1
			next_step_to_do = step_candidates[C]
		else if(step_candidates.len == 1)
			// I'm doing this because BYOND lists are an amalgam of hash tables and arrays
			var/step_name = step_candidates[1]
			next_step_to_do = step_candidates[step_name]
		else
			to_chat(world, "We couldn't find something to do!") // FIXME world print
			return 0

	to_chat(world, "We're going to do [initial(next_step_to_do.name)]!") // FIXME world print
	var/datum/surgery_step/S = new next_step_to_do
	if(S)
		if(S.try_op(user, target, user.zone_sel.selecting, user.get_active_hand(), src))
			return 1
	return 0

/datum/active_surgery/proc/step_has_been_done(step_type)
	return (steps_stack && (step_type in steps_stack.stack))

/datum/active_surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries -= src
	qdel(src)

// This is to separate an active surgery being done, and a new class of surgeries that groups steps together
/datum/surgery
	var/name
	var/requires_organic_bodypart = 1							//Prevents you from performing an operation on robotic limbs
	var/list/possible_locs = list() 							//Multiple locations -- c0
	var/list/allowed_mob = list(/mob/living/carbon/human)
	var/list/steps = list()

// Put overrides whether you can do a surgery or not here
/datum/surgery/proc/can_start(mob/user, mob/living/carbon/target, target_zone)
	// if 0 surgery wont show up in list
	// put special restrictions here
	return 1

// Bundles together the special restrictions code, and general surgery checks.
// Don't override this!
/datum/surgery/proc/surgery_is_compatible(mob/user, mob/living/M, selected_zone)
	var/obj/item/organ/external/affecting
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		affecting = H.get_organ(check_zone(selected_zone))

	if(steps.len == 0)
		return 0 // We're a dummy surgery, that has no steps

	var/right_mob_type = 0
	for(var/path in allowed_mob)
		if(istype(M, path))
			right_mob_type = 1

	if(!right_mob_type && allowed_mob.len != 0)
		return 0

	if(!possible_locs.Find(selected_zone))
		return 0
	if(affecting && requires_organic_bodypart && affecting.status & ORGAN_ROBOT)
		return 0
	if(!can_start(user, M,selected_zone))
		return 0
	return 1

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

	var/steps_to_pop = 0
	var/list/steps_this_can_pop = list()

	var/painful = TRUE

/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/success = 0
	if(accept_hand)
		if(!tool)
			success = 1
	if(accept_any_item)
		if(tool && tool_quality(tool))
			success = 1
	else if(tool_quality(tool) > 0)
		success = 1

	if(success)
		if(target_zone == surgery.location)
			initiate(user, target, target_zone, tool, surgery)
			return 1//returns 1 so we don't stab the guy in the dick or wherever.
	return 0

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(!can_use(user, target, target_zone, tool, surgery))
		surgery.next_step_to_do = null
		return
	surgery.step_in_progress = 1

	var/speed_mod = 1

	if(begin_step(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = 0
		surgery.next_step_to_do = null
		return 1

	if(tool)
		speed_mod = tool.toolspeed
	var/prob_chance = 100

	if(tool)	//this means it isn't a require hand or any item step.
		prob_chance = tool_quality(tool)

	if(do_after(user, time * speed_mod, target = target))
		var/advance = 0
		prob_chance *= get_location_modifier(target)


		if(painful && ishuman(target))
			var/mob/living/carbon/human/H = target //typecast to human
			prob_chance *= get_pain_modifier(H)//operating on conscious people is hard.

		if(prob(prob_chance) || isrobot(user))
			if(end_step(user, target, target_zone, tool, surgery))
				advance = 1
		else
			if(fail_step(user, target, target_zone, tool, surgery))
				advance = 1

		if(advance)
			surgery.steps_stack.Push(src.type)
			check_for_further_advancing(user, target, target_zone, tool, surgery)
			for(var/i = 0, i < steps_to_pop, i++)
				if(steps_this_can_pop.Find(surgery.steps_stack.Top()))
					surgery.steps_stack.Pop()
			if(!surgery.steps_stack.is_empty())
				// Now that we've updated the stack, we rebuild the list of steps we can perform from here
				surgery.next_possible_steps.Cut()
				for(var/datum/surgery/S in GLOB.surgeries_list)
					if(!S.surgery_is_compatible(user, target, target_zone))
						continue
					var/datum/surgery_step/the_next_step = surgery.steps_stack.get_next_step(S)
					if(the_next_step && !surgery.next_possible_steps.Find(the_next_step))
						to_chat(world, "Adding step '[the_next_step]' to the possible steps! [S] is our template surgery!")
						surgery.next_possible_steps += the_next_step

	if(surgery.steps_stack.is_empty())
		surgery.complete(target)
	surgery.next_step_to_do = null
	surgery.step_in_progress = 0

//returns how well tool is suited for this step
// Return non-zero if you want to allow the tool to be used here
// Override this if you want to specify special conditions for your tools
// But you'll need to do a parent call if you want your tools list to be useful
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	if(isnull(tool) && accept_hand)
		return 100
	for(var/T in allowed_tools)
		if(istype(tool,T))
			return allowed_tools[T]
	return 0

// Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return FALSE
	return TRUE

/datum/surgery_step/proc/check_for_further_advancing(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	return 0

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	return 1

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
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
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
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
			if((!(BREATHLESS in H.mutations) || !(NO_BREATHE in H.dna.species.species_traits)) && !H.wear_mask) //wearing a mask helps preventing people from breathing cooties into open incisions
				germs += H.germ_level * 0.25

	for(var/obj/effect/decal/cleanable/M in view(2, E.loc))//germs from messes
		if(AStar(E.loc, M.loc, /turf/proc/Distance, 2, simulated_only = 0))
			if(!istype(M,/obj/effect/decal/cleanable/dirt))//dirt is too common
				germs++

	if(tool.blood_DNA && tool.blood_DNA.len) //germs from blood-stained tools
		germs += 30

	if(E.internal_organs.len)
		germs = germs / (E.internal_organs.len + 1) // +1 for the external limb this eventually applies to; let's not multiply germs now.
		for(var/obj/item/organ/internal/O in E.internal_organs)
			if(!O.is_robotic())
				O.germ_level += germs
	E.germ_level += germs

/datum/stack/surgery_stack

/*
Give the surgery_stack an operation, and this will return the next step of that operation
It'll return null if you can't do the next step in that surgery
*/
/datum/stack/surgery_stack/proc/get_next_step(datum/surgery/current_op)
	if(current_op.steps.len <= 0)
		return null
	if(stack.len <= 0)
		return current_op.steps[1]
	for(var/i in 1 to stack.len)
		if(current_op.steps[i] != stack[i])
			return null
	return current_op.steps[stack.len+1]

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
