/datum/action/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	power_type = CHANGELING_INNATE_POWER
	req_human = TRUE

/datum/action/changeling/absorb_dna/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE

	if(cling.is_absorbing)
		to_chat(user, "<span class='warning'>We are already absorbing!</span>")
		return FALSE

	var/obj/item/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return FALSE
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return FALSE

	return cling.can_absorb_dna(G.affecting)

/datum/action/changeling/absorb_dna/sting_action(mob/user)
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	cling.is_absorbing = TRUE
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We extend a proboscis.</span>")
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
			if(3)
				to_chat(user, "<span class='notice'>We stab [target] with the proboscis.</span>")
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>")
				to_chat(target, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				target.take_overall_damage(40)
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[stage]"))
		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our absorption of [target] has been interrupted!</span>")
			cling.is_absorbing = FALSE
			return FALSE

	to_chat(user, "<span class='notice'>We have absorbed [target]!</span>")
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	to_chat(target, "<span class='danger'>You have been absorbed by the changeling!</span>")

	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.set_nutrition(min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(user, 0) //I can read your mind, kekeke. Output all their notes.

		//Some of target's recent speech, so the changeling can attempt to imitate them better.
		//Recent as opposed to all because rounds tend to have a LOT of text.
		var/list/recent_speech = list()

		if(length(target.say_log) > CHANGELING_ABSORB_RECENT_SPEECH)
			recent_speech = target.say_log.Copy(length(target.say_log)-CHANGELING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
		else
			recent_speech = target.say_log.Copy()

		if(length(recent_speech))
			user.mind.store_memory("<B>Some of [target]'s speech patterns. We should study these to better impersonate [target.p_them()]!</B>")
			to_chat(user, "<span class='boldnotice'>Some of [target]'s speech patterns. We should study these to better impersonate [target.p_them()]!</span>")
			for(var/spoken_memory in recent_speech)
				user.mind.store_memory("\"[spoken_memory]\"")
				to_chat(user, "<span class='notice'>\"[spoken_memory]\"</span>")
			user.mind.store_memory("<B>We have no more knowledge of [target]'s speech patterns.</B>")
			to_chat(user, "<span class='boldnotice'>We have no more knowledge of [target]'s speech patterns.</span>")

		var/datum/antagonist/changeling/target_cling = target.mind.has_antag_datum(/datum/antagonist/changeling)
		if(target_cling)//If the target was a changeling, suck out their extra juice and objective points!
			cling.chem_charges += min(target_cling.chem_charges, cling.chem_storage)
			cling.absorbed_count += (target_cling.absorbed_count)

			target_cling.absorbed_dna.len = 1
			target_cling.absorbed_count = 0

	cling.chem_charges = min(cling.chem_charges + 10, cling.chem_storage)

	cling.is_absorbing = FALSE
	cling.can_respec = TRUE
	var/datum/action/changeling/evolution_menu/E = locate() in user.actions
	SStgui.update_uis(E)

	target.death(FALSE)
	target.Drain()
	return TRUE

#undef CHANGELING_ABSORB_RECENT_SPEECH
