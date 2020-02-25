/datum/surgery_step/augment
	name = "augment limb with robotic part"
	surgery_start_stage = SURGERY_STAGE_OPEN_INCISION
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_behaviour = SURGERY_AUGMENT_ROBOTIC
	possible_locs = list("head", "chest","l_arm","r_arm","r_leg","l_leg")
	time = 32

/datum/surgery_step/augment/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target)

/datum/surgery_step/augment/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected.status & ORGAN_BROKEN) //The arm has to be in prime condition to augment it.
		return FALSE
	return TRUE

/datum/surgery_step/augment/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE

	var/obj/item/robot_parts/p = tool
	if(p.part)
		if(!(target_zone in p.part))
			return FALSE
	return TRUE

/datum/surgery_step/augment/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts augmenting [affected] with [tool].", "You start augmenting [affected] with [tool].")

/datum/surgery_step/augment/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/robot_parts/L = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has finished augmenting [affected] with [tool].</span>",	\
	"<span class='notice'>You augment [affected] with [tool].</span>")

	if(L.part)
		for(var/part_name in L.part)
			if(!target.get_organ(part_name))
				continue
			affected.robotize(L.model_info, make_tough = 1, convert_all = 0)
			if(L.sabotaged)
				affected.sabotaged = 1
			break
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

	affected.open = 0
	affected.germ_level = 0
	return TRUE