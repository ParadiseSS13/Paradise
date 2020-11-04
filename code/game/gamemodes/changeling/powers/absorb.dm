/datum/action/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	max_genetic_damage = 100

/datum/action/changeling/absorbDNA/can_sting(mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		to_chat(user, "<span class='warning'>We are already absorbing!</span>")
		return

	var/obj/item/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)

/datum/action/changeling/absorbDNA/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
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
		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our absorption of [target] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(user, "<span class='notice'>We have absorbed [target]!</span>")
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	to_chat(target, "<span class='danger'>You have been absorbed by the changeling!</span>")

	if(!changeling.has_dna(target.dna))
		changeling.absorb_dna(target, user)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.set_nutrition(min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(user, 0) //I can read your mind, kekeke. Output all their notes.

		//Some of target's recent speech, so the changeling can attempt to imitate them better.
		//Recent as opposed to all because rounds tend to have a LOT of text.
		var/list/recent_speech = list()

		if(target.say_log.len > LING_ABSORB_RECENT_SPEECH)
			recent_speech = target.say_log.Copy(target.say_log.len-LING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
		else
			recent_speech = target.say_log.Copy()

		if(recent_speech.len)
			user.mind.store_memory("<B>Some of [target]'s speech patterns. We should study these to better impersonate [target.p_them()]!</B>")
			to_chat(user, "<span class='boldnotice'>Some of [target]'s speech patterns. We should study these to better impersonate [target.p_them()]!</span>")
			for(var/spoken_memory in recent_speech)
				user.mind.store_memory("\"[spoken_memory]\"")
				to_chat(user, "<span class='notice'>\"[spoken_memory]\"</span>")
			user.mind.store_memory("<B>We have no more knowledge of [target]'s speech patterns.</B>")
			to_chat(user, "<span class='boldnotice'>We have no more knowledge of [target]'s speech patterns.</span>")

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += (target.mind.changeling.absorbedcount)

			target.mind.changeling.absorbed_dna.len = 1
			target.mind.changeling.absorbedcount = 0

	changeling.chem_charges=min(changeling.chem_charges+10, changeling.chem_storage)

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	target.death(0)
	target.Drain()
	return 1

//Absorbs the target DNA.
/datum/changeling/proc/absorb_dna(mob/living/carbon/T, var/mob/user)
	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = T.dna.Clone()
	//Steal all of their languages!
	for(var/language in T.languages)
		if(!(language in absorbed_languages))
			absorbed_languages += language
		user.changeling_update_languages(absorbed_languages)

	absorbedcount++
	store_dna(new_dna, user)

/datum/changeling/proc/store_dna(var/datum/dna/new_dna, var/mob/user)
	for(var/datum/objective/escape/escape_with_identity/E in user.mind.objectives)
		if(E.target_real_name == new_dna.real_name)
			protected_dna |= new_dna
			return
	absorbed_dna |= new_dna
	trim_dna()

#undef LING_ABSORB_RECENT_SPEECH
