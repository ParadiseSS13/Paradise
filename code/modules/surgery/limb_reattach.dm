//Procedures in this file: Robotic limbs attachment, meat limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/limb/
	possible_locs = list("head", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot")

/datum/surgery_step/limb/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/limb/amputate
	name = "amputate limb"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_tools = SURGERY_TOOLS_AMPUTATE

	time = 10 SECONDS

/datum/surgery_step/limb/amputate/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return !affected.cannot_amputate

/datum/surgery_step/limb/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='danger'>[user] begins amputating [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You begins cutting through [target]'s [affected.amputation_point] with [tool].</span>")
	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	return ..()

/datum/surgery_step/limb/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] amputates [target]'s [affected.name] at the [affected.amputation_point] with [tool].</span>", \
	"<span class='notice'>You amputate [target]'s [affected.name] with [tool].</span>")

	add_attack_logs(user, target, "Surgically removed [affected.name]. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(TRUE, DROPLIMB_SHARP)
	if(isitem(thing))
		user.put_in_hands(thing)
	return SURGERY_SUCCESS

/datum/surgery_step/limb/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawing through the bone in [target]'s [affected.name] with [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawing through the bone in [target]'s [affected.name] with [tool]!</span>")
	affected.receive_damage(30)
	affected.fracture()
	return SURGERY_FAILED

/datum/surgery_step/limb/attach
	name = "attach limb"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_ATTACH_LIMB
	accept_any_item = TRUE
	var/robo_man_allowed = FALSE		// If IPCs are allowed
	var/robotic_limb = FALSE 			// If it should be a robotic limb. If false then it should be organic
	affected_organ_available = FALSE 	// Can't put on another limb when another is already there
	time = 3.2 SECONDS

/datum/surgery_step/limb/attach/is_valid_target(mob/living/carbon/human/target)
	return ..() && (robo_man_allowed || !ismachineperson(target))

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE

	if(!istype(tool, /obj/item/organ/external))
		return FALSE

	var/obj/item/organ/external/E = tool
	if(robotic_limb != E.is_robotic())
		return FALSE
	if(target.get_organ(E.limb_name))
		// This catches attaching an arm to a missing hand while the arm is still there
		return FALSE
	if(E.limb_name != target_zone)
		// This ensures you must be aiming at the appropriate location to attach
		// this limb. (Can't aim at a missing foot to re-attach a missing arm)
		return FALSE

	return TRUE

/datum/surgery_step/limb/attach/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/E = tool
	user.visible_message("<span class='notice'>[user] starts attaching [E.name] to [target]'s [E.amputation_point].</span>", \
	"<span class='notice'>You start attaching [E.name] to [target]'s [E.amputation_point].</span>")
	return ..()

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/E = tool
	user.visible_message("<span class='notice'>[user] has attached [target]'s [E.name] to the [E.amputation_point].</span>",	\
	"<span class='notice'>You have attached [target]'s [E.name] to the [E.amputation_point].</span>")
	attach_limb(user, target, E)
	return SURGERY_SUCCESS

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/E = tool
	user.visible_message("<span class='alert'>[user]'s hand slips, damaging [target]'s [E.amputation_point]!</span>", \
	"<span class='alert'>Your hand slips, damaging [target]'s [E.amputation_point]!</span>")
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_FAILED


/datum/surgery_step/limb/attach/proc/is_correct_limb(obj/item/organ/external/E)
	if(E.is_robotic())
		return FALSE
	return TRUE

/datum/surgery_step/limb/attach/proc/attach_limb(mob/living/user, mob/living/carbon/human/target, obj/item/organ/external/E)
	user.unEquip(E)
	E.replaced(target)
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()


// This is a step that handles robotic limb attachment while skipping the "connect" step
// THIS IS DISTINCT FROM USING A CYBORG LIMB TO CREATE A NEW LIMB ORGAN
/datum/surgery_step/limb/attach/robo
	name = "attach robotic limb"
	next_surgery_stage = SURGERY_STAGE_START
	robo_man_allowed = TRUE
	robotic_limb = TRUE

/datum/surgery_step/limb/attach/robo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	var/obj/item/organ/external/E = tool
	return E.is_robotic()

/datum/surgery_step/limb/attach/robo/attach_limb(mob/living/user, mob/living/carbon/human/target, obj/item/organ/external/E)
	// Fixes fabricator IPC heads
	if(!(E.dna) && E.is_robotic() && target.dna)
		E.set_dna(target.dna)
	..()
	if(E.limb_name == "head")
		var/obj/item/organ/external/head/H = target.get_organ("head")
		var/datum/robolimb/robohead = GLOB.all_robolimbs[H.model]
		if(robohead.is_monitor) //Ensures that if an IPC gets a head that's got a human hair wig attached to their body, the hair won't wipe.
			H.h_style = "Bald"
			H.f_style = "Shaved"
			target.m_styles["head"] = "None"


/datum/surgery_step/limb/connect
	name = "connect limb"
	surgery_start_stage = SURGERY_STAGE_ATTACH_LIMB
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_tools = SURGERY_TOOLS_CONNECT_LIMB
	can_infect = TRUE

	time = 3.2 SECONDS

/datum/surgery_step/limb/connect/is_valid_target(mob/living/carbon/human/target)
	return ..() && !ismachineperson(target)

/datum/surgery_step/limb/connect/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts connecting tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>", \
		"<span class='notice'>You start connecting tendons and muscle in [target]'s [E.amputation_point] with [tool].</span>")
	return ..()

/datum/surgery_step/limb/connect/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] connects the tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>",	\
	"<span class='notice'>You connect the tendons and muscles in [target]'s [E.amputation_point] with [tool].</span>")
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	return SURGERY_SUCCESS

/datum/surgery_step/limb/connect/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/E = target.get_organ(target_zone)
	user.visible_message("<span class='alert'>[user]'s hand slips, damaging [target]'s [E.amputation_point]!</span>", \
	"<span class='alert'>Your hand slips, damaging [target]'s [E.amputation_point]!</span>")
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_FAILED

// Difference between this and attach robo limb is that this one uses obj/item/robot_parts
/datum/surgery_step/limb/mechanize
	name = "apply robotic prosthetic"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_START
	accept_any_item = TRUE
	affected_organ_available = FALSE // Can't place if it's still there!
	time = 3.2 SECONDS

/datum/surgery_step/limb/mechanize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	var/obj/item/robot_parts/p = tool
	if(!istype(p))
		return FALSE
	return TRUE

/datum/surgery_step/limb/mechanize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/robot_parts/p = tool
	if(!p.part || !(target_zone in p.part))
		to_chat(user, "<span class='warning'>[tool] does not go there!</span>")
		return SURGERY_FAILED
	user.visible_message("<span class='notice'>[user] starts attaching [tool] to [target].</span>", \
	"<span class='notice'>You start attaching [tool] to [target].</span>")
	return ..()

/datum/surgery_step/limb/mechanize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/robot_parts/L = tool
	user.visible_message("<span class='notice'>[user] attaches [tool] to [target].</span>",	\
	"<span class='notice'>You attach [tool] to [target].</span>")

	if(L.part) // Safeguard against admemes. Shouldn't happen normally
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

	return SURGERY_SUCCESS

/datum/surgery_step/limb/mechanize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='alert'>[user]'s hand slips, damaging [target]'s flesh!</span>", \
	"<span class='alert'>Your hand slips, damaging [target]'s flesh!</span>")
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_FAILED
