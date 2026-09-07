
/**
 * # Surgery Initiator
 *
 * Allows an item to start (or prematurely stop) a surgical operation.
 */
/datum/component/surgery_initiator
	/// If present, this surgery TYPE will be attempted when the item is used.
	/// Useful for things like limb reattachments that don't need a scalpel.
	var/datum/surgery/forced_surgery

	/// If true, the initial step will be cancellable by just using the tool again. Should be FALSE for any tool that actually has a first surgery step.
	var/can_cancel_before_first = FALSE

	/// If true, can be used with a cautery in the off-hand to cancel a surgery.
	var/can_cancel = TRUE

	/// If true, can start surgery on someone while they're standing up.
	/// Seeing as how we really don't support this (yet), it's much nicer to selectively enable this if we want it.
	var/can_start_on_stander = FALSE

	/// Bitfield for the types of surgeries that this can start.
	/// Note that in cases where organs are missing, this will be ignored.
	/// Also, note that for anything sharp, SURGERY_INITIATOR_ORGANIC should be set as well.
	var/valid_starting_types = SURGERY_INITIATOR_ORGANIC

	/// How effective this is at preventing infections.
	/// 0 = preventing nothing, 1 = preventing any infection
	var/germ_prevention_quality = 0

	/// The sound to play when starting surgeries
	var/surgery_start_sound = null

	// Replace any other surgery initiator
	dupe_type = /datum/component/surgery_initiator

/**
 * Create a new surgery initiating component.
 *
 * Arguments:
 * * forced_surgery - (optional) the surgery that will be started when the parent is used on a mob.
 */
/datum/component/surgery_initiator/Initialize(datum/surgery/forced_surgery)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.forced_surgery = forced_surgery

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACK, PROC_REF(initiate_surgery_moment))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_SHARPNESS, PROC_REF(on_parent_sharpness_change))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE_MORE, PROC_REF(on_parent_examine_more))

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACK)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_SHARPNESS)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE_MORE)

/datum/component/surgery_initiator/proc/on_parent_examine_more(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER  // COMSIG_PARENT_EXAMINE_MORE
	examine_list += SPAN_NOTICE("You can use this on someone who is laying down to begin surgery on them.")

/// Keep tabs on the attached item's sharpness.
/// This component gets added in atoms when they're made sharp as well.
/datum/component/surgery_initiator/proc/on_parent_sharpness_change()
	SIGNAL_HANDLER  // COMSIG_ATOM_UPDATE_SHARPNESS
	var/obj/item/P = parent
	if(!P.sharp)
		RemoveComponent()

/// Does the surgery initiation.
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER	// COMSIG_ATTACK
	if(!isliving(user))
		return
	var/mob/living/L = target
	if(!user.Adjacent(target))
		return
	if(user.a_intent != INTENT_HELP)
		return
	if(!IS_HORIZONTAL(L) && !can_start_on_stander)
		return
	if(IS_HORIZONTAL(L) && !on_operable_surface(L) && !(isanimal(L) || isbasicmob(L)))
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/organ/external/affected = C.get_organ(user.zone_selected)
		if(affected)
			if((affected.status & ORGAN_ROBOT) && !(valid_starting_types & SURGERY_INITIATOR_ROBOTIC))
				return
			if(!(affected.status & ORGAN_ROBOT) && !(valid_starting_types & SURGERY_INITIATOR_ORGANIC))
				return

	if(L.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, SPAN_NOTICE("You realise that a ghost probably doesn't have any useful organs."))
		return //no cult ghost surgery please
	INVOKE_ASYNC(src, PROC_REF(do_initiate_surgery_moment), target, user)
	// This signal is actually part of the attack chain, so it needs to return true to stop it
	return TRUE

/// Meat and potatoes of starting surgery.
/datum/component/surgery_initiator/proc/do_initiate_surgery_moment(mob/living/target, mob/user)
	var/datum/surgery/current_surgery

	// Check if we've already got a surgery on our target zone
	for(var/i_one in target.surgeries)
		var/datum/surgery/surgeryloop = i_one
		if(surgeryloop.location == user.zone_selected)
			current_surgery = surgeryloop
			break

	if(!isnull(current_surgery) && !current_surgery.step_in_progress)
		var/datum/surgery_step/current_step = current_surgery.get_surgery_step()
		if(current_step.try_op(user, target, user.zone_selected, parent, current_surgery) == SURGERY_INITIATE_SUCCESS)
			return
		if(istype(parent, /obj/item/scalpel/laser/manager/debug))
			return
		if(attempt_cancel_surgery(current_surgery, target, user))
			return

	if(!isnull(current_surgery) && current_surgery.step_in_progress)
		return

	var/list/available_surgeries = get_available_surgeries(user, target)

	var/datum/surgery/procedure

	if(!length(available_surgeries))
		if(IS_HORIZONTAL(target) || isanimal(target))
			to_chat(user, SPAN_NOTICE("There aren't any surgeries you can perform there right now."))
		else
			to_chat(user, SPAN_NOTICE("You can't perform any surgeries there while [target] is standing."))
		return

	// if we have a surgery that should be performed regardless with this item,
	// make sure it's available to be done
	if(forced_surgery)
		for(var/datum/surgery/S in available_surgeries)
			if(istype(S, forced_surgery))
				procedure = S
				break
	else
		procedure = tgui_input_list(user, "Begin which procedure?", "Surgery", available_surgeries)

	if(!procedure)
		return

	if(!on_surgery_selection(user, target, procedure))
		return

	return try_choose_surgery(user, target, procedure)

/datum/component/surgery_initiator/proc/on_surgery_selection(mob/user, mob/living/target, datum/surgery/target_surgery)
	return TRUE

/datum/component/surgery_initiator/proc/get_available_surgeries(mob/user, mob/living/target)
	var/list/available_surgeries = list()
	for(var/datum/surgery/surgery in GLOB.surgeries_list)
		if(surgery.abstract && !istype(surgery, forced_surgery))  // no choosing abstract surgeries, though they can be forced
			continue
		if(!is_type_in_list(target, surgery.target_mobtypes))
			continue
		if(!target.can_run_surgery(surgery, user))
			continue

		available_surgeries |= surgery

	return available_surgeries

/datum/component/surgery_initiator/proc/cancel_unstarted_surgery_fluff(datum/surgery/the_surgery, mob/living/patient, mob/user, selected_zone)
	user.visible_message(
		SPAN_NOTICE("[user] stops the surgery on [patient]'s [parse_zone(selected_zone)] with [parent]."),
		SPAN_NOTICE("You stop the surgery on [patient]'s [parse_zone(selected_zone)] with [parent]."),
	)

/// Does the surgery de-initiation.
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, mob/living/patient, mob/user)
	var/selected_zone = user.zone_selected
	/// We haven't even started yet. Any surgery can be cancelled at this point.
	if(the_surgery.step_number == 1)
		patient.surgeries -= the_surgery
		cancel_unstarted_surgery_fluff(the_surgery, patient, user, selected_zone)

		qdel(the_surgery)
		return TRUE

	if(!the_surgery.can_cancel)
		return

	// Don't make a forced surgery implement cancel a surgery.
	if(istype(the_surgery, forced_surgery))
		return

	var/obj/item/close_tool
	var/obj/item/other_hand = user.get_inactive_hand()

	var/is_robotic = !the_surgery.requires_organic_bodypart
	var/datum/surgery_step/chosen_close_step
	var/skip_surgery = FALSE  // if true, don't even run an operation, just end the surgery.

	if(!the_surgery.requires_bodypart)
		// special behavior here; if it doesn't require a bodypart just check if there's a limb there or not.
		// this is a little bit gross and I do apologize
		if(iscarbon(patient))
			var/mob/living/carbon/C = patient
			var/obj/item/organ/external/affected = C.get_organ(user.zone_selected)
			if(!affected)
				skip_surgery = TRUE

		else if(!isanimal(patient)) // surgery is base to living mobs now but we should still probably restrict this
			skip_surgery = TRUE

	if(!skip_surgery)
		if(is_robotic)
			chosen_close_step = new /datum/surgery_step/robotics/external/close_hatch/premature()
		else
			chosen_close_step = new /datum/surgery_step/generic/cauterize/premature()

	if(skip_surgery)
		close_tool = user.get_active_hand()  // sure, just something so that it isn't null
	else if(isrobot(user))
		if(!is_robotic)
			// borgs need to be able to finish surgeries with just the laser scalpel, no special checks here.
			close_tool = parent
		else
			close_tool = locate(/obj/item/crowbar) in user.get_all_slots()
			if(!close_tool)
				to_chat(user, SPAN_WARNING("You need a prying tool in an inactive slot to stop the surgery!"))
				return TRUE

	else if(other_hand)
		for(var/key in chosen_close_step.allowed_tools)
			if(ispath(key) && istype(other_hand, key) || other_hand.tool_behaviour == key)
				close_tool = other_hand
				break

	if(!close_tool)
		to_chat(user, SPAN_WARNING("You need a [is_robotic ? "prying": "cauterizing"] tool in your inactive hand to stop the surgery!"))
		return TRUE

	if(skip_surgery || chosen_close_step.try_op(user, patient, selected_zone, close_tool, the_surgery) == SURGERY_INITIATE_SUCCESS)
		// logging in case people wonder why they're cut up inside
		log_attack(user, patient, "Prematurely finished \a [the_surgery] surgery.")
		qdel(chosen_close_step)
		patient.surgeries -= the_surgery
		qdel(the_surgery)

	// always return TRUE here so we don't continue the surgery chain and try to start a new surgery with our tool.
	return TRUE

/datum/component/surgery_initiator/proc/can_start_surgery(mob/user, mob/living/target)
	if(!user.Adjacent(target))
		return FALSE

	// The item was moved somewhere else
	if(!(parent in user))
		to_chat(user, SPAN_WARNING("You cannot start an operation if you aren't holding the tool anymore."))
		return FALSE

	// While we were choosing, another surgery was started at the same location
	for(var/datum/surgery/surgery in target.surgeries)
		if(surgery.location == user.zone_selected)
			to_chat(user, SPAN_WARNING("There's already another surgery in progress on their [parse_zone(surgery.location)]."))
			return FALSE

	return TRUE

/datum/component/surgery_initiator/proc/try_choose_surgery(mob/user, mob/living/target, datum/surgery/surgery)
	if(!can_start_surgery(user, target))
		return

	var/obj/item/organ/affecting_limb

	var/selected_zone = user.zone_selected

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		affecting_limb = carbon_target.get_organ(check_zone(selected_zone))

	if(surgery.requires_bodypart == isnull(affecting_limb))
		if(surgery.requires_bodypart)
			to_chat(user, SPAN_WARNING("The patient has no [parse_zone(selected_zone)]!"))
		else
			to_chat(user, SPAN_WARNING("The patient has \a [parse_zone(selected_zone)]!"))

		return

	if(iscarbon(target))
		if(!isnull(affecting_limb))
			if((surgery.requires_organic_bodypart && affecting_limb.is_robotic()) || (!surgery.requires_organic_bodypart && !affecting_limb.is_robotic()))
				to_chat(user, SPAN_WARNING("That's not the right type of limb for this operation!"))
				return

		if(surgery_needs_exposure(surgery, target))
			to_chat(user, SPAN_WARNING("You have to expose [target.p_their()] [parse_zone(selected_zone)] first!"))
			return

	if(surgery.lying_required && !on_operable_surface(target))
		to_chat(user, SPAN_NOTICE("Patient must be lying down for this operation."))
		return

	if(target == user && !surgery.self_operable)
		to_chat(user, SPAN_NOTICE("You can't perform that operation on yourself!"))
		return

	if(!surgery.can_start(user, target))
		to_chat(user, SPAN_WARNING("Can't start the surgery!"))
		return

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)

	// Need to pass dissection its steps because it changes alot depending on the creature
	if(istype(procedure, /datum/surgery/dissect))
		if(isnull(target.surgery_container))
			log_debug("A dissection was started on [target] with contains_xeno_organ as TRUE, however its surgery_container was null!")
			CRASH(SPAN_USERDANGER("[target] does not have a dissection surgery information set to it. Please inform an admin or developer."))
		if(ispath(target.surgery_container, /datum/xenobiology_surgery_container))
			target.surgery_container = new target.surgery_container
		procedure.steps = target.surgery_container.dissection_tool_step

	RegisterSignal(procedure, COMSIG_SURGERY_BLOOD_SPLASH, PROC_REF(on_blood_splash))

	procedure.germ_prevention_quality = germ_prevention_quality

	show_starting_message(user, target, procedure)

	log_attack(user, target, "operated on (OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

	return procedure

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target)
	return !surgery.ignore_clothes && !get_location_accessible(target, target.zone_selected)

/// Handle to allow for easily overriding the message shown
/datum/component/surgery_initiator/proc/show_starting_message(mob/user, mob/living/target, datum/surgery/procedure)
	user.visible_message(
		SPAN_NOTICE("[user] holds [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for surgery."),
		SPAN_NOTICE("You hold [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for \an [procedure.name]."),
	)

/datum/component/surgery_initiator/proc/on_prevent_germs()
	SIGNAL_HANDLER  //
	return

/datum/component/surgery_initiator/proc/on_blood_splash()
	SIGNAL_HANDLER  // COMSIG_SURGERY_BLOOD_SPLASH
	return

/datum/component/surgery_initiator/limb
	can_cancel = FALSE  // don't let a leg cancel a surgery

/datum/component/surgery_initiator/robo
	valid_starting_types = SURGERY_INITIATOR_ROBOTIC

/datum/component/surgery_initiator/robo/sharp
	valid_starting_types = SURGERY_INITIATOR_ORGANIC | SURGERY_INITIATOR_ROBOTIC

/datum/component/surgery_initiator/cloth
	can_cancel = FALSE
	surgery_start_sound = "rustle"

/datum/component/surgery_initiator/cloth/Initialize(datum/surgery/forced_surgery, surgery_effectiveness)
	. = ..()
	if(surgery_effectiveness)
		germ_prevention_quality = surgery_effectiveness

/datum/component/surgery_initiator/cloth/show_starting_message(mob/user, mob/living/target, datum/surgery/procedure)
	user.visible_message(
		SPAN_NOTICE("[user] drapes [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for surgery."),
		SPAN_NOTICE("You drape [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for \an [procedure.name]."),
	)

/datum/component/surgery_initiator/cloth/on_surgery_selection(mob/user, mob/living/target, datum/surgery/target_surgery)
	user.visible_message(
		SPAN_NOTICE("[user] starts to apply [parent] onto [target]."),
		SPAN_NOTICE("You start to apply [parent] onto [target]."),
	)

	if(!isnull(surgery_start_sound))
		playsound(src, surgery_start_sound, 50, TRUE)

	playsound(src, surgery_start_sound)
	if(!do_after_once(user, 3 SECONDS, TRUE, target))
		user.visible_message(
			SPAN_WARNING("[user] stops applying [parent] onto [target]."),
			SPAN_WARNING("You stop applying [parent] onto [target].")
		)
		return

	if(!isnull(surgery_start_sound))
		playsound(src, surgery_start_sound, 50, TRUE)

	return TRUE

/datum/component/surgery_initiator/cloth/on_blood_splash(datum/surgery, mob/user, mob/target, zone, obj/item/tool)
	if(prob(90 * germ_prevention_quality))
		target.visible_message(SPAN_NOTICE("Blood splashes onto the dressing."))
		var/obj/item/I = parent  // safety: this component can only go onto an item
		I.add_mob_blood(target)
		return COMPONENT_BLOOD_SPLASH_HANDLED
