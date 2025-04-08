/// Type of tipped reaction that is akin to puppy dog eyes.
/datum/ai_behavior/tipped_reaction

/datum/ai_behavior/tipped_reaction/perform(seconds_per_tick, datum/ai_controller/controller, tipper_key, reacting_key)
	var/mob/living/carbon/tipper = controller.blackboard[tipper_key]

	// visible part of the visible message
	var/seen_message = ""
	// self part of the visible message
	var/self_message = ""
	// the mob we're looking to for aid
	var/mob/living/carbon/savior
	// look for someone in a radius around us for help. If our original tipper is in range, prioritize them
	for(var/mob/living/carbon/potential_aid in oview(3, get_turf(controller.pawn)))
		if(potential_aid == tipper)
			savior = tipper
			break
		savior = potential_aid

	if(prob(75) && savior)
		var/text = pick("imploringly", "pleadingly", "with a resigned expression")
		seen_message = "[controller.pawn] looks at [savior] [text]."
		self_message = "You look at [savior] [text]."
	else
		seen_message = "[controller.pawn] seems resigned to its fate."
		self_message = "You resign yourself to your fate."
	controller.pawn.visible_message("<span class='notice'>[seen_message]</span>", "<span class='notice'>[self_message]</span>")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/tipped_reaction/finish_action(datum/ai_controller/controller, succeeded, tipper_key, reacting_key)
	. = ..()
	controller.set_blackboard_key(reacting_key, FALSE)
	controller.clear_blackboard_key(tipper_key)
