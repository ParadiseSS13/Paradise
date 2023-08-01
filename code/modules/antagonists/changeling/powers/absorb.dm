/datum/action/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	power_type = CHANGELING_INNATE_POWER
	chemical_cost = 0
	req_human = TRUE


/datum/action/changeling/absorbDNA/can_sting(mob/living/carbon/user, ignore_absorbing = FALSE)
	if(!..())
		return FALSE

	if(cling.is_absorbing && !ignore_absorbing)
		to_chat(user, span_warning("We are already absorbing!"))
		return FALSE

	var/obj/item/grab/grab = user.get_active_hand()
	if(!istype(grab))
		to_chat(user, span_warning("We must be grabbing a creature in our active hand to absorb them."))
		return FALSE

	if(grab.state <= GRAB_NECK)
		to_chat(user, span_warning("We must have a tighter grip to absorb this creature."))
		return FALSE

	return cling.can_absorb_dna(grab.affecting)


/datum/action/changeling/absorbDNA/sting_action(mob/user)
	var/obj/item/grab/grab = user.get_active_hand()
	var/mob/living/carbon/human/target = grab.affecting
	cling.is_absorbing = TRUE

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, span_notice("This creature is compatible. We must hold still..."))

			if(2)
				user.visible_message(span_warning("[user] extends a proboscis!"), span_notice("We extend a proboscis."))

			if(3)
				user.visible_message(span_danger("[user] stabs [target] with the proboscis!"), span_notice("We stab [target] with the proboscis."))
				to_chat(target, span_danger("You feel a sharp stabbing pain!"))
				target.take_overall_damage(40)

		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[stage]"))
		if(!do_mob(user, target, 15 SECONDS) || !can_sting(user, TRUE))
			to_chat(user, span_warning("Our absorption of [target] has been interrupted!"))
			cling.is_absorbing = FALSE
			return FALSE

	user.visible_message(span_danger("[user] sucks the fluids from [target]!"), span_notice("We have absorbed [target]!"))
	to_chat(target, span_danger("You have been absorbed by the changeling!"))

	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.set_nutrition(min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(user, FALSE) //I can read your mind, kekeke. Output all their notes.

		//Some of target's recent speech, so the changeling can attempt to imitate them better.
		//Recent as opposed to all because rounds tend to have a LOT of text.
		var/list/recent_speech = list()

		if(target.say_log.len > LING_ABSORB_RECENT_SPEECH)
			recent_speech = target.say_log.Copy(target.say_log.len - LING_ABSORB_RECENT_SPEECH + 1, 0) //0 so len-LING_ARS+1 to end of list
		else
			recent_speech = target.say_log.Copy()

		if(length(recent_speech))
			user.mind.store_memory("<B>Some of [target]'s speech patterns. We should study these to better impersonate [target.p_them()]!</B>")
			to_chat(user, span_boldnotice("Some of [target]'s speech patterns. We should study these to better impersonate [target.p_them()]!"))
			for(var/spoken_memory in recent_speech)
				user.mind.store_memory("\"[spoken_memory]\"")
				to_chat(user, span_notice("\"[spoken_memory]\""))
			user.mind.store_memory("<B>We have no more knowledge of [target]'s speech patterns.</B>")
			to_chat(user, span_boldnotice("We have no more knowledge of [target]'s speech patterns."))

		var/datum/antagonist/changeling/target_cling = target?.mind?.has_antag_datum(/datum/antagonist/changeling)
		if(target_cling)//If the target was a changeling, suck out their extra juice and objective points!
			cling.chem_charges += min(target_cling.chem_charges, cling.chem_storage)
			cling.absorbed_count += target_cling.absorbed_count

			target_cling.absorbed_dna.len = 1
			target_cling.absorbed_count = 0

	cling.chem_charges = min(cling.chem_charges + 10, cling.chem_storage)

	cling.is_absorbing = FALSE
	cling.can_respec = TRUE
	var/datum/action/changeling/evolution_menu/menu = locate() in user.actions
	SStgui.update_uis(menu)

	target.death(FALSE)
	target.Drain()
	return TRUE


#undef LING_ABSORB_RECENT_SPEECH

