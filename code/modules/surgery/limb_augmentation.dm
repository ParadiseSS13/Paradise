/datum/surgery/limb_augmentation
	name = "Augment Limb"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/augment)
	possible_locs = list("head", "chest","l_arm","r_arm","r_leg","l_leg")

/datum/surgery/limb_augmentation/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return 0
		if(affected.status & ORGAN_BROKEN) //The arm has to be in prime condition to augment it.
			return 0
		if(affected.is_robotic())
			return 0
		return 1

/datum/surgery_step/augment
	name = "augment limb with robotic part"
	allowed_tools = list(/obj/item/robot_parts = 100)
	time = 32

/datum/surgery_step/augment/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/p = tool
	if(p.part)
		if(!(target_zone in p.part))
			to_chat(user, "<span class='warning'>[tool] cannot be used to augment this limb!</span>")
			return 0
	return 1

/datum/surgery_step/augment/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts augmenting [affected] with [tool].", "You start augmenting [affected] with [tool].")

/datum/surgery_step/augment/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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
	return 1