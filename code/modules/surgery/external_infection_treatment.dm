/datum/surgery/infection
	name = "External Infection Treatment"
	desc = "Gradually remove infected from an affected limb"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/heal_infection,
		/datum/surgery_step/pull_skin,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)

/datum/surgery_step/heal_infection
	name = "tend infection"

	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30,
		/obj/item/flamethrower = 1
	)

	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'
	failure_sound = 'sound/items/welder.ogg'
	time = 2.4 SECONDS
	repeatable = TRUE

	var/shown_starting_message_already = FALSE

	COOLDOWN_DECLARE(success_message_spam_cooldown)

	var/germ_amount_healed = 50

/datum/surgery_step/heal_infection/proc/can_be_healed(mob/living/user, mob/living/carbon/target, target_zone)
	if(germ_amount_healed == 0)
		stack_trace("A healing surgery was given no healing values.")
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return (germ_amount_healed && affected.germ_level)

/datum/surgery_step/heal_infection/can_repeat(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!can_be_healed(user, target, target_zone))
		to_chat(user, "<span class='notice'>It doesn't look like [target] has any remaining infection.</span>")
		return FALSE
	return TRUE

/datum/surgery_step/heal_infection/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!shown_starting_message_already)
		shown_starting_message_already = TRUE
		user.visible_message(
			"[user] starts to remove some of the infection on [target]'s [affected.name] with [tool].",
			"You start to remove some of the infection on [target]'s [affected.name] with [tool].",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
	affected.custom_pain("Your [affected.name] is being burned!")

	return ..()

/datum/surgery_step/heal_infection/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	if(!can_be_healed(user, target, target_zone))
		to_chat(user, "<span class='notice'>It doesn't look like [target] has any remaining infection.</span>")
		return SURGERY_STEP_CONTINUE

	var/outer_msg = "[user] succeeds in fixing some of [target]'s infection"
	var/self_msg = "You successfully manage to remove some of [target]'s infection"

	var/germ_healed = germ_amount_healed
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	germ_healed += germ_amount_healed
	affected.germ_level = max(affected.germ_level - germ_amount_healed, 0)

	self_msg += get_progress(user, target, target_zone, germ_healed)

	if(COOLDOWN_FINISHED(src, success_message_spam_cooldown))
		user.visible_message(
			"<span class='notice'>[outer_msg].</span>",
			"<span class='notice'>[self_msg].</span>",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		COOLDOWN_START(src, success_message_spam_cooldown, 7 SECONDS)

	// retry ad nauseum; can_repeat should handle anything else.
	if(affected.germ_level > 0)
		return SURGERY_STEP_RETRY
	else
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/heal_infection/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(3, BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/heal_infection/proc/get_progress(mob/user, mob/living/carbon/target, target_zone, germ_healed)
	if(!germ_healed)
		return

	var/progress_text
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	switch(affected.germ_level)
		if(1 to INFECTION_LEVEL_ONE - 1)
			progress_text = ", removing the last traces of the infection"
		if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
			progress_text = ", counting down the small bits of infection"
		if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
			progress_text = ", continuing to eliminate the spots of infection"
		if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
			progress_text = ", still counting some moderate spots of infection"
		if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
			progress_text = ", steadying yourself for the long surgery ahead"
		if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
			progress_text = ", burning through some of the severe spots of infection"
		if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
			progress_text = ", though [target.p_their()] [parse_zone(target_zone)] still feels like more bacteria than flesh"
		if(INFECTION_LEVEL_THREE to INFINITY)
			progress_text = ", though you feel like you're barely making a dent in [target.p_their()] near-septic [parse_zone(target_zone)]"

	return progress_text

/datum/surgery_step/pull_skin
	name = "pull skin"

	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		/obj/item/scalpel/laser/manager = 100,
		/obj/item/retractor = 100,
		/obj/item/crowbar = 90,
		/obj/item/kitchen/utensil/fork = 60
	)

	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	time = 2.4 SECONDS

/datum/surgery_step/pull_skin/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pull closed the incision on [target]'s [affected.name] with [tool]."
	var/self_msg = "You start to pull closed the incision on [target]'s [affected.name] with [tool]."

	user.visible_message(msg, self_msg, chat_message_type = MESSAGE_TYPE_COMBAT)
	affected.custom_pain("It feels like the skin on your [affected.name] is on fire!")
	return ..()

/datum/surgery_step/pull_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='notice'>[user] pulls the incision closed on [target]'s [affected.name] with [tool].</span>"
	var/self_msg = "<span class='notice'>You pull the incision closed on [target]'s [affected.name] with [tool].</span>"

	user.visible_message(msg, self_msg, chat_message_type = MESSAGE_TYPE_COMBAT)
	affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/pull_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of incision on [target]'s [affected.name] with [tool]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, tearing the edges of incision on [target]'s [affected.name] with [tool]!</span>"
	user.visible_message(msg, self_msg, chat_message_type = MESSAGE_TYPE_COMBAT)
	target.apply_damage(12, BRUTE, affected, sharp = TRUE)
	return SURGERY_STEP_RETRY
