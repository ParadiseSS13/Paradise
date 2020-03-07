//Procedures in this file: Unsealing a Rig.
//Bay12 removal
/datum/surgery_step/rigsuit
	name="Cut Seals"
	allowed_surgery_tools = SURGERY_TOOLS_RIGSUIT_CUT
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_START
	possible_locs = list("chest")
	pain = FALSE
	can_infect = FALSE
	blood_level = 0
	requires_organic_bodypart = FALSE
	time = 50

/datum/surgery_step/rigsuit/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target)

/datum/surgery_step/rigsuit/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	if(tool.tool_behaviour == TOOL_WELDER)
		if(!tool.tool_use_check(user, 0))
			return
		if(!tool.use(1))
			return
	return istype(target.back, /obj/item/rig) && (target.back.flags&NODROP)

/datum/surgery_step/rigsuit/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] starts cutting through the support systems of [target]'s [target.back] with \the [tool].</span>" , \
	"<span class='notice'>You start cutting through the support systems of [target]'s [target.back] with \the [tool].</span>")
	return ..()

/datum/surgery_step/rigsuit/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/rig/rig = target.back
	if(!istype(rig))
		return SURGERY_FAILED
	rig.reset()
	user.visible_message("<span class='notice'>[user] has cut through the support systems of [target]'s [rig] with \the [tool].</span>", \
		"<span class='notice'>You have cut through the support systems of [target]'s [rig] with \the [tool].</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/rigsuit/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='danger'>[user]'s [tool] can't quite seem to get through the metal...</span>", \
	"<span class='danger'>Your [tool] can't quite seem to get through the metal. It's weakening, though - try again.</span>")
	return SURGERY_FAILED
