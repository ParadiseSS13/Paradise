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

	/// Whether or not we should add ourselves as a step after we run a branch
	var/insert_self_after = TRUE

/datum/surgery_step/proxy/New()

	if(length(branches_init))
		CRASH("Proxy surgery [src] was given some initialized branches. Branches must be specified in branches, not branches_init.")

	for(var/branch_type in branches)
		if(!ispath(branch_type, /datum/surgery))
			CRASH("proxy surgery [src] was given a branch type [branch_type] that isn't a subtype of /datum/surgery!")
		var/datum/surgery/new_surgery = new branch_type()
		// Add our proxy step as well so we can choose to perform multiple branches after we finish this one.
		new_surgery.steps.Add(src)
		branches_init.Add(new branch_type())

	. = ..()

/datum/surgery_step/proxy/get_step_information(datum/surgery/surgery)
	var/datum/surgery_step/cur = surgery.get_surgery_next_step()
	var/step_names = list(cur.name)
	for(var/datum/surgery/surg in branches_init)
		step_names += surg.get_surgery_step()

	return english_list(step_names, "Nothing...? If you see this, tell a coder.", ", or ")


/datum/surgery_step/proxy/try_op(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/list/starting_tools = list()
	var/datum/surgery/next_surgery

	var/datum/surgery_step/next_surgery_step = surgery.get_surgery_next_step()
	var/datum/surgery_step/first_step

	// Check the tools that all of our branches expect to use, and see if any of them match the current tool.
	// sanity checks first though! Make sure we don't have any tool conflicts.
	// A tool should only lead to one surgery step.

	// (If a tool can lead to more, make sure you put it into overriding tools)

	for(var/datum/surgery/S in branches_init)
		first_step = S.get_surgery_step()

		if(!tool && accept_hand)
			if("hand" in starting_tools)
				CRASH("[src] was provided with multiple branches that allow an empty hand.")
			next_surgery = S
			starting_tools.Add("hand")

		else if(accept_any_item)
			if("any" in starting_tools)
				CRASH("[src] was provided with multiple branches that allow any tool.")
			next_surgery = S
			starting_tools.Add("any")


		for(var/allowed in first_step.allowed_tools)
			if(ispath(allowed) && istype(tool, allowed) || (tool && istype(tool) && tool.tool_behaviour == allowed))
				next_surgery = S
			if(allowed in starting_tools && !(allowed in overriding_tools))
				CRASH("[src] was provided with multiple branches that start with tool [allowed].")
			else
				starting_tools.Add(allowed)

	var/overridden_tool = FALSE

	// Also check the next surgery step.
	if(!isnull(next_surgery_step))
		if(next_surgery_step.accept_hand && ("hand" in starting_tools))
			CRASH("[src] has a conflict with the next main step [next_surgery_step] in surgery [surgery]: both require an open hand.")

		if(("any" in starting_tools) && next_surgery_step.accept_any_item)
			CRASH("[src] has a conflict with the next main step [next_surgery_step] in surgery [surgery]: both accept any item.")

		if(!tool && next_surgery_step.accept_hand && !("hand" in starting_tools))
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

			if(tool && istype(tool) && (tool.type == allowed || tool.tool_behaviour == allowed))
				next_surgery = surgery

		// Check if we allow any tool after checking everything. We don't want to accidentally miss a tool conflict.
		if(tool && next_surgery_step.accept_any_item && !("any" in starting_tools))
			next_surgery = surgery

	if(!next_surgery)
		// If we didn't find a match at all, it's probably just someone using a random tool.
		return FALSE

	if(overridden_tool || next_surgery == surgery || !next_surgery)
		// Continue along with the original surgery
		surgery.status++
		var/datum/surgery_step/next_step = surgery.get_surgery_step()
		return next_step.try_op(user, target, target_zone, tool, surgery)

	if(!next_surgery.can_start(user, target))
		// If we wouldn't be able to start the next surgery anyway, don't move past this step.
		// Let them try other tools if necessary.
		return TRUE

	// Insert the steps in our intermediate surgery into the current surgery.
	// This is how we keep our surgeries still technically linear.
	var/list/steps_to_insert = next_surgery.steps
	if(insert_self_after)
		steps_to_insert.Add(type)

	// Also, bump the status so we skip past this abstract step.
	surgery.steps.Insert(surgery.status + 1, next_surgery.steps)
	surgery.status++

	// force the next surgery step so we don't have to click again.
	var/datum/surgery_step/next_step = surgery.get_surgery_step()
	return next_step.try_op(user, target, target_zone, tool, surgery)

// Some intermediate surgeries
/datum/surgery/intermediate/bleeding
	// don't worry about these names, they won't appear anywhere.
	name = "Internal Bleeding (abstract)"
	desc = "An intermediate surgery to fix internal bleeding while a patient is undergoing another procedure."
	steps = list(/datum/surgery_step/fix_vein)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/intermediate/bleeding/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
	if(affected.status & ORGAN_INT_BLEEDING)
		return TRUE
	else
		// Since we aren't calling these surgeries in the normal way, it'll be okay to add a to_chat to their can_start.
		to_chat(user, "<span class='warning'>The veins in [target]'s [parse_zone(affected)] seem to be in perfect condition, they don't need mending.</span>")

	return FALSE

/datum/surgery/intermediate/mendbone
	name = "Mend Bone (abstract)"
	desc = "An intermediate surgery to mend bones while a patient is undergoing another procedure."
	steps = list(/datum/surgery_step/glue_bone, /datum/surgery_step/set_bone, /datum/surgery_step/finish_bone)
	possible_locs = list("chest", "l_arm", "l_hand", "r_arm", "r_hand","r_leg", "r_foot", "l_leg", "l_foot", "groin")

/datum/surgery/intermediate/mendbone/can_start(mob/user, mob/living/carbon/target)
	. = ..()
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



/// Proxy surgery step to allow healing bleeding and mending bones.
/// Should be added into surgeries just after the first three standard steps.
/datum/surgery_step/proxy/open_organ
	name = "mend internal bleeding or mend bone (proxy)"
	branches = list(
		/datum/surgery/intermediate/bleeding,
		/datum/surgery/intermediate/mendbone
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
