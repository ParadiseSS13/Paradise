//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/open_encased/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return 0
	if(affected.is_robotic())
		return 0
	return 1


/datum/surgery_step/open_encased/saw
	name = "saw bone"
	allowed_tools = list(
	/obj/item/circular_saw = 100, \
	/obj/item/melee/energy/sword/cyborg/saw = 100, \
	/obj/item/hatchet = 90
	)

	time = 54

/datum/surgery_step/open_encased/saw/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("[user] begins to cut through [target]'s [affected.encased] with \the [tool].", \
	"You begin to cut through [target]'s [affected.encased] with \the [tool].")
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'> [user] has cut [target]'s [affected.encased] open with \the [tool].</span>",		\
	"<span class='notice'> You have cut [target]'s [affected.encased] open with \the [tool].</span>")
	affected.open = 2.5
	return 1

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'> [user]'s hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" , \
	"<span class='warning'> Your hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" )

	affected.receive_damage(20)
	affected.fracture()

	return 0


/datum/surgery_step/open_encased/retract
	name = "retract bone"
	allowed_tools = list(
	/obj/item/scalpel/laser/manager = 100, \
	/obj/item/retractor = 100, 	\
	/obj/item/crowbar = 90
	)

	time = 24

/datum/surgery_step/open_encased/retract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "[user] starts to force open the [affected.encased] in [target]'s [affected.name] with \the [tool]."
	var/self_msg = "You start to force open the [affected.encased] in [target]'s [affected.name] with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='notice'> [user] forces open [target]'s [affected.encased] with \the [tool].</span>"
	var/self_msg = "<span class='notice'> You force open [target]'s [affected.encased] with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	affected.open = 3

	return 1

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='warning'> [user]'s hand slips, cracking [target]'s [affected.encased]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, cracking [target]'s  [affected.encased]!</span>"
	user.visible_message(msg, self_msg)

	affected.receive_damage(20)
	affected.fracture()

	return 0

/datum/surgery_step/open_encased/close
	name = "unretract bone" //i suck at names okay? give me a new one
	allowed_tools = list(
	/obj/item/scalpel/laser/manager = 100, \
	/obj/item/retractor = 100, 	\
	/obj/item/crowbar = 90
	)

	time = 24

/datum/surgery_step/open_encased/close/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "[user] starts bending [target]'s [affected.encased] back into place with \the [tool]."
	var/self_msg = "You start bending [target]'s [affected.encased] back into place with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='notice'> [user] bends [target]'s [affected.encased] back into place with \the [tool].</span>"
	var/self_msg = "<span class='notice'> You bend [target]'s [affected.encased] back into place with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	affected.open = 2.5

	return 1

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='warning'> [user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
	user.visible_message(msg, self_msg)

	affected.receive_damage(20)
	affected.fracture()

	return 0

/datum/surgery_step/open_encased/mend
	name = "mend bone"
	allowed_tools = list(
	/obj/item/bonegel = 100,	\
	/obj/item/screwdriver = 90
	)

	time = 24

/datum/surgery_step/open_encased/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "[user] starts applying \the [tool] to [target]'s [affected.encased]."
	var/self_msg = "You start applying \the [tool] to [target]'s [affected.encased]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [affected.name]!")
	..()

/datum/surgery_step/open_encased/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='notice'> [user] applied \the [tool] to [target]'s [affected.encased].</span>"
	var/self_msg = "<span class='notice'> You applied \the [tool] to [target]'s [affected.encased].</span>"
	user.visible_message(msg, self_msg)

	affected.open = 2

	return 1
