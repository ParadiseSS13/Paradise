//Procedures in this file: Generic surgery steps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/surgery_step/generic
	can_infect = TRUE

/datum/surgery_step/generic/cut_open
	name = "make incision"

	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 90,
		/obj/item/shard = 60,
		/obj/item/scissors = 12,
		/obj/item/butcher_chainsaw = 1,
		/obj/item/claymore = 6,
		/obj/item/melee/energy = 6,
		/obj/item/pen/edagger = 6,
	)

	time = 1.6 SECONDS

/datum/surgery_step/generic/cut_open/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts the incision on [target]'s [affected.name] with \the [tool].",
		"You start the incision on [target]'s [affected.name] with \the [tool]."
	)
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.name]!")
	return ..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] has made an incision on [target]'s [affected.name] with \the [tool].</span>",
		"<span class='notice'> You have made an incision on [target]'s [affected.name] with \the [tool].</span>"
	)
	affected.open = ORGAN_ORGANIC_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s hand slips, slicing open [target]'s [affected.name] in a wrong spot with \the [tool]!</span>",
		"<span class='warning'> Your hand slips, slicing open [target]'s [affected.name] in a wrong spot with \the [tool]!</span>"
	)
	affected.receive_damage(10)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/clamp_bleeders
	name = "clamp bleeders"

	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/scalpel/laser = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/assembly/mousetrap = 25
	)

	time = 2.4 SECONDS


/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts clamping bleeders in [target]'s [affected.name] with \the [tool].",
		"You start clamping bleeders in [target]'s [affected.name] with \the [tool]."
	)
	target.custom_pain("The pain in your [affected.name] is maddening!")
	return ..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] clamps bleeders in [target]'s [affected.name] with \the [tool].</span>",
		"<span class='notice'> You clamp bleeders in [target]'s [affected.name] with \the [tool].</span>"
	)
	spread_germs_to_organ(affected, user, tool)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'> Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>"
	)
	affected.receive_damage(10)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/retract_skin
	name = "retract skin"

	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		/obj/item/scalpel/laser/manager = 100,
		/obj/item/retractor = 100,
		/obj/item/crowbar = 90,
		/obj/item/kitchen/utensil/fork = 60
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/retract_skin/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [affected.name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [affected.name] with \the [tool]."
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [affected.name] is on fire!")
	return ..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='notice'> [user] keeps the incision open on [target]'s [affected.name] with \the [tool].</span>"
	var/self_msg = "<span class='notice'> You keep the incision open on [target]'s [affected.name] with \the [tool].</span>"
	if(target_zone == BODY_ZONE_CHEST)
		msg = "<span class='notice'> [user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the ribcage open on [target]'s torso with \the [tool]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "<span class='notice'> [user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of incision on [target]'s [affected.name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, tearing the edges of incision on [target]'s [affected.name] with \the [tool]!</span>"
	if(target_zone == BODY_ZONE_CHEST)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	target.apply_damage(12, BRUTE, affected, sharp = TRUE)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/cauterize

	name = "cauterize incision"

	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/cauterize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] is beginning to cauterize the incision on [target]'s [affected.name] with \the [tool].",
		"You are beginning to cauterize the incision on [target]'s [affected.name] with \the [tool]."
	)
	target.custom_pain("Your [affected.name] is being burned!")
	return ..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'>[user] cauterizes the incision on [target]'s [affected.name] with \the [tool].</span>",
		"<span class='notice'>You cauterize the incision on [target]'s [affected.name] with \the [tool].</span>"
	)
	affected.open = ORGAN_CLOSED
	affected.germ_level = 0
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>"
	)
	target.apply_damage(3, BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/cauterize/premature
	name = "cauterize incision (premature)"

/datum/surgery_step/generic/cauterize/premature/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] is beginning to cauterize the incision on [target]'s [affected.name] with \the [tool].",
		// give a little heads up to the surgeon that they're stopping the surgery prematurely in case that wasn't the intention.
		"<span class='warning'>You are interrupting the current surgery</span>, beginning to cauterize the incision on [target]'s [affected.name] with \the [tool]."
	)
	target.custom_pain("Your [affected.name] is being burned!")
	return ..()


//drill bone
/datum/surgery_step/generic/drill
	name = "drill bone"
	allowed_tools = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 80,
		/obj/item/pickaxe/drill = 60,
		/obj/item/mecha_parts/mecha_equipment/drill = 60,
		/obj/item/screwdriver = 20
	)
	time = 3 SECONDS

/datum/surgery_step/generic/drill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>"
	)
	return ..()

/datum/surgery_step/generic/drill/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] drills into [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>")
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/drill/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user]'s [tool] doesn't get a firm grip and tears at the bone in [target]'s [parse_zone(target_zone)]!</span>",
		"<span class='warning'>Your [tool] doesn't get a firm grip and tears at the bone in [target]'s [parse_zone(target_zone)]!</span>"
	)

	affected.receive_damage(15)
	return SURGERY_STEP_RETRY


/datum/surgery_step/generic/amputate
	name = "amputate limb"

	allowed_tools = list(
		TOOL_SAW = 100,
		/obj/item/hatchet = 90,
		/obj/item/melee/arm_blade = 75
	)

	time = 10 SECONDS

/datum/surgery_step/generic/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] is beginning to amputate [target]'s [affected.name] with \the [tool].",
		"You are beginning to cut through [target]'s [affected.amputation_point] with \the [tool]."
	)
	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	return ..()

/datum/surgery_step/generic/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] amputates [target]'s [affected.name] at the [affected.amputation_point] with \the [tool].</span>",
		"<span class='notice'> You amputate [target]'s [affected.name] with \the [tool].</span>"
	)

	add_attack_logs(user, target, "Surgically removed [affected.name]. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1, DROPLIMB_SHARP)

	if(istype(target) && target.can_feel_pain())
		// okay if you can feel your arm getting chopped off you aren't gonna be singing
		to_chat(target, "<span class='userdanger'>Your [affected] goes completely numb at the [affected.amputation_point]!</span>")
		target.emote("scream")
	if(isitem(thing))
		user.put_in_hands(thing)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s hand slips, sawing through the bone in [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'> Your hand slips, sawing through the bone in [target]'s [affected.name] with \the [tool]!</span>"
	)
	affected.receive_damage(30)
	affected.fracture()
	return SURGERY_STEP_RETRY
