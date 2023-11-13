//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

/datum/surgery_step/open_encased/saw
	name = "saw bone"
	allowed_tools = list(
		TOOL_SAW = 100,
		/obj/item/hatchet = 90
	)

	time = 5.4 SECONDS

/datum/surgery_step/open_encased/saw/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"[user] begins to cut through [target]'s [affected.encased] with \the [tool].",
		"You begin to cut through [target]'s [affected.encased] with \the [tool]."
	)
	affected.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='notice'> [user] has cut [target]'s [affected.encased] open with \the [tool].</span>",
		"<span class='notice'> You have cut [target]'s [affected.encased] open with \the [tool].</span>"
	)
	affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	affected.fracture(silent = TRUE)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='warning'> [user]'s hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" ,
		"<span class='warning'> Your hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>"
	)

	affected.receive_damage(20)
	affected.fracture()

	return SURGERY_STEP_RETRY


/datum/surgery_step/open_encased/retract
	name = "retract bone"
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 90
	)

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/retract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"[user] starts to force open the [affected.encased] in [target]'s [affected.name] with \the [tool].",
		"You start to force open the [affected.encased] in [target]'s [affected.name] with \the [tool]."
	)
	affected.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='notice'> [user] forces open [target]'s [affected.encased] with \the [tool].</span>",
		"<span class='notice'> You force open [target]'s [affected.encased] with \the [tool].</span>"
	)

	affected.open = ORGAN_ORGANIC_ENCASED_OPEN

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='warning'> [user]'s hand slips, cracking [target]'s [affected.encased]!</span>",
		"<span class='warning'> Your hand slips, cracking [target]'s  [affected.encased]!</span>"
	)

	affected.receive_damage(20)
	affected.fracture()

	return SURGERY_STEP_RETRY

/datum/surgery_step/open_encased/close
	name = "unretract bone" //i suck at names okay? give me a new one
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 90
	)

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/close/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"[user] starts bending [target]'s [affected.encased] back into place with \the [tool].",
		"You start bending [target]'s [affected.encased] back into place with \the [tool]."
	)
	affected.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='notice'>[user] bends [target]'s [affected.encased] back into place with \the [tool].</span>",
		"<span class='notice'>You bend [target]'s [affected.encased] back into place with \the [tool].</span>"
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='warning'>[user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>",
		"<span class='warning'>Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
	)

	affected.receive_damage(20)
	affected.fracture()

	return SURGERY_STEP_RETRY

/datum/surgery_step/open_encased/mend
	name = "mend bone"
	allowed_tools = list(
		TOOL_BONEGEL = 100,
		TOOL_SCREWDRIVER = 90
	)

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"[user] starts applying \the [tool] to [target]'s [affected.encased].",
		"You start applying \the [tool] to [target]'s [affected.encased]."
	)
	affected.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='notice'> [user] applied \the [tool] to [target]'s [affected.encased].</span>",
		"<span class='notice'> You applied \the [tool] to [target]'s [affected.encased].</span>"
	)

	affected.open = ORGAN_ORGANIC_OPEN

	return SURGERY_STEP_CONTINUE
