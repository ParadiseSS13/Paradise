//Procedures in this file: Generic surgery steps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = TRUE
	priority = 10 // Pretty high. Usually what you want

/datum/surgery_step/generic/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target)

/datum/surgery_step/generic/cut_open
	name = "make incision"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_INCISION
	allowed_surgery_tools = SURGERY_TOOLS_INCISION
	blood_level = SURGERY_BLOOD_LEVEL_HANDS
	time = 1.6 SECONDS

/datum/surgery_step/generic/cut_open/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts the incision on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You start the incision on [target]'s [affected.name] with [tool].</span>")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.name]!")
	return ..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [affected.name] with [tool].</span>")
	affected.cut_level = SURGERY_CUT_LEVEL_SHALLOW
	return SURGERY_SUCCESS

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [affected.name] in a wrong spot with [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [affected.name] in a wrong spot with [tool]!</span>")
	affected.receive_damage(10)
	return SURGERY_FAILED

/datum/surgery_step/generic/clamp_bleeders
	name = "clamp bleeders"
	surgery_start_stage = SURGERY_STAGE_INCISION
	next_surgery_stage = SURGERY_STAGE_CLAMPED
	allowed_surgery_tools = SURGERY_TOOLS_CLAMP

	time = 2.4 SECONDS


/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts clamping bleeders in [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You start clamping bleeders in [target]'s [affected.name] with [tool].</span>")
	target.custom_pain("The pain in your [affected.name] is maddening!")
	return ..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [affected.name] with [tool]</span>.",	\
	"<span class='notice'>You clamp bleeders in [target]'s [affected.name] with [tool].</span>")
	spread_germs_to_organ(affected, user, tool)
	return SURGERY_SUCCESS

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with [tool]!</span>")
	affected.receive_damage(10)
	return SURGERY_FAILED

/datum/surgery_step/generic/retract_skin
	name = "retract skin"
	surgery_start_stage = SURGERY_STAGE_CLAMPED
	next_surgery_stage = SURGERY_STAGE_SKIN_RETRACTED
	allowed_surgery_tools = SURGERY_TOOLS_RETRACT_SKIN

	time = 2.4 SECONDS

/datum/surgery_step/generic/retract_skin/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [affected.name] with [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [affected.name] with [tool]."
	if(target_zone == "chest")
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
	if(target_zone == "groin")
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
	user.visible_message("<span class='notice'>[msg]</span>", "<span class='notice'>[self_msg]</span>")
	target.custom_pain("It feels like the skin on your [affected.name] is on fire!")
	return ..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] keeps the incision open on [target]'s [affected.name] with [tool]."
	var/self_msg = "You keep the incision open on [target]'s [affected.name] with [tool]."
	if(target_zone == "chest")
		msg = "[user] keeps the ribcage open on [target]'s torso with [tool]."
		self_msg = "You keep the ribcage open on [target]'s torso with [tool]."
	if(target_zone == "groin")
		msg = "[user] keeps the incision open on [target]'s lower abdomen with [tool]."
		self_msg = "You keep the incision open on [target]'s lower abdomen with [tool]."
	user.visible_message("<span class='notice'>[msg]</span>", "<span class='notice'>[self_msg]</span>")
	affected.cut_level = SURGERY_CUT_LEVEL_OPEN
	return SURGERY_SUCCESS

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user]'s hand slips, tearing the edges of incision on [target]'s [affected.name] with [tool]!"
	var/self_msg = "Your hand slips, tearing the edges of incision on [target]'s [affected.name] with [tool]!"
	if(target_zone == "chest")
		msg = "[user]'s hand slips, damaging several organs [target]'s torso with [tool]!"
		self_msg = "Your hand slips, damaging several organs [target]'s torso with [tool]!"
	if(target_zone == "groin")
		msg = "[user]'s hand slips, damaging several organs [target]'s lower abdomen with [tool]"
		self_msg = "Your hand slips, damaging several organs [target]'s lower abdomen with [tool]!"
	user.visible_message("<span class='warning'>[msg]</span>", "<span class='warning'>[self_msg]</span>")
	target.apply_damage(12, BRUTE, affected, sharp = TRUE)
	return SURGERY_FAILED

/datum/surgery_step/generic/cauterize
	priority = -1 // Always on the bottom of possibilities
	name = "cauterize incision"
	surgery_start_stage = SURGERY_STAGE_ALWAYS // Can always be started
	next_surgery_stage = SURGERY_STAGE_START

	allowed_surgery_tools = SURGERY_TOOLS_CAUTERIZE

	time = 2.4 SECONDS

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return ..() && surgery.current_stage != SURGERY_STAGE_START // Annoying and unneeded

/datum/surgery_step/generic/cauterize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] begins cauterizing the incision on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You begin cauterizing the incision on [target]'s [affected.name] with [tool].</span>")
	target.custom_pain("Your [affected.name] is being burned!")
	return ..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s [affected.name] with [tool].</span>")
	affected.germ_level = 0
	return SURGERY_SUCCESS

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.name] with [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.name] with [tool]!</span>")
	target.apply_damage(3, BURN, affected)
	return SURGERY_FAILED
