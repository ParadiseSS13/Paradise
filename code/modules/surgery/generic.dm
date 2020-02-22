//Procedures in this file: Generic surgery steps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return 0
	if(affected.is_robotic())
		return 0
	return 1


/datum/surgery_step/generic/cut_open
	name = "make incision"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_INCISION
	allowed_surgery_behaviour = SURGERY_MAKE_INCISION

	time = 16

/datum/surgery_step/generic/cut_open/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the incision on [target]'s [affected.name] with \the [tool].", \
	"You start the incision on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.name]!")
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has made an incision on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have made an incision on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	return TRUE

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, slicing open [target]'s [affected.name] in a wrong spot with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing open [target]'s [affected.name] in a wrong spot with \the [tool]!</span>")
	affected.receive_damage(10)
	return FALSE

/datum/surgery_step/generic/clamp_bleeders
	name = "clamp bleeders"
	surgery_start_stage = SURGERY_STAGE_INCISION
	next_surgery_stage = SURGERY_STAGE_CLAMPED
	allowed_surgery_behaviour = SURGERY_CLAMP_BLEEDERS

	time = 24


/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts clamping bleeders in [target]'s [affected.name] with \the [tool].", \
	"You start clamping bleeders in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is maddening!")
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] clamps bleeders in [target]'s [affected.name] with \the [tool]</span>.",	\
	"<span class='notice'> You clamp bleeders in [target]'s [affected.name] with \the [tool].</span>")
	spread_germs_to_organ(affected, user, tool)
	return TRUE

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",	\
	"<span class='warning'> Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",)
	affected.receive_damage(10)
	return FALSE

/datum/surgery_step/generic/retract_skin
	name = "retract skin"
	surgery_start_stage = SURGERY_STAGE_CLAMPED
	next_surgery_stage = SURGERY_STAGE_OPEN_INCISION

	allowed_surgery_behaviour = SURGERY_RETRACT_SKIN

	time = 24

/datum/surgery_step/generic/retract_skin/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [affected.name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [affected.name] with \the [tool]."
	if(target_zone == "chest")
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if(target_zone == "groin")
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [affected.name] is on fire!")
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='notice'> [user] keeps the incision open on [target]'s [affected.name] with \the [tool].</span>"
	var/self_msg = "<span class='notice'> You keep the incision open on [target]'s [affected.name] with \the [tool].</span>"
	if(target_zone == "chest")
		msg = "<span class='notice'> [user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the ribcage open on [target]'s torso with \the [tool]."
	if(target_zone == "groin")
		msg = "<span class='notice'> [user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	affected.open = 2
	return TRUE

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='warning'> [user]'s hand slips, tearing the edges of incision on [target]'s [affected.name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, tearing the edges of incision on [target]'s [affected.name] with \the [tool]!</span>"
	if(target_zone == "chest")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
	if(target_zone == "groin")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	target.apply_damage(12, BRUTE, affected, sharp = 1)
	return FALSE

/datum/surgery_step/generic/cauterize
	priority = -1 // Always on the bottom of possibilities
	name = "cauterize incision"
	surgery_start_stage = SURGERY_STAGE_ALWAYS // Can always be started
	next_surgery_stage = SURGERY_STAGE_START

	allowed_surgery_behaviour = SURGERY_CAUTERIZE_INCISION

	time = 24

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	return . && surgery.current_stage != SURGERY_STAGE_START // Annoying and unneeded

/datum/surgery_step/generic/cauterize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.name] with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Your [affected.name] is being burned!")
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] cauterizes the incision on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You cauterize the incision on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	affected.germ_level = 0
	return TRUE

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>")
	target.apply_damage(3, BURN, affected)
	return FALSE
