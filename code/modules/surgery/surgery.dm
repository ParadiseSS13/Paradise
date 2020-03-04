///Datum Surgery Helpers//
/datum/surgery
	var/current_stage = SURGERY_STAGE_START
	var/step_in_progress = FALSE
	var/list/in_progress = list()									//Actively performing a Surgery
	var/location = "chest"										//Surgery location
	var/obj/item/organ/organ_ref									//Operable body part

/datum/surgery/proc/next_step(mob/living/user, mob/living/carbon/target, obj/item/tool)
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
		var/result
		. = TRUE
		do
			S = new S.type() // Make a new step. Don't fuck this one up
			step_in_progress = TRUE
			result = S.try_op(user, target, location, tool, src)
			if(result)
				if(S.next_surgery_stage != SURGERY_STAGE_SAME)
					current_stage = S.next_surgery_stage
			step_in_progress = FALSE
		while(result == SURGERY_CONTINUE)

/datum/surgery/proc/get_surgery_steps(mob/user, mob/living/carbon/target, obj/item/tool)
	var/list/possible_steps = list()
	var/list/all_steps = GLOB.surgery_steps[current_stage] + GLOB.surgery_steps[SURGERY_STAGE_ALWAYS]

	for(var/i in all_steps)
		var/datum/surgery_step/S = i
		if(S.possible_locs?.len && !(location in S.possible_locs))
			continue
		if((S.accept_hand && !tool) || (tool && (S.accept_any_item \
			|| S.get_path_key_from_tool(tool))))
			if(S.can_use(user, target, location, tool, src))
				possible_steps[S.name] = S
	
	return sortInsert(possible_steps, /proc/compare_surgery_steps, TRUE)

// Used by the operating computer
/datum/surgery/proc/get_all_possible_steps_on_stage(mob/user, mob/living/carbon/target)
	var/list/all_steps = GLOB.surgery_steps[current_stage] + GLOB.surgery_steps[SURGERY_STAGE_ALWAYS]
	var/list/possible_steps = list()

	for(var/i in all_steps)
		var/datum/surgery_step/S = i
		if(S.possible_locs?.len && !(location in S.possible_locs))
			continue
		if(S.is_valid_target(target) && (isobserver(user) || S.is_valid_user(user)) && S.is_zone_valid(target, location, current_stage))
			possible_steps.Add(S)

	return sortInsert(possible_steps, /proc/compare_surgery_steps)

/* SURGERY STEPS */
/datum/surgery_step
	var/name			// Don't forget to name actual steps and make sure the name is unique. This will be used in the selecting logic
	
	var/priority = 1	//steps with higher priority will be put higher in the possible steps list



	var/surgery_start_stage = null 			// The stage that the surgery should be in should this step be an option. Can be a list of stages
	var/next_surgery_stage = null 			// The stage surgery will be in after this step completes
	var/list/possible_locs = null 			//Multiple locations -- c0
	var/requires_organic_bodypart = TRUE	//Prevents you from performing an operation on robotic limbs
	var/affected_organ_available = TRUE 	// If the surgery step actually needs an organ to be on the selected spot
	var/time = 10							// duration of the step
	

	var/allowed_surgery_tools = null		// The tools allowed for the surgery step	
	var/accept_hand = FALSE					//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = FALSE

	var/pain = TRUE
	// evil infection stuff that will make everyone hate me
	var/can_infect = FALSE
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

/proc/compare_surgery_steps(datum/surgery_step/A, datum/surgery_step/B)
	return A.priority < B.priority

/datum/surgery_step/New()
	. = ..()
	if(!islist(surgery_start_stage))
		surgery_start_stage = list(surgery_start_stage)

/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/success = FALSE
	
	if(target_zone != surgery.location || (!(SURGERY_STAGE_ALWAYS in surgery_start_stage) && !(surgery.current_stage in surgery_start_stage)) || !can_operate(target)) // No distance check. Not needed
		return FALSE
	var/tool_path_key = null
	if(tool)
		tool_path_key = get_path_key_from_tool(tool)
		if(accept_any_item || tool_path_key)
			success = TRUE
	else if(accept_hand)
		success = TRUE

	if(success)
		return initiate(user, target, target_zone, tool, surgery, tool_path_key)
	return FALSE

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, tool_path_key)
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
		if(tool && allowed_surgery_tools)
			if(!tool_path_key) // tools path ain't in the allowed tools.
				if(!accept_any_item)
					prob_chance = 0 // No chance of success... how did we even get here?!
			else
				prob_chance = allowed_surgery_tools[tool_path_key]
		prob_chance *= get_location_modifier(target)


		if(pain)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target //typecast to human
				prob_chance *= get_pain_modifier(H)//operating on conscious people is hard.

		if(prob(prob_chance) || isrobot(user))
			advance = end_step(user, target, target_zone, tool, surgery)
		else
			advance = fail_step(user, target, target_zone, tool, surgery)
		
		return advance

/datum/surgery_step/proc/get_path_key_from_tool(obj/item/tool)
	for(var/path in allowed_surgery_tools)
		if(istype(tool, path))
			return path

// Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	return TRUE

// Check if the user is valid for this surgery step
/datum/surgery_step/proc/is_valid_user(mob/living/user)
	return istype(user)

// Check if the given zone is valid on this surgery step for the given target and stage
/datum/surgery_step/proc/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	
	if(affected_organ_available)
		if(!affected)
			return FALSE
	else
		return !affected // No more checks needed

	if((requires_organic_bodypart && affected.is_robotic()))
		return FALSE
	return TRUE

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!is_valid_target(target) || !is_valid_user(user))
		return FALSE
	if(!is_zone_valid(target, target_zone, surgery.current_stage))
		return FALSE
	return TRUE

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
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

	if(tool && tool.blood_DNA && tool.blood_DNA.len) //germs from blood-stained tools
		germs += 30

	if(E.internal_organs.len)
		germs = germs / (E.internal_organs.len + 1) // +1 for the external limb this eventually applies to; let's not multiply germs now.
		for(var/obj/item/organ/internal/O in E.internal_organs)
			if(!O.is_robotic())
				O.germ_level += germs

	E.germ_level += germs
