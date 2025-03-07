/datum/surgery/infection
	name = "External Infection Treatment"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/heal_infection, /datum/surgery_step/generic/cauterize)
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

/// Get a message indicating how the surgery is going.
/datum/surgery_step/heal_infection/proc/get_progress(mob/user, mob/living/carbon/target, germ_healed)
	return

/datum/surgery_step/heal_infection/proc/can_be_healed(mob/living/user, mob/living/carbon/target, target_zone)
	if(germ_amount_healed == 0)
		stack_trace("A healing surgery was given no healing values.")
		return FALSE

	return (germ_amount_healed && target.germ_level)

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

	germ_healed += germ_amount_healed
	affected.germ_level = max(affected.germ_level - germ_amount_healed, 0)

	self_msg += get_progress(user, target, germ_healed)

	if(COOLDOWN_FINISHED(src, success_message_spam_cooldown))
		user.visible_message(
			"<span class='notice'>[outer_msg].</span>",
			"<span class='notice'>[self_msg].</span>",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		COOLDOWN_START(src, success_message_spam_cooldown, 10 SECONDS)

	// retry ad nauseum; can_repeat should handle anything else.
	return SURGERY_STEP_RETRY

/datum/surgery_step/heal_infection/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(3, BURN, affected)
	return SURGERY_STEP_RETRY
