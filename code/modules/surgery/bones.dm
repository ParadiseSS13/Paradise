//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////
//surgery steps
/datum/surgery_step/encasing
	can_infect = 1
	blood_level = 1
	possible_locs = list("chest", "l_arm", "l_hand", "r_arm", "r_hand","r_leg", "r_foot", "l_leg", "l_foot", "groin", "head")

/datum/surgery_step/encasing/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/encasing/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return !affected.cannot_break

/datum/surgery_step/encasing/glue_bone
	name = "mend bone"
	surgery_start_stage = SURGERY_STAGE_OPEN_INCISION
	next_surgery_stage = SURGERY_STAGE_BONES_GELLED
	allowed_surgery_behaviour = SURGERY_MEND_BONE

	time = 24

/datum/surgery_step/encasing/glue_bone/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [affected.name] with \the [tool]." , \
	"You start applying medication to the damaged bones in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!")
	..()

/datum/surgery_step/encasing/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] applies some [tool] to [target]'s bone in [affected.name]</span>", \
		"<span class='notice'> You apply some [tool] to [target]'s bone in [affected.name] with \the [tool].</span>")

	return TRUE

/datum/surgery_step/encasing/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")
	return FALSE

/datum/surgery_step/encasing/set_bone
	name = "set bone"
	surgery_start_stage = SURGERY_STAGE_BONES_GELLED
	next_surgery_stage = SURGERY_STAGE_BONES_SET
	allowed_surgery_behaviour = SURGERY_SET_BONE

	time = 32

/datum/surgery_step/encasing/set_bone/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to set the bone in [target]'s [affected.name] in place with \the [tool]." , \
		"You are beginning to set the bone in [target]'s [affected.name] in place with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is going to make you pass out!")
	..()

/datum/surgery_step/encasing/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] sets the bone in [target]'s [affected.name] in place with \the [tool].</span>", \
		"<span class='notice'> You set the bone in [target]'s [affected.name] in place with \the [tool].</span>")
	
	return TRUE

/datum/surgery_step/encasing/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, damaging the bone in [target]'s [affected.name] with \the [tool]!</span>" , \
		"<span class='warning'> Your hand slips, damaging the bone in [target]'s [affected.name] with \the [tool]!</span>")
	affected.receive_damage(5)
	return FALSE

/datum/surgery_step/encasing/set_bone/mend_skull
	name = "mend skull"
	possible_locs = list("head")

/datum/surgery_step/encasing/set_bone/mend_skull/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] is beginning piece together [target]'s skull with \the [tool]."  , \
		"You are beginning piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/encasing/set_bone/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] sets [target]'s [affected.encased] with \the [tool].</span>" , \
		"<span class='notice'> You set [target]'s [affected.encased] with \the [tool].</span>")

	return TRUE

/datum/surgery_step/encasing/set_bone/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
	var/obj/item/organ/external/head/h = affected
	h.receive_damage(10)
	h.disfigure()
	return FALSE

/datum/surgery_step/encasing/glue_bone/finish_bone
	name = "medicate bones"
	surgery_start_stage = SURGERY_STAGE_BONES_SET
	next_surgery_stage = SURGERY_STAGE_OPEN_INCISION

/datum/surgery_step/encasing/glue_bone/finish_bone/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [affected.name] with \the [tool].", \
	"You start to finish mending the damaged bones in [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/encasing/glue_bone/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has mended the damaged bones in [target]'s [affected.name] with \the [tool].</span>"  , \
		"<span class='notice'> You have mended the damaged bones in [target]'s [affected.name] with \the [tool].</span>" )
	affected.mend_fracture()
	return TRUE
