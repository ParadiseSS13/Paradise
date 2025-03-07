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

/// Get a message indicating how the surgery is going.
/datum/surgery_step/heal/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	return

/datum/surgery_step/heal/proc/can_be_healed(mob/living/user, mob/living/carbon/target, target_zone)
	if(germ_healed == 0)
		stack_trace("A healing surgery was given no healing values.")
		return FALSE

	return (germ_healed && target.germ_level)

/datum/surgery_step/heal/can_repeat(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!can_be_healed(user, target, target_zone))
		to_chat(user, "<span class='notice'>It doesn't look like [target] has any remaining infection.</span>")
		return FALSE
	return TRUE

/datum/surgery_step/heal/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!shown_starting_message_already)
		shown_starting_message_already = TRUE
		user.visible_message(
			"[user] starts to remove some of the infection on [target]'s [affected.name] with [tool].",
			"You start to remove some of the infection on [target]'s [affected.name] with [tool].",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
	affected.custom_pain("Something in your [affected.name] is causing you a lot of pain!")

	return ..()
