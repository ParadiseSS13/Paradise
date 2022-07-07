/// Allows an item to  be used to initiate surgeries.
/datum/component/surgery_initiator

/datum/component/surgery_initiator/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/surgery_initiator/Destroy(force, silent)
	return ..()

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/// Does the surgery initiation.
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	if(!user.Adjacent(target))
		return
	INVOKE_ASYNC(src, .proc/do_initiate_surgery_moment, target, user)
	return TRUE

/datum/component/surgery_initiator/proc/do_initiate_surgery_moment(mob/living/target, mob/user)
	var/datum/surgery/current_surgery

	for(var/i_one in target.surgeries)
		var/datum/surgery/surgeryloop = i_one
		if(surgeryloop.location == user.zone_selected)
			current_surgery = surgeryloop
			break

	if (!isnull(current_surgery) && !current_surgery.step_in_progress)
		attempt_cancel_surgery(current_surgery, target, user)
		return

	var/list/available_surgeries = get_available_surgeries(user, target)

	if(!length(available_surgeries))
		if (IS_HORIZONTAL(target))
			to_chat(target, "<span class='notice'>No surgeries available!</span>")
		else
			to_chat(target, "<span class='notice'>Patient should be lying down first.</span>")

		return

/datum/component/surgery_initiator/proc/get_available_surgeries(mob/user, mob/living/target)
	var/list/available_surgeries = list()

	var/mob/living/carbon/carbon_target
	var/obj/item/organ/affecting
	if (iscarbon(target))
		carbon_target = target
		affecting = carbon_target.get_organ(check_zone(user.zone_selected))

	for(var/datum/surgery/surgery as anything in GLOB.surgeries_list)
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

	if(the_surgery.status == 1)
		patient.surgeries -= the_surgery
		user.visible_message(
			"<span class='notice'>[user] removes [parent] from [patient]'s [parse_zone(selected_zone)].</span>",
			"<span class='notice'>You remove [parent] from [patient]'s [parse_zone(selected_zone)].</span>",
		)

		qdel(the_surgery)
		return

	if(!the_surgery.can_cancel)
		return

	var/required_tool_type = TOOL_CAUTERY
	var/obj/item/close_tool = user.get_inactive_hand()
	var/is_robotic = !the_surgery.requires_organic_bodypart

	if(is_robotic)
		required_tool_type = TOOL_SCREWDRIVER

	if(isrobot(user))
		close_tool = locate(/obj/item/cautery) in user.get_all_slots()
		if(!close_tool)
			to_chat(user, "<span class='warning'>You need a cautery in an inactive slot to stop the surgery!</span>")
			return

	else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
		to_chat(user, "<span class='warning'>You need a [is_robotic ? "screwdriver": "cautery"] in your inactive hand to stop the surgery!</span>")
		return

	var/datum/surgery_step/generic/cauterize/premature/step = new

	if(step.try_op(user, patient, parse_zone(selected_zone), close_tool, the_surgery))

		patient.surgeries -= the_surgery
		qdel(the_surgery)



/datum/component/surgery_initiator/proc/list_surgeries(mob/user, /mob/living/carbon/target)

	var/list/surgeries = list()
	if (!isnull(surgery_target))
		var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in get_available_surgeries(user, target)
		for (var/datum/surgery/surgery as anything in )


	return list(
		"selected_zone" = user.zone_selected,
		"target_name" = surgery_target?.name,
		"surgeries" = surgeries,
	)

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
		to_chat(user, "<span class='warning'>That's not the right type of limb!</span>")
		return

	if (surgery.lying_required && !IS_HORIZONTAL(patient))
		to_chat(user, "<span class='warning'>Patient must be lying down for this operation.</span>")
		return

	if (!surgery.can_start(user, target))
		to_chat(user, "<span class='warning'>Can't start the surgery!</span>")
		return

	if (surgery_needs_exposure(surgery, target))
		to_chat(user, "<span class='warning'>You have to expose [target.p_their()] [parse_zone(selected_zone)] first!</span>")
		return

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)


	user.visible_message(
		"<span class='notice'>[user] holds [parent] over [target]'s [parse_zone(selected_zone)] to prepare for surgery.</span>",
		"<span class='notice'>You drape [parent] over [target]'s [parse_zone(selected_zone)] to prepare for \an [procedure.name].</span>",
	)

	log_attack(user, target, "operated on (OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target)

	return !surgery.ignore_clothes && !get_location_accessible(target, user.zone_selected)


