/// Allows an item to be used to initiate surgeries.
/datum/component/surgery_initiator
	/// If present, this surgery TYPE will be attempted when the item is used.
	/// Useful for things like limb reattachments that don't need a scalpel.
	var/datum/surgery/forced_surgery

	/// If true, the initial step will be cancellable by just using the tool again.
	var/can_cancel_before_first = FALSE

	/// Canceling surgery in-progress is pretty much a formality
	var/static/list/cautery_tools = list(
		TOOL_CAUTERY = 100, \
		/obj/item/scalpel/laser = 100, \
		/obj/item/clothing/mask/cigarette = 90,	\
		/obj/item/lighter = 60,			\
		/obj/item/weldingtool = 30
	)

/datum/component/surgery_initiator/Initialize(datum/surgery/forced_surgery = null)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.forced_surgery = forced_surgery

/datum/component/surgery_initiator/Destroy(force, silent)
	return ..()

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

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
		if((can_cancel_before_first && current_surgery.status == 1) || current_surgery.status > 1)
			attempt_cancel_surgery(current_surgery, target, user)
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
	var/obj/item/organ/affecting
	if (iscarbon(target))
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
			if(surgery.requires_real_bodypart && affecting.is_primary_organ())
				continue
		else if(carbon_target && surgery.requires_bodypart) //mob with no limb in surgery zone when we need a limb
			continue
		if(surgery.lying_required && target.body_position != LYING_DOWN)
			continue
		if(!surgery.can_start(user, target))
			continue
		for(var/path in surgery.allowed_mob)
			if(istype(target, path))
				available_surgeries += surgery
				break

	return available_surgeries

/// Does the surgery de-initiation.
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, mob/living/patient, mob/user)
	var/selected_zone = user.zone_selected

	// TODO not really sure how this'll work with overriden surgeries/limbs

	/// We haven't even started yet. Any surgery can be cancelled at this point.
	if(the_surgery.status == 1)
		patient.surgeries -= the_surgery
		// TODO This message is still pretty reminiscent of drapes
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

	// Robots can't operate on cyborg limbs
	if(isrobot(user) && !is_robotic)
		close_tool = locate(/obj/item/scalpel/laser) in user.get_all_slots()
		if(!close_tool)
			to_chat(user, "<span class='warning'>You need a cauterizing tool in an inactive slot to stop the surgery!</span>")
			return
	else
		if(!other_hand)
			close_tool = null
		else if(is_robotic)
			if(other_hand.tool_behaviour == TOOL_SCREWDRIVER)
				close_tool = other_hand
		else
			for(var/key in cautery_tools)
				if(ispath(key) && istype(other_hand, key) || other_hand.tool_behaviour == key)
					close_tool = other_hand
					break

	if(!close_tool)
		to_chat(user, "<span class='warning'>You need a [is_robotic ? "screwdriver": "cautery"] in your inactive hand to stop the surgery!</span>")
		return

	var/datum/surgery_step/generic/cauterize/premature/step = new

	if(step.try_op(user, patient, selected_zone, close_tool, the_surgery))
		patient.surgeries -= the_surgery
		qdel(the_surgery)
		// logging in case people wonder why they're cut up inside
		log_attack(user, patient, "Prematurely finished a surgery.")

/datum/component/surgery_initiator/proc/can_start_surgery(mob/user, mob/living/target)
	if (!user.Adjacent(target))
		return FALSE

	// The item was moved somewhere else
	if (!(parent in user))
		return FALSE

	// While we were choosing, another surgery was started at the same location
	for (var/datum/surgery/surgery in target.surgeries)
		if (surgery.location == user.zone_selected)
			return FALSE

	return TRUE

/datum/component/surgery_initiator/proc/try_choose_surgery(mob/user, mob/living/target, datum/surgery/surgery)
	if (!can_start_surgery(user, target))
		to_chat(user, "<span class='warning'>Can't start the surgery!</span>")
		return

	var/obj/item/organ/affecting_limb

	var/selected_zone = user.zone_selected

	if (iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		affecting_limb = carbon_target.get_organ(check_zone(selected_zone))

	if (surgery.requires_bodypart == isnull(affecting_limb))
		if (surgery.requires_bodypart)
			to_chat(user, "<span class='warning'>The patient has no [parse_zone(selected_zone)]!</span>")
		else
			to_chat(user, "<span class='warning'>patient has \a [parse_zone(selected_zone)]!</span>")

		return

	if (!isnull(affecting_limb) && (surgery.requires_organic_bodypart && affecting_limb.is_robotic()) || (!surgery.requires_organic_bodypart && !affecting_limb.is_robotic()))
		to_chat(user, "<span class='warning'>That's not the right type of limb for this operation!</span>")
		return

	if (surgery.lying_required && !IS_HORIZONTAL(target))
		to_chat(user, "<span class='notice'>Patient must be lying down for this operation.</span>")
		return

	if(target == src && !surgery.self_operable)
		to_chat(user, "<span class='notice'>You can't perform that operation on yourself!</span>")
		return

	if (!surgery.can_start(user, target))
		to_chat(user, "<span class='warning'>Can't start the surgery!</span>")
		return

	if (surgery_needs_exposure(surgery, target))
		to_chat(user, "<span class='warning'>You have to expose [target.p_their()] [parse_zone(selected_zone)] first!</span>")
		return

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)


	show_starting_message(user, target, procedure)

	log_attack(user, target, "operated on (OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target)

	return !surgery.ignore_clothes && !get_location_accessible(target, target.zone_selected)

/// Handle to allow for easily overriding the message shown
/datum/component/surgery_initiator/proc/show_starting_message(mob/user, mob/living/target, datum/surgery/procedure)
	user.visible_message(
		"<span class='notice'>[user] holds [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for surgery.</span>",
		"<span class='notice'>You hold [parent] over [target]'s [parse_zone(user.zone_selected)] to prepare for \an [procedure.name].</span>",
	)
