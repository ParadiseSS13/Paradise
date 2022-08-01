/// Allows an item to be used to initiate surgeries.
/datum/component/surgery_initiator
	/// If present, this surgery TYPE will be attempted when the item is used.
	/// Useful for things like limb reattachments that don't need a scalpel.
	var/datum/surgery/forced_surgery

	/// If true, the initial step will be cancellable by just using the tool again. Should be FALSE for any tool that actually has a first surgery step.
	var/can_cancel_before_first = FALSE

	/// If true, can be used with a cautery in the off-hand to cancel a surgery.
	var/can_cancel = TRUE

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

/datum/component/surgery_initiator/Destroy(force, silent)
	return ..()

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_SHARPNESS, .proc/on_parent_sharpness_change)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_SHARPNESS)

/// Keep tabs on the attached item's sharpness. Any sharp item can start a surgery.
/datum/component/surgery_initiator/proc/on_parent_sharpness_change()
	SIGNAL_HANDLER  // COMSIG_ATOM_UPDATE_SHARPNESS
	var/obj/item/P = parent
	if(!P.sharp)
		RemoveComponent()

/// Does the surgery initiation.
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER	// COMSIG_ITEM_ATTACK
	if(!isliving(user))
		return
	if(!user.Adjacent(target))
		return
	if(user.a_intent != INTENT_HELP)
		return
	var/mob/living/L = user
	if(istype(L) && L.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='notice'>You realise that a ghost probably doesn't have any useful organs.</span>")
		return //no cult ghost surgery please
	INVOKE_ASYNC(src, .proc/do_initiate_surgery_moment, target, user)
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
		if(current_step.try_op(user, target, user.zone_selected, parent, current_surgery))
			return
		if(istype(parent, /obj/item/scalpel/laser/manager/debug))
			return
		if((can_cancel_before_first && current_surgery.step_number == 1) || current_surgery.step_number > 1)
			attempt_cancel_surgery(current_surgery, target, user)
			return

	if(!isnull(current_surgery) && current_surgery.step_in_progress)
		return

	var/list/available_surgeries = get_available_surgeries(user, target)

	var/datum/surgery/procedure

	if(!length(available_surgeries))
		if(IS_HORIZONTAL(target))
			to_chat(user, "<span class='notice'>There aren't any surgeries you can perform there right now.</span>")
		else
			to_chat(user, "<span class='notice'>You can't perform any surgeries there while [target] is standing.</span>")
		return

	// if we have a surgery that should be performed regardless with this item,
	// make sure it's available to be done
	if(forced_surgery)
		for(var/datum/surgery/S in available_surgeries)
			if(istype(S, forced_surgery))
				procedure = S
				break
	else
		procedure = input("Begin which procedure?", "Surgery", null, null) as null|anything in available_surgeries

	if(!procedure)
		return

	return try_choose_surgery(user, target, procedure)

/datum/component/surgery_initiator/proc/get_available_surgeries(mob/user, mob/living/target)
	var/list/available_surgeries = list()

	var/mob/living/carbon/carbon_target
	var/obj/item/organ/external/affecting
	if(iscarbon(target))
		carbon_target = target
		affecting = carbon_target.get_organ(check_zone(user.zone_selected))

	for(var/datum/surgery/surgery as anything in GLOB.surgeries_list)
		if(surgery.abstract)  // no choosing abstract surgeries
			continue
		if(!surgery.possible_locs.Find(user.zone_selected))
			continue
		if(affecting)
			if(!surgery.requires_bodypart)
				continue
			if((surgery.requires_organic_bodypart && affecting.is_robotic()) || (!surgery.requires_organic_bodypart && !affecting.is_robotic()))
				continue
			if(surgery.requires_real_bodypart && !affecting.is_primary_organ())
				continue
		else if(carbon_target && surgery.requires_bodypart) //mob with no limb in surgery zone when we need a limb
			continue
		if(surgery.lying_required && target.body_position != LYING_DOWN)
			continue
		if(!surgery.self_operable && target == user)
			continue
		if(!surgery.can_start(user, target))
			continue
		for(var/path in surgery.target_mobtypes)
			if(istype(target, path))
				available_surgeries += surgery
				break

	return available_surgeries

/// Does the surgery de-initiation.
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, mob/living/patient, mob/user)
	var/selected_zone = user.zone_selected
	/// We haven't even started yet. Any surgery can be cancelled at this point.
	if(the_surgery.step_number == 1)
		patient.surgeries -= the_surgery
		user.visible_message(
			"<span class='notice'>[user] draws [parent] away from [patient]'s [parse_zone(selected_zone)].</span>",
			"<span class='notice'>You remove [parent] from [patient]'s [parse_zone(selected_zone)].</span>",
		)

		qdel(the_surgery)
		return

	if(!the_surgery.can_cancel)
		return

	// Don't make a forced surgery implement cancel a surgery.
	if(istype(the_surgery, forced_surgery))
		return

	var/obj/item/close_tool
	var/obj/item/other_hand = user.get_inactive_hand()

	var/is_robotic = !the_surgery.requires_organic_bodypart
	var/datum/surgery_step/close_carbon = new /datum/surgery_step/generic/cauterize/premature()
	var/datum/surgery_step/close_robo = new /datum/surgery_step/robotics/external/close_hatch/premature()
	var/datum/surgery_step/chosen_close_step

	if(is_robotic)
		chosen_close_step = close_robo
	else
		chosen_close_step = close_carbon

	if(isrobot(user))
		if(!is_robotic)
			// borgs need to be able to finish surgeries with just the laser scalpel, no special checks here.
			close_tool = parent
		else
			close_tool = locate(/obj/item/crowbar) in user.get_all_slots()
			if(!close_tool)
				to_chat(user, "<span class='warning'>You need a prying tool in an inactive slot to stop the surgery!</span>")
				return

	else if(other_hand)
		for(var/key in chosen_close_step.allowed_tools)
			if(ispath(key) && istype(other_hand, key) || other_hand.tool_behaviour == key)
				close_tool = other_hand
				break

	if(!close_tool)
		to_chat(user, "<span class='warning'>You need a [is_robotic ? "prying": "cauterizing"] tool in your inactive hand to stop the surgery!</span>")
		return

	if(chosen_close_step.try_op(user, patient, selected_zone, close_tool, the_surgery))
		// logging in case people wonder why they're cut up inside
		log_attack(user, patient, "Prematurely finished \a [the_surgery] surgery.")
		patient.surgeries -= the_surgery
		qdel(the_surgery)

/datum/component/surgery_initiator/proc/can_start_surgery(mob/user, mob/living/target)
	if(!user.Adjacent(target))
		return FALSE

	// The item was moved somewhere else
	if(!(parent in user))
		to_chat(user, "<span class='warning'>You cannot start an operation if you aren't holding the tool anymore.</span>")
		return FALSE

	// While we were choosing, another surgery was started at the same location
	for(var/datum/surgery/surgery in target.surgeries)
		if(surgery.location == user.zone_selected)
			to_chat(user, "<span class='warning'>There's already another surgery in progress on their [surgery.location].</span>")
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
			to_chat(user, "<span class='warning'>The patient has no [parse_zone(selected_zone)]!</span>")
		else
			to_chat(user, "<span class='warning'>The patient has \a [parse_zone(selected_zone)]!</span>")

		return

	if(!isnull(affecting_limb) && (surgery.requires_organic_bodypart && affecting_limb.is_robotic()) || (!surgery.requires_organic_bodypart && !affecting_limb.is_robotic()))
		to_chat(user, "<span class='warning'>That's not the right type of limb for this operation!</span>")
		return

	if(surgery.lying_required && !on_operable_surface(target))
		to_chat(user, "<span class='notice'>Patient must be lying down for this operation.</span>")
		return

	if(target == user && !surgery.self_operable)
		to_chat(user, "<span class='notice'>You can't perform that operation on yourself!</span>")
		return

	if(!surgery.can_start(user, target))
		to_chat(user, "<span class='warning'>Can't start the surgery!</span>")
		return

	if(surgery_needs_exposure(surgery, target))
		to_chat(user, "<span class='warning'>You have to expose [target.p_their()] [parse_zone(selected_zone)] first!</span>")
		return

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)

	show_starting_message(user, target, procedure)

	log_attack(user, target, "operated on (OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")
	add_attack_logs(user, target, "started operation on (OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target)
	return !surgery.ignore_clothes && !get_location_accessible(target, target.zone_selected)

/// Handle to allow for easily overriding the message shown
/datum/component/surgery_initiator/proc/show_starting_message(mob/user, mob/living/target, datum/surgery/procedure)
	user.visible_message(
		"<span class='notice'>[user] holds [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for surgery.</span>",
		"<span class='notice'>You hold [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for \an [procedure.name].</span>",
	)

/datum/component/surgery_initiator/limb
	can_cancel = FALSE  // don't let a leg cancel a surgery
