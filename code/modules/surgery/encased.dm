//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	priority = 2
	can_infect = TRUE
	blood_level = SURGERY_BLOOD_LEVEL_HANDS

/datum/surgery_step/open_encased/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/open_encased/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE
	if(target_zone == "eyes" || target_zone == "mouth") // Head will be the external organ. Which is encased
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.encased)
		return FALSE
	return TRUE

/datum/surgery_step/open_encased/saw
	name = "saw bone"
	surgery_start_stage = SURGERY_STAGE_SKIN_RETRACTED
	next_surgery_stage = SURGERY_STAGE_SAWN_BONES
	allowed_surgery_tools = SURGERY_TOOLS_SAW_BONE

	time = 5.4 SECONDS

/datum/surgery_step/open_encased/saw/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] begins to cut through [target]'s [affected.encased] with [tool].</span>", \
	"<span class='notice'>You begin to cut through [target]'s [affected.encased] with [tool].</span>")
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] has cut [target]'s [affected.encased] open with [tool].</span>", \
	"<span class='notice'>You have cut [target]'s [affected.encased] open with [tool].</span>")
	affected.cut_level = SURGERY_CUT_LEVEL_SAWN
	affected.fracture(TRUE, "bones sawn")
	return SURGERY_SUCCESS

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [affected.encased] with [tool]!</span>", \
	"<span class='warning'>Your hand slips, cracking [target]'s [affected.encased] with [tool]!</span>" )

	affected.receive_damage(20)
	affected.fracture()

	return SURGERY_FAILED


/datum/surgery_step/open_encased/retract
	name = "retract bone"
	allowed_surgery_tools = SURGERY_TOOLS_RETRACT_BONE
	surgery_start_stage = SURGERY_STAGE_SAWN_BONES
	next_surgery_stage = SURGERY_STAGE_BONES_RETRACTED
	time = 2.4 SECONDS

/datum/surgery_step/open_encased/retract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] starts to force open the [affected.encased] in [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You start to force open the [affected.encased] in [target]'s [affected.name] with [tool].</span>")
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] forces open [target]'s [affected.encased] with [tool].</span>", \
	"<span class='notice'>You force open [target]'s [affected.encased] with [tool].</span>")

	affected.cut_level = SURGERY_CUT_LEVEL_DEEP

	return SURGERY_SUCCESS

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [affected.encased]!</span>", \
	"<span class='warning'>Your hand slips, cracking [target]'s [affected.encased]!</span>")

	affected.receive_damage(20)
	affected.fracture()

	return SURGERY_FAILED

/datum/surgery_step/open_encased/close
	name = "unretract bone" //i suck at names okay? give me a new one
	allowed_surgery_tools = SURGERY_TOOLS_RETRACT_BONE
	surgery_start_stage = SURGERY_STAGE_BONES_RETRACTED
	next_surgery_stage = SURGERY_STAGE_SKIN_RETRACTED

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/close/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] starts bending [target]'s [affected.encased] back into place with [tool].</span>", \
	"<span class='notice'>You start bending [target]'s [affected.encased] back into place with [tool].</span>")
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] bends [target]'s [affected.encased] back into place with [tool].</span>", \
	"<span class='notice'>You bend [target]'s [affected.encased] back into place with [tool].</span>")

	affected.cut_level = SURGERY_CUT_LEVEL_SAWN

	return SURGERY_SUCCESS

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>", \
	"<span class='warning'>Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>")

	affected.receive_damage(20)
	affected.fracture()

	return SURGERY_FAILED
