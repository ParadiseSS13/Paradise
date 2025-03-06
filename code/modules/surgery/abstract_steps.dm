/**
 * This file consists of how we manage somewhat non-linear surgeries.
 * Essentially what goes on here is that we have some "proxy" surgery steps that get inserted into existing surgeries at key points.
 * Depending on the tool used after that point, the proxy step chooses the next step(s) that should be executed.
 *
 * These proxy steps use a list of surgeries, so a full procedure can be inserted into an existing surgery. Just make sure that the user's state
 * after an intermediate surgery is (in the context of the surgery) identical to before the intermediate surgery. Don't heal things that will
 * need to be healed during the surgery, for example.
 *
 * Adding a new intermediate surgery:
 * - Define a new intermediate surgery datum with the list of steps that you want to inject. This forms one surgery "branch".
 * - Define a new proxy surgery step with branches containing the typepath of your new surgery datum.
 * - Insert that surgery step into an existing surgery.
 */

#define SURGERY_TOOL_HAND "hand"
#define SURGERY_TOOL_ANY "any"

/**
 * A partial surgery that consists of a few steps that may be found in the middle of another operation.
 * An existing surgery can yield to an intermediate surgery for a few steps by way of a proxy surgery_step.
 */
/datum/surgery/intermediate
	abstract = TRUE

/**
 * Here's the special sauce: a surgery step that can pretend to be a few different surgery steps.
 * These proxy steps will, depending on the tool that's used, either continue to the next surgery step, or temporarily spin off a new surgery
 * by adding new steps to the current surgery.
 */
/datum/surgery_step/proxy
	name = "Intermediate Operation"
	/// Optional surgery TYPES that we can branch out to
	/// Note that these must not share any starting tools.
	var/list/branches = list()

	/// Initialized versions of types specified in branches.
	/// Don't fill this yourself, instead fill branches with surgery TYPES.
	var/list/datum/surgery/branches_init = list()

	/// These tools are just...special cases.
	/// If we're using one of these tools and there's a tool conflict with the original surgery,
	/// just ignore any branches and continue with the original surgery.
	var/list/overriding_tools = list(
		/obj/item/scalpel/laser/manager  // IMS
	)

	/// Whether or not we should add ourselves as a step after we run a branch. This doesn't apply to failures, those will always add ourselves after.
	var/insert_self_after = TRUE

/datum/surgery_step/proxy/New()
	if(length(branches_init))
		CRASH("Proxy surgery [src] was given some initialized branches. Branching steps must be specified in var/branches, not var/branches_init.")

	for(var/branch_type in branches)
		if(!ispath(branch_type, /datum/surgery))
			CRASH("proxy surgery [src] was given a branch type [branch_type] that isn't a subtype of /datum/surgery!")
		var/datum/surgery/new_surgery = new branch_type()
		// Add our proxy step as well so we can choose to perform multiple branches after we finish this one.
		new_surgery.steps.Add(src)
		branches_init.Add(new branch_type())

	..()

/datum/surgery_step/proxy/Destroy(force, ...)
	QDEL_LIST_CONTENTS(branches_init)
	return ..()

/datum/surgery_step/proxy/get_step_information(datum/surgery/surgery, with_tools = FALSE)
	var/datum/surgery_step/cur = surgery.get_surgery_next_step()
	var/step_names = list()
	for(var/datum/surgery/surg in branches_init)
		var/datum/surgery_step/surg_step = surg.get_surgery_step()
		step_names += surg_step.get_step_information(surgery, with_tools)
	step_names += cur.get_step_information(surgery, with_tools)  // put this one on the end

	return english_list(step_names, "Nothing...? If you see this, tell a coder.", ", or ")

/datum/surgery_step/proxy/try_op(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/list/starting_tools = list()

	// pull this out separately. We don't want to move ahead with an any item surgery unless we've exhausted all of our
	// other options.
	// There will also only ever be one possibility for this in a surgery step (unless someone screwed up)
	var/datum/surgery/possible_any_surgery
	var/datum/surgery/next_surgery

	var/datum/surgery_step/next_surgery_step = surgery.get_surgery_next_step()
	var/datum/surgery_step/first_step

	// Check the tools that all of our branches expect to use, and see if any of them match the current tool.
	// sanity checks first though! Make sure we don't have any tool conflicts.
	// A tool should only lead to one surgery step.

	// (If there's a tool that could be used for a few different steps, though, make sure it's put into overriding steps)

	for(var/datum/surgery/S in branches_init)
		first_step = S.get_surgery_step()

		if((!tool || HAS_TRAIT(tool, TRAIT_SURGICAL_OPEN_HAND)) && first_step.accept_hand)
			if(SURGERY_TOOL_HAND in starting_tools)
				CRASH("[src] was provided with multiple branches that allow an empty hand.")
			next_surgery = S  // if there's no tool, just proceed forward.
			starting_tools.Add(SURGERY_TOOL_HAND)

		else if(first_step.accept_any_item)
			if(SURGERY_TOOL_ANY in starting_tools)
				CRASH("[src] was provided with multiple branches that allow any tool.")
			possible_any_surgery = S
			starting_tools.Add(SURGERY_TOOL_ANY)


		for(var/allowed in first_step.allowed_tools)
			if(ispath(allowed) && istype(tool, allowed) || (tool && istype(tool) && tool.tool_behaviour == allowed))
				next_surgery = S
			if((allowed in starting_tools) && !(allowed in overriding_tools))
				CRASH("[src] was provided with multiple branches that start with tool [allowed].")
			else
				starting_tools.Add(allowed)

	// if we didn't set our next surgery (defined by the tool in use), check to see if a catch-all like accept hand or any item work
	if(!next_surgery)
		if((SURGERY_TOOL_ANY in starting_tools) && tool)
			next_surgery = possible_any_surgery


	// If this is set to true, the tool in use will force the next step in the main surgery.
	var/overridden_tool = FALSE

	// Also check the next surgery step.
	if(!isnull(next_surgery_step))

		if(istype(next_surgery_step, /datum/surgery_step/proxy))
			// It might make sense to support this, and I think the flow could work (just treating them like a single step, sorta)
			// but I think for simplicity's sake it's better to just say no
			CRASH("[src] was followed by another proxy surgery step [next_surgery_step] in [surgery].")

		if((SURGERY_TOOL_HAND in starting_tools) && next_surgery_step.accept_hand)
			CRASH("[src] has a conflict with the next main step [next_surgery_step] in surgery [surgery]: both require an open hand.")

		if((SURGERY_TOOL_ANY in starting_tools) && next_surgery_step.accept_any_item)
			CRASH("[src] has a conflict with the next main step [next_surgery_step] in surgery [surgery]: both accept any item.")

		if((!tool || HAS_TRAIT(tool, TRAIT_SURGICAL_OPEN_HAND)) && next_surgery_step.accept_hand && !(SURGERY_TOOL_HAND in starting_tools))
			next_surgery = surgery

		for(var/allowed in next_surgery_step.allowed_tools)
			// debug IMS stuff, check it here so it forces the next surgery if it's being used
			if(istype(tool, /obj/item/scalpel/laser/manager/debug))
				if(!ispath(allowed) && (allowed in GLOB.surgery_tool_behaviors))
					next_surgery = surgery
					next_surgery_step.allowed_tools[tool.type] = 100
					next_surgery_step.implement_type = tool.type
					overridden_tool = TRUE
					break

			if(allowed in starting_tools)
				if(allowed in overriding_tools)
					overridden_tool = TRUE
					break
				else
					CRASH("[src] has a tool conflict ([allowed]) with the next step [next_surgery_step] in the surgery it was called from ([surgery])")

			if(tool && istype(tool) && (ispath(allowed) && istype(tool, allowed) || tool.tool_behaviour == allowed))
				next_surgery = surgery

		// Check if we might allow this under the any item rule if it doesn't fit into any other category. We don't want to accidentally miss a tool conflict.
		if(tool && next_surgery_step.accept_any_item && !(SURGERY_TOOL_ANY in starting_tools))
			next_surgery = surgery

	if(!next_surgery)
		// If the tool used doesn't work for any branch, just ignore it.
		return FALSE

	if(overridden_tool || next_surgery == surgery || !next_surgery)
		// Continue along with the original surgery.
		return try_next_step(user, target, target_zone, tool, surgery, null, TRUE, TRUE)

	if(!target.can_run_surgery(next_surgery, user))
		// Make sure the target can support the surgery.
		// note that this should be run before can_start
		return TRUE

	if(!next_surgery.can_start(user, target))
		// If we wouldn't be able to start the next surgery anyway, don't move past this step.
		// Let them try other tools if necessary.
		return TRUE

	return try_next_step(user, target, target_zone, tool, surgery, next_surgery.steps)

/**
 * Test the next step, but don't fully commit to it unless it completes successfully.
 * If the next step doesn't fully complete (such as being interrupted or failing), we'll insert ourselves again to bring us back
 * 	to the "base" state.
 * If it does, we'll add the subsequent steps to the surgery and continue down the expected branch. If you complete the surgery step, it
 * 	means you've committed to what comes next.
 * Part of the motivation behind this is that I don't want to mutate a surgery retroactively. We can insert, but we shouldn't be changing anything
 * 	behind us.
 *
 * Arguments:
 * * next_surgery_steps - the steps for the branching surgery to add to the current surgery. If there's no branching surgery (or this would continue the main surgery) ignore this.
 * * override_adding_self - If true, then on a successful surgery, regardless of the value of insert_self_after, we won't add ourselves in as another step.
 * * readd_step_on_fail - If true, when we fail a step we'll add the failed step again after the proxy surgery. This is necessary for main surgeries.
 * (for other arguments, see try_op())
 */
/datum/surgery_step/proxy/proc/try_next_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/running_surgery, list/next_surgery_steps, override_adding_self, readd_step_on_fail)

	var/list/following_steps = list()

	if(length(next_surgery_steps))

		// add the first step from the following surgery into the surgery list, to make it the next step.
		running_surgery.steps.Insert(running_surgery.step_number + 1, next_surgery_steps[1])

		// grab the remaining steps to possibly insert after this surgery, depending on what we're doing
		// skip the current step though, since if our try_op works, we've completed it.
		following_steps = next_surgery_steps.Copy()
		following_steps.Cut(1, 2)

	running_surgery.step_number++

	var/datum/surgery_step/next_step = running_surgery.get_surgery_step()
	var/step_status = next_step.try_op(user, target, target_zone, tool, running_surgery)

	if(step_status != SURGERY_INITIATE_SUCCESS)
		// always add ourselves after a failure so someone can make a different choice.
		running_surgery.steps.Insert(running_surgery.step_number + 1, type)

		// Since we've already bumped up the step count, if we tried the main branch in the surgery and failed it, we need to add both
		// the proxy step and the main step to keep them both as options.
		if(readd_step_on_fail)
			running_surgery.steps.Insert(running_surgery.step_number + 2, next_step.type)

		running_surgery.step_number++

	else
		// Insert the steps in our intermediate surgery into the current surgery.
		// This is how we keep our surgeries still technically linear.
		if(insert_self_after && !override_adding_self)
			// add ourselves afterwards as well so we can repeat this step
			following_steps.Add(type)

		// insert at the current step number since we're not trying to bump it up
		running_surgery.steps.Insert(running_surgery.step_number, following_steps)


	return step_status


// Some intermediate surgeries
/datum/surgery/intermediate/bleeding
	// don't worry about these names, they won't appear anywhere.
	name = "Internal Bleeding (abstract)"
	desc = "An intermediate surgery to fix internal bleeding while a patient is undergoing another procedure."
	steps = list(/datum/surgery_step/fix_vein)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)

/datum/surgery/intermediate/bleeding/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
	if(affected.status & ORGAN_INT_BLEEDING)
		return TRUE
	else
		// Normally, adding to_chat to can_start is poor practice since this gets called when listing surgery steps.
		// It's alright for intermediate surgeries, though, since they never get called like that.
		to_chat(user, "<span class='warning'>The veins in [target]'s [parse_zone(affected)] seem to be in perfect condition, they don't need mending.</span>")

	return FALSE

/datum/surgery/intermediate/mendbone
	name = "Mend Bone (abstract)"
	desc = "An intermediate surgery to mend bones while a patient is undergoing another procedure."
	steps = list(/datum/surgery_step/glue_bone, /datum/surgery_step/set_bone, /datum/surgery_step/finish_bone)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/intermediate/mendbone/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
	if(HAS_TRAIT(target, TRAIT_NO_BONES))
		return FALSE
	if(affected.limb_flags & CANNOT_BREAK)
		return FALSE
	if(affected.status & ORGAN_BROKEN)
		return TRUE
	else
		to_chat(user, "<span class='warning'>The bones in [target]'s [parse_zone(affected)] look fully intact, they don't need mending.</span>")
	return FALSE

/datum/surgery/intermediate/treat_burns
	name = "Burns (abstract)"
	desc = "An intermediate surgery to treat burn wounds while a patient is undergoing another procedure."
	steps = list(/datum/surgery_step/treat_burns)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)

/datum/surgery/intermediate/treat_burns/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
	if(affected.status & ORGAN_BURNT)
		return TRUE
	return FALSE

/// Proxy surgery step to allow healing bleeding, bones, and burns.
/// Should be added into surgeries just after the first three standard steps.
/datum/surgery_step/proxy/open_organ
	name = "mend internal bleeding, bones, or burns (proxy)"
	branches = list(
		/datum/surgery/intermediate/bleeding,
		/datum/surgery/intermediate/mendbone,
		/datum/surgery/intermediate/treat_burns
	)

/// Mend IB without healing bones
/datum/surgery_step/proxy/ib
	name = "mend internal bleeding (proxy)"
	branches = list(
		/datum/surgery/intermediate/bleeding
	)

/// The robotic equivalent
/datum/surgery_step/proxy/robotics/repair_limb
	name = "Repair Limb (proxy)"
	branches = list(
		/datum/surgery/intermediate/robotics/repair/burn,
		/datum/surgery/intermediate/robotics/repair/brute
	)

#undef SURGERY_TOOL_ANY
#undef SURGERY_TOOL_HAND
