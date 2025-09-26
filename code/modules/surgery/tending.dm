/**
 * Surgeries for tending brute and burn damage without needing to expend items.
 */


// Since these both share surgery steps, we can only realistically expose one
/datum/surgery_step/proxy/open_organ/extra
	/// Other surgeries to fire off next.
	var/list/other_surgeries

/datum/surgery_step/proxy/open_organ/extra/New()
	for(var/healing_step_type in other_surgeries)
		if(!ispath(healing_step_type))
			CRASH("open_organ was given an additional option that was not a type path: [healing_step_type]")
		branches |= healing_step_type
	return ..()

/datum/surgery_step/proxy/open_organ/extra/brute
	other_surgeries = list(/datum/surgery/intermediate/heal/brute)

/datum/surgery_step/proxy/open_organ/extra/burn
	other_surgeries = list(/datum/surgery/intermediate/heal/burn)

/datum/surgery/heal
	abstract = TRUE  // don't need this popping up
	/// A subtype of /datum/surgery_step/heal that this will invoke.
	var/healing_step_type
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/heal,
		/datum/surgery_step/generic/cauterize
	)

/datum/surgery/heal/New(atom/surgery_target, surgery_location, surgery_bodypart)
	..()
	if(ispath(healing_step_type))
		steps = list(
			/datum/surgery_step/generic/cut_open,
			/datum/surgery_step/generic/clamp_bleeders,
			/datum/surgery_step/generic/retract_skin,
			healing_step_type,
			/datum/surgery_step/generic/cauterize
		)

/datum/surgery_step/heal
	name = "tend something"

	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		TOOL_WIRECUTTER = 65,
		/obj/item/pen = 55
	)

	time = 1.25 SECONDS
	repeatable = TRUE

	preop_sound = 'sound/surgery/retractor2.ogg'

	var/shown_starting_message_already = FALSE

	COOLDOWN_DECLARE(success_message_spam_cooldown)

	var/damage_name_pretty = "wounds"
	/// Amount of brute damage to treat per op.
	var/brute_damage_healed
	/// Amount of burn damage to treat per op.
	var/burn_damage_healed

	/// Multiplier based on the amount of brute damage that the patient has, increasing the efficiency at higher levels of damage.
	var/brute_damage_healmod
	/// Multiplier based on the amount of burn damage that the patient has.
	var/burn_damage_healmod

/// Get a message indicating how the surgery is going.
/datum/surgery_step/heal/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	return

/datum/surgery_step/heal/proc/can_be_healed(mob/living/user, mob/living/carbon/target, target_zone)
	if(brute_damage_healed == 0 && burn_damage_healed == 0)
		stack_trace("A healing surgery was given no healing values.")
		return FALSE

	return (brute_damage_healed && target.get_damage_amount(BRUTE) || burn_damage_healed && target.get_damage_amount(BURN))

/datum/surgery_step/heal/can_repeat(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!can_be_healed(user, target, target_zone))
		to_chat(user, "<span class='notice'>It doesn't look like [target] has any more [damage_name_pretty].</span>")
		return FALSE
	return TRUE

/datum/surgery_step/heal/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!shown_starting_message_already)
		shown_starting_message_already = TRUE
		user.visible_message(
			"[user] starts to patch some of the [damage_name_pretty] on [target]'s [affected.name] with [tool].",
			"You start to patch some of the [damage_name_pretty] on [target]'s [affected.name] with [tool].",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
	affected.custom_pain("Something in your [affected.name] is causing you a lot of pain!")

	return ..()

/datum/surgery_step/heal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	if(!can_be_healed(user, target, target_zone))
		to_chat(user, "<span class='notice'>It doesn't look like [target] has any more [damage_name_pretty].</span>")
		return SURGERY_STEP_CONTINUE

	var/brute_healed = brute_damage_healed
	var/burn_healed = burn_damage_healed

	var/outer_msg = "[user] succeeds in fixing some of [target]'s [damage_name_pretty]"
	var/self_msg = "You successfully manage to patch up some of [target]'s [damage_name_pretty]"

	brute_healed += round((sqrt(target.getBruteLoss()) * brute_damage_healmod), 0.1)
	burn_healed += round((sqrt(target.getFireLoss()) * burn_damage_healmod), 0.1)

	if(!get_location_accessible(target, target_zone))
		brute_healed *= 0.55
		burn_healed *= 0.55
		self_msg += " as best as you can while [target.p_they()] [target.p_have()] clothing on"
		outer_msg += " as best as [user.p_they()] can while [target.p_they()] [target.p_have()] clothing on"

	target.heal_overall_damage(brute_healed, burn_healed)

	self_msg += get_progress(user, target, brute_healed, burn_healed)

	if(COOLDOWN_FINISHED(src, success_message_spam_cooldown))
		user.visible_message(
			"<span class='notice'>[outer_msg].</span>",
			"<span class='notice'>[self_msg].</span>",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		COOLDOWN_START(src, success_message_spam_cooldown, 10 SECONDS)

	// retry ad nauseum; can_repeat should handle anything else.
	return SURGERY_STEP_RETRY

/datum/surgery_step/heal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		"<span class='warning'>[user] screws up, making things worse!</span>",
		"<span class='warning'>You screw up, making things worse!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	var/burn_dealt = burn_damage_healed * 0.8
	var/brute_dealt = brute_damage_healed * 0.8

	brute_dealt += round((sqrt(target.getBruteLoss()) * (brute_damage_healmod * 0.5)), 0.1)
	burn_dealt += round((sqrt(target.getFireLoss()) * (burn_damage_healmod * 0.5)), 0.1)

	target.take_overall_damage(brute_dealt, burn_dealt)

	return SURGERY_STEP_RETRY

/datum/surgery/heal/wounds
	name = "Tend Wounds"
	desc = "Tend a patient's wounds, gradually treating their brute damage."
	abstract = FALSE
	healing_step_type = /datum/surgery_step/proxy/open_organ/extra/brute

/datum/surgery/heal/burns
	name = "Treat Burns"
	desc = "Tend a patient's burns, gradually treating their burn damage."
	abstract = FALSE
	healing_step_type = /datum/surgery_step/proxy/open_organ/extra/burn


/********************BRUTE STEPS********************/


/datum/surgery_step/heal/brute
	name = "tend wounds"
	brute_damage_healed = 7
	brute_damage_healmod = 0.35

/datum/surgery_step/heal/brute/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!brute_healed)
		return

	var/estimated_remaining_steps = target.getBruteLoss() / brute_healed
	var/progress_text

	if(locate(/obj/item/healthanalyzer) in list(user.l_hand, user.r_hand))
		progress_text = ". Remaining brute: <font color='#ff3333'>[target.getBruteLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", stitching up the last few scrapes"
			if(3 to 6)
				progress_text = ", counting down the last few bruises left to treat"
			if(6 to 9)
				progress_text = ", continuing to plug away at [target.p_their()] extensive rupturing"
			if(9 to 12)
				progress_text = ", steadying yourself for the long surgery ahead"
			if(12 to 15)
				progress_text = ", though [target.p_they()] still look[target.p_s()] more like ground beef than a person"
			if(15 to INFINITY)
				progress_text = ", though you feel like you're barely making a dent in treating [target.p_their()] pulped body"

	return progress_text

/datum/surgery_step/heal/burn
	name = "treat burns"
	damage_name_pretty = "burns"
	burn_damage_healed = 7
	burn_damage_healmod = 0.35

/********************BURN STEPS********************/
/datum/surgery_step/heal/burn/get_progress(mob/living/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!burn_healed)
		return
	var/estimated_remaining_steps = target.getFireLoss() / burn_healed
	var/progress_text

	if(locate(/obj/item/healthanalyzer) in list(user.l_hand, user.r_hand))
		progress_text = ". Remaining burn: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", finishing up the last few singe marks"
			if(3 to 6)
				progress_text = ", counting down the last few blisters left to treat"
			if(6 to 9)
				progress_text = ", continuing to plug away at [target.p_their()] thorough roasting"
			if(9 to 12)
				progress_text = ", steadying yourself for the long surgery ahead"
			if(12 to 15)
				progress_text = ", though [target.p_they()] still look[target.p_s()] more like burnt steak than a [target.dna?.species.name || "person" ]"
			if(15 to INFINITY)
				progress_text = ", though you feel like you're barely making a dent in treating [target.p_their()] charred body"

	return progress_text


// Intermediate versions of the above surgeries


/datum/surgery/intermediate/heal
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/intermediate/heal/brute
	name = "Tend Wounds (abstract)"
	desc = "An intermediate surgery to tend to a patient's wounds while they're undergoing another procedure."
	steps = list(
		/datum/surgery_step/heal/brute
	)


/datum/surgery/intermediate/heal/brute/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return
	if(target.getBruteLoss() == 0)
		to_chat(user, "<span class='warning'>[target] doesn't even have a bruise on [target.p_them()], there's nothing to treat.</span>")
		return FALSE
	return TRUE
	// Normally, adding to_chat to can_start is poor practice since this gets called when listing surgery steps.
	// It's alright for intermediate surgeries, though, since they never get listed out

/datum/surgery/intermediate/heal/burn
	name = "Treat Burns (abstract)"
	desc = "An intermediate surgery to tend to a patient's burns while they're undergoing another procedure."
	steps = list(
		/datum/surgery_step/heal/burn
	)

/datum/surgery/intermediate/heal/burn/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return
	if(target.getFireLoss() == 0)
		to_chat(user, "<span class='warning'>[target] doesn't even have a blister on [target.p_them()], there's nothing to treat.</span>")
		return FALSE
	return TRUE
