//Procedures in this file: Robotic limbs attachment, meat limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery/amputation
	name = "Amputation"
	steps = list(/datum/surgery_step/generic/amputate)
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)
	cancel_on_organ_change = FALSE  // don't stop the surgery when removing limbs

/datum/surgery/amputation/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.limb_flags & CANNOT_DISMEMBER)
		return FALSE
	return TRUE

/datum/surgery/reattach
	name = "Limb Reattachment"
	requires_bodypart = FALSE
	steps = list(
		/datum/surgery_step/limb/attach,
		/datum/surgery_step/limb/connect
	)
	cancel_on_organ_change = FALSE
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/reattach/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(ismachineperson(target))
			// RIP bi-centennial man
			return FALSE
		if(!affected)
			return TRUE
		// make sure they can actually have this limb
		var/list/organ_data = target.dna.species.has_limbs["[user.zone_selected]"]
		return !isnull(organ_data)

	return FALSE

/datum/surgery/reattach_synth
	name = "Synthetic Limb Reattachment"
	requires_bodypart = FALSE
	steps = list(/datum/surgery_step/limb/attach/robo)
	abstract = TRUE  // these shouldn't show in the list; they'll be replaced by attach_robotic_limb
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/robo_attach
	name = "Apply Robotic Prosthetic"
	requires_bodypart = FALSE
	steps = list(/datum/surgery_step/limb/mechanize)
	abstract = TRUE
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)


/datum/surgery_step/proxy/robo_limb_attach
	name = "apply robotic limb (proxy)"
	branches = list(
		/datum/surgery/robo_attach,
		/datum/surgery/reattach_synth
	)
	insert_self_after = FALSE

/datum/surgery/attach_robotic_limb
	name = "Apply Robotic or Synthetic Limb"
	requires_bodypart = FALSE
	steps = list(
		/datum/surgery_step/proxy/robo_limb_attach
	)
	cancel_on_organ_change = FALSE
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)


/datum/surgery_step/limb

/datum/surgery_step/limb/attach
	name = "attach limb"
	allowed_tools = list(/obj/item/organ/external = 100)
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'

	time = 3.2 SECONDS

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/external/E = tool
	if(target.get_organ(E.limb_name))
		// This catches attaching an arm to a missing hand while the arm is still there
		to_chat(user, "<span class='warning'>[target] already has an [E.name]!</span>")
		return SURGERY_BEGINSTEP_ABORT
	if(E.limb_name != target_zone)
		// This ensures you must be aiming at the appropriate location to attach
		// this limb. (Can't aim at a missing foot to re-attach a missing arm)
		to_chat(user, "<span class='warning'>The [E.name] does not go there.</span>")
		return SURGERY_BEGINSTEP_ABORT
	if(!is_correct_limb(E))
		to_chat(user, "<span class='warning'>This is not the correct limb type for this surgery!</span>")
		return SURGERY_BEGINSTEP_ABORT
	var/list/organ_data = target.dna.species.has_limbs["[user.zone_selected]"]
	if(isnull(organ_data))
		to_chat(user, "<span class='warning'>[target.dna.species] don't have the anatomy for [E.name]!</span>")
		return SURGERY_BEGINSTEP_ABORT
	if(!target.bodyparts_by_name[E.parent_organ])
		to_chat(user, "<span class='warning'>[target] doesn't have a [parse_zone(E.parent_organ)] to attach the [E.name] to!</span>")
		return SURGERY_BEGINSTEP_ABORT
	if(length(E.search_contents_for(/obj/item/organ/internal/brain)) && target.get_int_organ(/obj/item/organ/internal/brain))
		to_chat(user, "<span class='warning'>Both [target] and [E.name] contain a brain, and [target] can't have two brains!</span>")
		return SURGERY_BEGINSTEP_ABORT

	user.visible_message(
		"[user] starts attaching [E.name] to [target]'s [E.amputation_point].",
		"You start attaching [E.name] to [target]'s [E.amputation_point].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = tool
	user.visible_message(
		"<span class='notice'>[user] has attached [target]'s [E.name] to the [E.amputation_point].</span>",
		"<span class='notice'>You have attached [target]'s [E.name] to the [E.amputation_point].</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	attach_limb(user, target, E)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = tool
	user.visible_message(
		"<span class='alert'>[user]'s hand slips, damaging [target]'s [E.amputation_point]!</span>",
		"<span class='alert'>Your hand slips, damaging [target]'s [E.amputation_point]!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_STEP_RETRY


/datum/surgery_step/limb/attach/proc/is_correct_limb(obj/item/organ/external/E)
	if(E.is_robotic())
		return FALSE
	return TRUE

/datum/surgery_step/limb/attach/proc/attach_limb(mob/living/user, mob/living/carbon/human/target, obj/item/organ/external/E)
	user.drop_item_to_ground(E)
	E.replaced(target)
	if(!E.is_robotic())
		E.properly_attached = FALSE
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()


// This is a step that handles robotic limb attachment while skipping the "connect" step
// THIS IS DISTINCT FROM USING A CYBORG LIMB TO CREATE A NEW LIMB ORGAN
/datum/surgery_step/limb/attach/robo
	name = "attach robotic limb"

/datum/surgery_step/limb/attach/robo/is_correct_limb(obj/item/organ/external/E)
	if(!E.is_robotic())
		return FALSE
	return TRUE

/datum/surgery_step/limb/attach/robo/attach_limb(mob/living/user, mob/living/carbon/human/target, obj/item/organ/external/E)
	// Fixes fabricator IPC heads
	if(!(E.dna) && E.is_robotic() && target.dna)
		E.set_dna(target.dna)
	..()


/datum/surgery_step/limb/connect
	name = "connect limb"
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/assembly/mousetrap = 25
	)
	can_infect = TRUE
	preop_sound = 'sound/surgery/hemostat1.ogg'

	time = 3.2 SECONDS

/datum/surgery_step/limb/connect/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts connecting tendons and muscles in [target]'s [E.amputation_point] with [tool].",
		"You start connecting tendons and muscle in [target]'s [E.amputation_point].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/limb/connect/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'>[user] has connected tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>",
		"<span class='notice'>You have connected tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	E.properly_attached = TRUE
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/limb/connect/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message(
		"<span class='alert'>[user]'s hand slips, damaging [target]'s [E.amputation_point]!</span>",
		"<span class='alert'>Your hand slips, damaging [target]'s [E.amputation_point]!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_STEP_RETRY

/datum/surgery_step/limb/mechanize
	name = "apply robotic prosthetic"
	allowed_tools = list(/obj/item/robot_parts = 100)

	time = 3.2 SECONDS

/datum/surgery_step/limb/mechanize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/robot_parts/P = tool
	if(P.part)
		if(!(target_zone in P.part))
			to_chat(user, "<span class='warning'>\The [tool] does not go there!</span>")
			return SURGERY_BEGINSTEP_ABORT

	user.visible_message(
		"[user] starts attaching \the [tool] to [target].",
		"You start attaching \the [tool] to [target].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/limb/mechanize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/L = tool
	user.visible_message(
		"<span class='notice'>[user] has attached \the [tool] to [target].</span>",
		"<span class='notice'>You have attached \the [tool] to [target].</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	if(L.part)
		for(var/part_name in L.part)
			if(!isnull(target.get_organ(part_name)))
				continue
			var/list/organ_data = target.dna.species.has_limbs["[part_name]"]
			if(!organ_data)
				continue
			// This will break if there's more than one stump ever
			var/obj/item/organ/external/stump = target.bodyparts_by_name["limb stump"]
			if(stump)
				stump.remove(target)
			var/new_limb_type = organ_data["path"]
			var/obj/item/organ/external/new_limb = new new_limb_type(target)
			new_limb.robotize(L.model_info)
			if(L.sabotaged)
				new_limb.sabotaged = TRUE
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/limb/mechanize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		"<span class='alert'>[user]'s hand slips, damaging [target]'s flesh!</span>",
		"<span class='alert'>Your hand slips, damaging [target]'s flesh!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_STEP_RETRY
