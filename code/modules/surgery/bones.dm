//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////
///Surgery Datums
/datum/surgery/bone_repair
	name = "Bone Repair"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/glue_bone, /datum/surgery_step/set_bone, /datum/surgery_step/finish_bone, /datum/surgery_step/generic/cauterize)
	possible_locs = list("chest", "l_arm", "l_hand", "r_arm", "r_hand","r_leg", "r_foot", "l_leg", "l_foot", "groin")

/datum/surgery/bone_repair/skull
	name = "Skull Repair"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/glue_bone, /datum/surgery_step/mend_skull, /datum/surgery_step/finish_bone, /datum/surgery_step/generic/cauterize)
	possible_locs = list("head")

/datum/surgery/bone_repair/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 0
		if(affected.status & ORGAN_ROBOT)
			return 0
		if(affected.cannot_break)
			return 0
		if(affected.status & ORGAN_BROKEN)
			return 1
		return 1


//surgery steps
/datum/surgery_step/glue_bone
	name = "mend bone"

	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)
	can_infect = 1
	blood_level = 1

	time = 24

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && !(affected.status & ORGAN_ROBOT) && !(affected.cannot_break)

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [affected.name] with \the [tool]." , \
	"You start applying medication to the damaged bones in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'> [user] applies some [tool] to [target]'s bone in [affected.name]</span>", \
			"<span class='notice'> You apply some [tool] to [target]'s bone in [affected.name] with \the [tool].</span>")

		return 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
		"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")
		return 0

/datum/surgery_step/set_bone
	name = "set bone"

	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	time = 32

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !(affected.status & ORGAN_ROBOT)

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to set the bone in [target]'s [affected.name] in place with \the [tool]." , \
		"You are beginning to set the bone in [target]'s [affected.name] in place with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is going to make you pass out!",1)
	..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected.status & ORGAN_BROKEN)
		user.visible_message("<span class='notice'> [user] sets the bone in [target]'s [affected.name] in place with \the [tool].</span>", \
			"<span class='notice'> You set the bone in [target]'s [affected.name] in place with \the [tool].</span>")
		return 1
	else
		user.visible_message("<span class='notice'> [user] sets the bone in [target]'s [affected.name] in place with \the [tool].</span>", \
			"<span class='notice'> You set the bone in [target]'s [affected.name] in place with \the [tool].</span>")
		return 1

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, damaging the bone in [target]'s [affected.name] with \the [tool]!</span>" , \
		"<span class='warning'> Your hand slips, damaging the bone in [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 5)
	return 0

/datum/surgery_step/mend_skull
	name = "mend skull"

	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	time = 32

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !(affected.status & ORGAN_ROBOT) && affected.limb_name == "head"

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning piece together [target]'s skull with \the [tool]."  , \
		"You are beginning piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] sets [target]'s [affected.encased] with \the [tool].</span>" , \
		"<span class='notice'> You set [target]'s [affected.encased] with \the [tool].</span>")

	return 1

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
	var/obj/item/organ/external/head/h = affected
	h.createwound(BRUISE, 10)
	h.disfigured = 1
	return 0

/datum/surgery_step/finish_bone
	name = "medicate bones"

	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)
	can_infect = 1
	blood_level = 1

	time = 24

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !(affected.status & ORGAN_ROBOT)

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [affected.name] with \the [tool].", \
	"You start to finish mending the damaged bones in [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has mended the damaged bones in [target]'s [affected.name] with \the [tool].</span>"  , \
		"<span class='notice'> You have mended the damaged bones in [target]'s [affected.name] with \the [tool].</span>" )
	affected.status &= ~ORGAN_BROKEN
	affected.status &= ~ORGAN_SPLINTED
	affected.perma_injury = 0

	return 1

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")
	return 0
