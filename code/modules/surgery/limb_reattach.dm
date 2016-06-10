//Procedures in this file: Robotic limbs attachment, meat limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery/amputation
	name = "amputation"
	steps = list(/datum/surgery_step/generic/amputate)
	possible_locs = list("head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")


/datum/surgery/amputation/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if((target.get_species() == "Machine"))
			return 0
		if(!affected)
			return 0

		return 1


/datum/surgery/reattach
	name = "limb attachment"
	steps = list(/datum/surgery_step/limb/attach,/datum/surgery_step/limb/connect)
	possible_locs = list("head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")

/datum/surgery/reattach/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 1
		if((target.get_species() == "Machine"))
			return 0
		return 0

/datum/surgery/reattach_synth
	name = "limb attachment"
	steps = list(/datum/surgery_step/limb/attach)
	possible_locs = list("head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")

/datum/surgery/reattach_synth/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected && (target.get_species() == "Machine"))
			return 1

		return 0


/datum/surgery/robo_attach
	name = "robotic limb attachment"
	steps = list(/datum/surgery_step/limb/mechanize)
	possible_locs = list("head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")

/datum/surgery/robo_attach/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 1

		return 0

/datum/surgery_step/limb/
	can_infect = 0
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if (affected)
			return 0
		var/list/organ_data = target.species.has_limbs["[target_zone]"]
		return !isnull(organ_data)

/datum/surgery_step/limb/attach
	name = "attach limb"
	allowed_tools = list(/obj/item/organ/external = 100)

	time = 32

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = tool
	user.visible_message("[user] starts attaching [E.name] to [target]'s [E.amputation_point].", \
	"You start attaching [E.name] to [target]'s [E.amputation_point].")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = tool
	user.visible_message("<span class='notice'>[user] has attached [target]'s [E.name] to the [E.amputation_point].</span>",	\
	"<span class='notice'>You have attached [target]'s [E.name] to the [E.amputation_point].</span>")
	user.unEquip(E)
	E.replaced(target)
	E.forceMove(target)
	if(target.get_species() == "Machine")//as this is the only step needed for ipc put togethers
		if(target_zone == "head")
			var/obj/item/organ/external/head/H = target.get_organ("head")
			var/datum/robolimb/robohead = all_robolimbs[H.model]
			if(robohead.is_monitor) //Ensures that if an IPC gets a head that's got a human hair wig attached to their body, the hair won't wipe.
				H.h_style = ""
				H.f_style = ""
				target.m_style = ""
		E.status &= ~ORGAN_DESTROYED
		if(E.children)
			for(var/obj/item/organ/external/C in E.children)
				C.status &= ~ORGAN_DESTROYED
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	return 1

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = tool
	user.visible_message("<span class='alert'>[user]'s hand slips, damaging [target]'s [E.amputation_point]!</span>", \
	"<span class='alert'>Your hand slips, damaging [target]'s [E.amputation_point]!</span>")
	target.apply_damage(10, BRUTE, null, sharp=1)
	return 0

/datum/surgery_step/limb/connect
	name = "connect limb"
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/device/assembly/mousetrap = 20
	)
	can_infect = 1

	time = 32

/datum/surgery_step/limb/connect/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	return E && !E.is_stump() && (E.status & ORGAN_DESTROYED)

/datum/surgery_step/limb/connect/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message("[user] starts connecting tendons and muscles in [target]'s [E.amputation_point] with [tool].", \
	"You start connecting tendons and muscle in [target]'s [E.amputation_point].")

/datum/surgery_step/limb/connect/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has connected tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>",	\
	"<span class='notice'>You have connected tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>")
	E.status &= ~ORGAN_DESTROYED
	var/obj/item/organ/external/stump = target.organs_by_name["limb stump"]
	if(stump)
		stump.remove(target)
	if(E.children)
		for(var/obj/item/organ/external/C in E.children)
			C.status &= ~ORGAN_DESTROYED
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	return 1

/datum/surgery_step/limb/connect/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message("<span class='alert'>[user]'s hand slips, damaging [target]'s [E.amputation_point]!</span>", \
	"<span class='alert'>Your hand slips, damaging [target]'s [E.amputation_point]!</span>")
	target.apply_damage(10, BRUTE, null, sharp=1)
	return 0

/datum/surgery_step/limb/mechanize
	name = "attach robotic limb"
	allowed_tools = list(/obj/item/robot_parts = 100)

	time = 32

/datum/surgery_step/limb/mechanize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/robot_parts/p = tool
		if (p.part)
			if (!(target_zone in p.part))
				return 0
		return isnull(target.get_organ(target_zone))

/datum/surgery_step/limb/mechanize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts attaching \the [tool] to [target].", \
		"You start attaching \the [tool] to [target].")

/datum/surgery_step/limb/mechanize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/L = tool
	user.visible_message("<span class='notice'>[user] has attached \the [tool] to [target].</span>",	\
	"<span class='notice'>You have attached \the [tool] to [target].</span>")

	if(L.part)
		for(var/part_name in L.part)
			if(!isnull(target.get_organ(part_name)))
				continue
			var/list/organ_data = target.species.has_limbs["[part_name]"]
			if(!organ_data)
				continue
			var/obj/item/organ/external/stump = target.organs_by_name["limb stump"]
			if(stump)
				stump.remove(target)
			var/new_limb_type = organ_data["path"]
			var/obj/item/organ/external/new_limb = new new_limb_type(target)
			new_limb.robotize(L.model_info)
			new_limb.replaced(target)
			new_limb.status &= ~ORGAN_DESTROYED
			if(new_limb.children)
				for(var/obj/item/organ/external/C in new_limb.children)
					C.status &= ~ORGAN_DESTROYED
			if(L.sabotaged)
				new_limb.sabotaged = 1
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

	return 1

/datum/surgery_step/limb/mechanize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='alert'>[user]'s hand slips, damaging [target]'s flesh!</span>", \
	"<span class='alert'>Your hand slips, damaging [target]'s flesh!</span>")
	target.apply_damage(10, BRUTE, null, sharp=1)
	return 0
