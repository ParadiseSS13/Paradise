///Datum Surgery Helpers//


/datum/surgery
	/// Name of the surgery
	var/name
	/// Description of the surgery
	var/desc
	/// How far along we are in a surgery being performed.
	var/step_number = 1
	/// Surgical steps that go into performing this procedure
	var/list/steps = list()
	/// Whether this surgery can be stopped after the first step with a cautery
	var/can_cancel = TRUE
	/// If we're currently performing a step
	var/step_in_progress = FALSE
	/// Location of the surgery
	var/location = BODY_ZONE_CHEST
	/// Whether we can perform the surgery on a robotic limb
	var/requires_organic_bodypart = TRUE							//Prevents you from performing an operation on robotic limbs
	/// Whether you need to remove clothes to perform the surgery
	var/ignore_clothes = TRUE
	/// Body locations this surgery can be performed on
	var/list/possible_locs = list()
	/// Surgery is only available if the target bodypart is present (or if it's missing)
	var/requires_bodypart = TRUE
	/// Surgery step speed modifier
	var/speed_modifier = 0
	/// Some surgeries might work on limbs that don't really exist (like chainsaw arms or flashlight eyes)
	var/requires_real_bodypart = TRUE
	/// Does the victim (patient) need to be lying down?
	var/lying_required = TRUE
	/// Can the surgery be performed on yourself?
	var/self_operable = FALSE
	/// Don't show this surgery if this type exists. Set to /datum/surgery if you want to hide a "base" surgery.
	var/replaced_by
	/// Mobs on which this can be performed
	var/list/target_mobtypes = list(/mob/living/carbon/human)
	/// Target of the surgery
	var/mob/living/carbon/target
	/// Body part the surgery is currently being performed on. Useful for checking to see if the organ desired is still in the body after the surgery has begun.
	var/obj/item/organ/external/organ_to_manipulate
	/// Whether or not this should be a selectable surgery at all
	var/abstract = FALSE
	/// Whether this surgery should be cancelled when an organ change happens. (removed if requires bodypart, or added if doesn't require bodypart)
	var/cancel_on_organ_change = TRUE


/datum/surgery/New(atom/surgery_target, surgery_location, surgery_bodypart)
	..()
	if(!surgery_target)
		return
	target = surgery_target
	target.surgeries += src
	if(surgery_location)
		location = surgery_location
	if(!surgery_bodypart)
		return
	organ_to_manipulate = surgery_bodypart
	if(cancel_on_organ_change)
		if(requires_bodypart)
			RegisterSignal(surgery_target, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_remove))
		else
			RegisterSignal(surgery_target, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_organ_insert))

/datum/surgery/Destroy()
	if(target)
		target.surgeries -= src
	target = null
	organ_to_manipulate = null
	return ..()

/// Get whether the target organ is compatible with the current surgery.
/datum/surgery/proc/is_organ_compatible(obj/item/organ/external/affecting)
	if(!affecting || !istype(affecting))
		return FALSE
	return requires_organic_bodypart && affecting.is_robotic() || !requires_organic_bodypart && !affecting.is_robotic()


/**
 * Whether or not we can start this surgery.
 * If this returns FALSE, this surgery won't show up in the list.
 */
/datum/surgery/proc/can_start(mob/user, mob/living/carbon/target)
	if(replaced_by == /datum/surgery)
		return FALSE

	return TRUE

/**
 * Try to perform the next step in the current operation.
 * This gets called in the attack chain, and as such returning FALSE in here means that the target
 * will be hit with whatever's in your hand.
 *
 * The return is passed to the attack chain, so return TRUE to stop any sort of afterattack.
 */
/datum/surgery/proc/next_step(mob/user, mob/living/carbon/target)
	if(location != user.zone_selected)
		return FALSE

	if(step_in_progress)
		return FALSE

	if(!self_operable && user == target)
		return FALSE

	if(lying_required && !on_operable_surface(target))
		return FALSE

	var/datum/surgery_step/step = get_surgery_step()
	if(step)
		var/obj/item/tool = user.get_active_hand()
		if(step.try_op(user, target, user.zone_selected, tool, src))
			return TRUE
		// If it's a surgery initiator, make sure it calls its attack chain down the line.
		// Make sure this comes after the operation though, especially for things like scalpels
		if(tool && tool.GetComponent(/datum/component/surgery_initiator))
			return FALSE
		if(tool && HAS_TRAIT(tool, TRAIT_SURGICAL))
			to_chat(user, "<span class='warning'>This step requires a different tool!</span>")
			return TRUE
	return FALSE

/**
 * Get the current surgery step we're on
 */
/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[step_number]
	return new step_type

/**
 * Get the next step in the current surgery, or null if we're on the last one.
 */
/datum/surgery/proc/get_surgery_next_step()
	if(step_number < length(steps))
		var/step_type = steps[step_number + 1]
		return new step_type
	else
		return null

/datum/surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries -= src
	qdel(src)


/**
 * Handle an organ's insertion or removal mid-surgery.
 * If cancel_on_organ_change is true, then this will cancel the surgery in certain cases.
 */
/datum/surgery/proc/handle_organ_state_change(mob/living/carbon/organ_owner, obj/item/organ/external/organ, insert)
	SIGNAL_HANDLER  // only called from signals anyway, better safe than sorry
	if(!istype(organ_owner) || !istype(organ) || !cancel_on_organ_change)  // only fire this on external organs
		return

	if(requires_bodypart && organ != organ_to_manipulate)  // we removed a different organ
		return

	if((requires_bodypart && !insert) || (!requires_bodypart && insert))
		add_attack_logs(null, organ_owner, "had [src] canceled by organ [insert ? "insertion" : "removal"]")
		qdel(src)

/datum/surgery/proc/on_organ_insert(mob/living/carbon/organ_owner, obj/item/organ/external/organ)
	SIGNAL_HANDLER  // COMSIG_CARBON_GAIN_ORGAN
	handle_organ_state_change(organ_owner, organ, TRUE)

/datum/surgery/proc/on_organ_remove(mob/living/carbon/organ_owner, obj/item/organ/external/organ)
	SIGNAL_HANDLER  // COMSIG_CARBON_LOSE_ORGAN
	handle_organ_state_change(organ_owner, organ, FALSE)



/* SURGERY STEPS */
/datum/surgery_step
	var/name
	/// Type path of tools that can be used to complete this step. Format is `path = probability of success`.
	/// If the tool has a specific surgery tooltype, you can use that as a key as well.
	var/list/allowed_tools = null
	/// The current type of implement from allowed_tools in use. This has to be stored, as the typepath of the tool might not match the list type (such as if we're using tool behavior)
	var/implement_type = null
	/// does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_hand = FALSE
	/// Does the surgery step accept any item? If true, ignores implements. Compatible with accept_hand.
	var/accept_any_item = FALSE
	/// duration of the step
	var/time = 1 SECONDS
	/// Is this step repeatable by using the same tool again after it's finished?
	/// Make sure it isn't the last step, or it's used in a cancellable surgery. Otherwise, you might get stuck in a loop!
	var/repeatable = FALSE
	/// List of chems needed in the mob to complete the step. Even on success, this step will have no effect if the required chems aren't in the mob.
	var/list/chems_needed = list()
	/// Do we require any of the needed chems, or all of them?
	var/require_all_chems = TRUE
	/// Whether silicons ignore any probabilities (and are therefore "perfect" surgeons)
	var/silicons_ignore_prob = FALSE
	/// How many times this step has been automatically repeated.
	var/times_repeated = 0

	// evil infection stuff that will make everyone hate me

	/// Whether this surgery step can cause an infection.
	var/can_infect = FALSE
	/// How much blood this step can get on surgeon. See SURGERY_BLOODSPREAD_* defines
	var/blood_level = SURGERY_BLOODSPREAD_NONE

/**
 * Whether or not the tool being used is usable for the surgery.
 * Checks both the tool itself as well as any tool behaviors defined in allowed_tools.
 * Arguments:
 * * user - User handling the tool.
 * * tool - The tool (or item) being used in this surgery step.
 * Returns TRUE if the tool can be used, or FALSE otherwise
 */
/datum/surgery_step/proc/is_valid_tool(mob/living/user, obj/item/tool)

	var/success = FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE
		if(isrobot(user) && istype(tool, /obj/item/gripper_medical))
			success = TRUE

	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = TRUE
	else if(tool)
		if(istype(tool, /obj/item/scalpel/laser/manager/debug))
			// ok this is a meme but only use it if we'd actually be replacing a tool
			for(var/key in allowed_tools)
				if(!ispath(key) && (key in GLOB.surgery_tool_behaviors))
					allowed_tools[tool.type] = 100
					implement_type = tool.type
					success = TRUE
					break

		for(var/key in allowed_tools)
			var/match = FALSE
			if(ispath(key) && istype(tool, key))
				match = TRUE
			else if(tool.tool_behaviour == key)
				match = TRUE

			if(match)
				implement_type = key
				if(tool_check(user, tool))
					success = TRUE
					break

	return success

/**
 * Try to perform an operation on a user.
 * Arguments:
 * * user - The user performing the surgery.
 * * target - The user on whom the surgery is being performed.
 * * target_zone - the zone the user is targeting for the surgery.
 * * tool - The object that the user is using to perform the surgery (optional)
 * * surgery - The surgery being performed.
 * Returns TRUE if the step was a success, or FALSE if the step can't be performed for some reason.
 */
/datum/surgery_step/proc/try_op(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	if(is_valid_tool(user, tool))
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone) || surgery.ignore_clothes)
				return initiate(user, target, target_zone, tool, surgery)
			to_chat(user, "<span class='warning'>You need to expose [target]'s [parse_zone(target_zone)] before you can perform surgery on it!")
			return SURGERY_INITIATE_FAILURE //returns TRUE so we don't stab the guy in the dick or wherever.

	if(repeatable)
		// you can continuously, manually, perform a step, so long as you continue to use the correct tool.
		// if you use the wrong tool, though, it'll try to start the next surgery step with the tool you have in your hand.
		// Note that this separate from returning the surgery_step_* defines in end/fail_step, which will automatically retry the surgery.
		var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
		next_step.times_repeated = times_repeated + 1
		if(next_step)
			surgery.step_number++
			if(next_step.try_op(user, target, user.zone_selected, user.get_active_hand(), surgery))
				return SURGERY_INITIATE_SUCCESS
			else
				surgery.step_number--

	return SURGERY_INITIATE_CONTINUE_CHAIN

/**
 * Determines whether or not this surgery step can repeat if its end/fail steps returned SURGERY_STEP_RETRY.
 *
 * Arguments:
 * * user - mob performing the surgery
 * * target - mob the surgery is being performed on
 * * target_zone - body zone of the surgery
 * * tool - tool used for the surgery
 * * surgery - the operation this surgery step is a part of
 *
 * If this returns TRUE, the step will automatically retry. If not, the user will have to manually start the step again.
 *
 */
/datum/surgery_step/proc/can_repeat(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool && istype(tool) && HAS_TRAIT(tool, TRAIT_ADVANCED_SURGICAL))
		return TRUE
	if(HAS_TRAIT(user, TRAIT_REPEATSURGERY))
		return TRUE
	return FALSE

/**
 * Initiate and really perform the surgery itself.
 * This includes the main do-after and the checking of probabilities for successful surgeries.
 * If try_to_fail is TRUE, then this surgery will be deliberately failed out of.
 *
 * Returns TRUE if the surgery should proceed to the next step, or FALSE otherwise.
 */
/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)

	surgery.step_in_progress = TRUE

	var/speed_mod = 1
	var/advance = FALSE
	var/retry = FALSE
	var/prob_success = 100

	var/begin_step_result = begin_step(user, target, target_zone, tool, surgery)
	if(begin_step_result == SURGERY_BEGINSTEP_ABORT)
		surgery.step_in_progress = FALSE
		return SURGERY_INITIATE_FAILURE

	if(begin_step_result == SURGERY_BEGINSTEP_SKIP)
		surgery.step_number++
		if(surgery.step_number > length(surgery.steps))
			surgery.complete(target)

		surgery.step_in_progress = FALSE
		return SURGERY_INITIATE_SUCCESS

	if(tool)
		speed_mod = tool.toolspeed

	// Using an unoptimal tool slows down your surgery
	var/implement_speed_mod = 1
	if(implement_type)
		implement_speed_mod = allowed_tools[implement_type] / 100.0

	// They also have some interesting ways that surgery success/fail prob get evaluated, maybe worth looking at
	speed_mod /= (get_location_modifier(target) * 1 + surgery.speed_modifier) * implement_speed_mod
	var/modded_time = time * speed_mod

	if(slowdown_immune(user))
		modded_time = time

	if(implement_type)	// If this is set, we aren't in an allow_hand or allow_any_item step.
		prob_success = allowed_tools[implement_type]
	prob_success *= get_location_modifier(target)

	if(!do_after(user, modded_time, target = target))
		surgery.step_in_progress = FALSE
		return SURGERY_INITIATE_INTERRUPTED

	var/chem_check_result = chem_check(target)
	var/pain_mod = deal_pain(user, target, target_zone, tool, surgery)
	prob_success *= pain_mod

	var/step_result

	if((prob(prob_success) || silicons_ignore_prob && isrobot(user)) && chem_check_result && !try_to_fail)
		step_result = end_step(user, target, target_zone, tool, surgery)
	else
		step_result = fail_step(user, target, target_zone, tool, surgery)
	switch(step_result)
		if(SURGERY_STEP_CONTINUE)
			advance = TRUE
		if(SURGERY_STEP_RETRY_ALWAYS)
			retry = TRUE
		if(SURGERY_STEP_RETRY)
			if(can_repeat(user, target, target_zone, tool, surgery))
				retry = TRUE

	if(retry)
		// if at first you don't succeed...
		return .(user, target, target_zone, tool, surgery, try_to_fail)

	// Bump the surgery status
	// if it's repeatable, don't let it truly "complete" though
	if(advance && !repeatable)
		surgery.step_number++
		if(surgery.step_number > length(surgery.steps))
			surgery.complete(target)

	surgery.step_in_progress = FALSE
	if(advance)
		return SURGERY_INITIATE_SUCCESS
	else
		return SURGERY_INITIATE_FAILURE

/**
 * Try to inflict pain during a surgery, a surgeon's dream come true.
 * This will wake up the user if they're voluntarily sleeping.
 *
 * Returns the success rate that the user's amount of pain would deal, while also handling extra pain behavior.
 */
/datum/surgery_step/proc/deal_pain(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	. = 1
	if(!surgery.requires_organic_bodypart)
		return
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	var/pain_mod = get_pain_modifier(H)

	// don't let people sit on the optable and sleep verb
	var/datum/status_effect/incapacitating/sleeping/S = H.IsSleeping()
	if(S?.voluntary)
		H.SetSleeping(0) // wake up people who are napping through the surgery
		if(pain_mod < 0.95)
			to_chat(H, "<span class='danger'>The surgery on your [parse_zone(target_zone)] is agonizingly painful, and rips you out of your shallow slumber!</span>")
		else
			// Still wake people up, but they shouldn't be as alarmed.
			to_chat(H, "<span class='warning'>The surgery being performed on your [parse_zone(target_zone)] wakes you up.</span>")
	return pain_mod //operating on conscious people is hard.

/**
 * Get whether the tool should be usable in its current state. Useful for checks to see if a welder is on, for example.
 *
 * Arguments:
 * * user - The user using the tool.
 * * tool - The tool in use.
 *
 */
/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE

/**
 * Check for mobs that would be immune to surgery slowdowns/speedups.
 */
/datum/surgery_step/proc/slowdown_immune(mob/living/user)
	if(isrobot(user))
		return TRUE
	return FALSE

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	SHOULD_CALL_PARENT(TRUE)
	if(ishuman(target))
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(can_infect && affected)
			spread_germs_to_organ(affected, user, tool)
	if(ishuman(user) && !isalien(target) && prob(60))
		var/mob/living/carbon/human/H = user
		switch(blood_level)
			if(SURGERY_BLOODSPREAD_HANDS)
				H.bloody_hands(target, 0)
			if(SURGERY_BLOODSPREAD_FULLBODY)
				H.bloody_body(target)
	return

/**
 * Finish a surgery step, performing anything that runs on the tail-end of a successful surgery.
 * This runs if the surgery step passes the probability check, and therefore is a success.
 *
 * Should return SURGERY_STEP_CONTINUE to advance the surgery, though may return SURGERY_STEP_INCOMPLETE to keep the surgery step from advancing.
 */
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return SURGERY_STEP_CONTINUE

/**
 * Play out the failure state of a surgery step.
 * This runs if the surgery step fails the probability check, the right chems weren't present, or if the user deliberately failed the surgery.
 *
 * Should return SURGERY_STEP_INCOMPLETE to prevent the surgery step from advancing, though may return SURGERY_STEP_CONTINUE to advance to the next step regardless.
 */
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return SURGERY_STEP_INCOMPLETE

/**
 * Get the action that will be performed during this surgery step, in context of the surgery it is a part of.
 *
 * * surgery - A surgery in progress.
 */
/datum/surgery_step/proc/get_step_information(datum/surgery/surgery)
	return name

/**
 * Spread some nasty germs to an organ.
 *
 * * target_organ - The organ to try spreading germs to.
 * * user - The user who's manipulating the organ.
 * * tool - The tool the user is using to mess with the organ.
 */
/proc/spread_germs_to_organ(obj/item/organ/target_organ, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(target_organ) || target_organ.is_robotic() || target_organ.sterile)
		return

	var/germ_level = user.germ_level

	// germ spread from surgeon touching the patient
	if(user.gloves)
		germ_level = user.gloves.germ_level
	target_organ.germ_level = max(germ_level, target_organ.germ_level)
	spread_germs_by_incision(target_organ, tool) //germ spread from environement to patient

/**
 * Spread germs directly from a tool.
 *
 * * E - An external organ being operated on.
 * * tool - The tool performing the operation.
 */
/proc/spread_germs_by_incision(obj/item/organ/external/E, obj/item/tool)
	if(!isorgan(E))
		return

	var/germs = 0

	for(var/mob/living/carbon/human/H in view(2, E.loc))//germs from people
		if(length(get_path_to(E.loc, H.loc, max_distance = 2, simulated_only = FALSE)))
			if(!HAS_TRAIT(H, TRAIT_NOBREATH) && !H.wear_mask) //wearing a mask helps preventing people from breathing cooties into open incisions
				germs += H.germ_level * 0.25

	for(var/obj/effect/decal/cleanable/M in view(2, E.loc))//germs from messes
		if(length(get_path_to(E.loc, M.loc, 2, simulated_only = FALSE)))
			germs++

	if(tool && tool.blood_DNA && length(tool.blood_DNA)) //germs from blood-stained tools
		germs += 30

	if(length(E.internal_organs))
		germs = germs / (length(E.internal_organs) + 1) // +1 for the external limb this eventually applies to; let's not multiply germs now.
		for(var/obj/item/organ/internal/O in E.internal_organs)
			if(!O.is_robotic())
				O.germ_level += germs

	E.germ_level += germs

/**
 * Check that the target contains the chems we expect them to.
 */
/datum/surgery_step/proc/chem_check(mob/living/target)
	if(!LAZYLEN(chems_needed))
		return TRUE

	if(require_all_chems)
		. = TRUE
		for(var/reagent in chems_needed)
			if(!target.reagents.has_reagent(reagent))
				return FALSE
	else
		. = FALSE
		for(var/reagent in chems_needed)
			if(target.reagents.has_reagent(reagent))
				return TRUE
