//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////
///Surgery Datums
/datum/surgery/bone_repair
	name = "Bone Repair"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // Only proxy IB here
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)

	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/bone_repair/skull
	name = "Skull Repair"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone/mend_skull,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery/bone_repair/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.limb_flags & CANNOT_BREAK)
		return FALSE
	if(!(affected.status & ORGAN_BROKEN))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_NO_BONES))
		return FALSE
	return TRUE


//surgery steps
/datum/surgery_step/glue_bone
	name = "mend bone"

	allowed_tools = list(
		TOOL_BONEGEL = 100,
		TOOL_SCREWDRIVER = 90
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 2.4 SECONDS

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts applying medication to the damaged bones in [target]'s [affected.name] with \the [tool].",
		"You start applying medication to the damaged bones in [target]'s [affected.name] with \the [tool]."
	)
	affected.custom_pain("Something in your [affected.name] is causing you a lot of pain!")
	return ..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			"<span class='notice'> [user] applies some [tool] to [target]'s bone in [affected.name].</span>",
			"<span class='notice'> You apply some [tool] to [target]'s bone in [affected.name] with \the [tool].</span>"
		)

		return SURGERY_STEP_CONTINUE

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			"<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>",
			"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>"
		)
		return SURGERY_STEP_RETRY

/datum/surgery_step/set_bone
	name = "set bone"

	allowed_tools = list(
		TOOL_BONESET = 100,
		TOOL_WRENCH = 90
	)

	time = 3.2 SECONDS

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] is beginning to set the bone in [target]'s [affected.name] in place with \the [tool].",
		"You are beginning to set the bone in [target]'s [affected.name] in place with \the [tool]."
	)
	affected.custom_pain("The pain in your [affected.name] is going to make you pass out!")
	return ..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] sets the bone in [target]'s [affected.name] in place with \the [tool].</span>",
		"<span class='notice'> You set the bone in [target]'s [affected.name] in place with \the [tool].</span>"
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s hand slips, damaging the bone in [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'> Your hand slips, damaging the bone in [target]'s [affected.name] with \the [tool]!</span>"
	)
	affected.receive_damage(5)
	return SURGERY_STEP_RETRY

/datum/surgery_step/set_bone/mend_skull
	name = "mend skull"

/datum/surgery_step/set_bone/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		"[user] is beginning piece together [target]'s skull with \the [tool].",
		"You are beginning piece together [target]'s skull with \the [tool]."
	)
	return ..()

/datum/surgery_step/set_bone/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] sets [target]'s [affected.encased] with \the [tool].</span>",
		"<span class='notice'> You set [target]'s [affected.encased] with \the [tool].</span>"
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/set_bone/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>",
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>"
	)
	var/obj/item/organ/external/head/H = affected
	H.receive_damage(10)
	H.disfigure()
	return SURGERY_STEP_RETRY

/datum/surgery_step/finish_bone
	name = "medicate bones"

	allowed_tools = list(
		TOOL_BONEGEL = 100,
		TOOL_SCREWDRIVER = 90
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 2.4 SECONDS

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts to finish mending the damaged bones in [target]'s [affected.name] with \the [tool].",
		"You start to finish mending the damaged bones in [target]'s [affected.name] with \the [tool]."
	)
	return ..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] has mended the damaged bones in [target]'s [affected.name] with \the [tool].</span>",
		"<span class='notice'> You have mended the damaged bones in [target]'s [affected.name] with \the [tool].</span>"
	)
	affected.mend_fracture()
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>",
		"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>"
	)
	return SURGERY_STEP_RETRY
