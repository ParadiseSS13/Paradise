/**
 * So this should probably be how we'll implement more "dynamic" surgeries.
 * For dynamic surgeries, the idea is more or less that we should be able to perform
 * certain steps once a given set of steps have been completed.
 * Fixing IB, for instance, should just require that the standard three are completed.
 * It's just a standard operation, though.
 * For something like organ manip or bone repair, you just need the first three steps, and then
 * from there it branches out.
 *
 * The way that I want to make this work, then, is to break out some "abstract" steps that
 * sit in between and function kind of like proxies.
 * Depending on the tool used, it can branch out in a few different ways,
 * but always comes back to the initial surgery.
 * This should (hopefully) still keep the linear surgery flow that /tg/ focuses on
 * while giving us some other flexibility.
 */

/**
 * A partial surgery that consists of a few steps that may be found in the middle of another operation.
 * An existing surgery can yield to a proxy surgery for a few steps
 */
/datum/surgery/intermediate
	abstract = TRUE

/datum/surgery/intermediate/bleeding
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
	if(affected.limb_flags & CANNOT_BREAK)
		return FALSE
	if(affected.status & ORGAN_BROKEN)
		return TRUE
	else
		to_chat(user, "<span class='warning'>The bones in [target]'s [parse_zone(affected)] look fully intact, they don't need mending.</span>")
	return FALSE

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
	/// If we're using one of these tools and there's a conflict with the original surgery,
	/// just send it to the original surgery.
	var/list/overriding_tools = list(
		/obj/item/scalpel/laser/manager
	)

/datum/surgery_step/proxy/New()
	for(var/branch_type in branches)
		if(!ispath(branch_type, /datum/surgery))
			CRASH("proxy surgery [src] was given a branch type [branch_type] that isn't a subtype of /datum/surgery!")
		var/datum/surgery/new_surgery = new branch_type()
		// Add our proxy step as well so we can choose to perform multiple branches after we finish this one.
		new_surgery.steps.Add(src)
		branches_init.Add(new branch_type())

	. = ..()


/datum/surgery_step/proxy/try_op(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// Quickly peek into the first few steps of the surgeries that we've got to choose the surgery to pull from

	// sanity checks first though! Make sure we don't have any tool conflicts.
	// A tool should only lead to one surgery step.
	// (If it leads to more, make sure you put it into overriding tools...)

	var/list/starting_tools = list()
	var/datum/surgery/next_surgery


	var/datum/surgery_step/next_surgery_step = surgery.get_surgery_next_step()
	var/datum/surgery_step/first_step

	for(var/datum/surgery/S in branches_init)
		first_step = S.get_surgery_step()

		for(var/allowed in first_step.allowed_tools)
			if(ispath(allowed) && istype(tool, allowed) || tool.tool_behaviour == allowed)
				next_surgery = S
			if(allowed in starting_tools && !(allowed in overriding_tools))
				CRASH("[src] was provided with multiple branches that start with tool [allowed].")
			else
				starting_tools.Add(allowed)

	var/overridden_tool = FALSE

	if(!isnull(next_surgery_step))
		for(var/allowed in next_surgery_step.allowed_tools)

			if(allowed in starting_tools)
				if(allowed in overriding_tools)
					overridden_tool = TRUE
					break
				else
					CRASH("[src] has a tool conflict ([allowed]) with the next step [next_surgery_step] in the surgery it was called from ([surgery])")

			if(tool.type == allowed || tool.tool_behaviour == allowed)
				next_surgery = surgery

	if(overridden_tool || next_surgery == surgery || !next_surgery)
		// Just fire off the next surgery step, but don't add any new steps.
		surgery.status++
		var/datum/surgery_step/next_step = surgery.get_surgery_step()
		return next_step.try_op(user, target, target_zone, tool, surgery)

	if(!next_surgery.can_start(user, target))
		// If we wouldn't be able to start the next surgery anyway, don't move past this step.
		// Let them try other tools if necessary.
		return TRUE

	// Insert the steps in our intermediate surgery into the current surgery.


	// Also, bump the status so we skip past this step.
	surgery.steps.Insert(surgery.status + 1, next_surgery.steps)
	surgery.status++

	// force the next surgery step so we don't have to click again.
	var/datum/surgery_step/next_step = surgery.get_surgery_step()
	return next_step.try_op(user, target, target_zone, tool, surgery)


/datum/surgery_step/proxy/open_chest
	name = "mend internal bleeding or mend bone"
	branches = list(
		/datum/surgery/intermediate/bleeding,
		/datum/surgery/intermediate/mendbone
	)

/datum/surgery_step/proxy/ib
	name = "mend internal bleeding"
	branches = list(
		/datum/surgery/intermediate/bleeding
	)
