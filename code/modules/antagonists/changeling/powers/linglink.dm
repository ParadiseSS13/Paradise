/datum/action/changeling/linglink
	name = "Hivemind Link"
	desc = "We link our victim's mind into the hivemind for personal interrogation."
	helptext = "If we find a human mad enough to support our cause, this can be a helpful tool to stay in touch."
	button_icon_state = "hivemind_link"
	chemical_cost = 0
	power_type = CHANGELING_INNATE_POWER
	req_human = TRUE

/datum/action/changeling/linglink/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE
	var/obj/item/grab/G = user.get_active_hand()

	if(cling.is_linking)
		to_chat(user, "<span class='warning'>We have already formed a link with the victim!</span>")
		return FALSE
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be tightly grabbing a creature in our active hand to link with them!</span>")
		return FALSE
	if(G.state <= GRAB_AGGRESSIVE)
		to_chat(user, "<span class='warning'>We must have a tighter grip to link with this creature!</span>")
		return FALSE
	if(iscarbon(G.affecting))
		var/mob/living/carbon/target = G.affecting
		if(!target.mind)
			to_chat(user, "<span class='warning'>The victim has no mind to link to!</span>")
			return FALSE
		if(target.stat == DEAD)
			to_chat(user, "<span class='warning'>The victim is dead, you cannot link to a dead mind!</span>")
			return FALSE
		if(target.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(user, "<span class='warning'>The victim is already a part of the hivemind!</span>")
			return FALSE
		return cling.can_absorb_dna(target)

/datum/action/changeling/linglink/sting_action(mob/user)
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/target = G.affecting
	cling.is_linking = TRUE
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We stealthily stab [target] with a minor proboscis...</span>")
				to_chat(target, "<span class='userdanger'>You experience a stabbing sensation and your ears begin to ring...</span>")
			if(3)
				to_chat(user, "<span class='notice'>You mold [target]'s mind like clay, [target.p_they()] can now speak in the hivemind!</span>")
				to_chat(target, "<span class='userdanger'>A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!</span>")
				for(var/mob/M in GLOB.mob_list)
					if(GLOB.all_languages["Changeling"] in M.languages)
						to_chat(M, "<span class='changeling'>We can sense a foreign presence in the hivemind...</span>")
				target.mind.linglink = TRUE
				target.add_language("Changeling")
				target.say(":g AAAAARRRRGGGGGHHHHH!!")
				to_chat(target, "<font color=#800040><span class='boldannounce'>You can now communicate in the changeling hivemind, say \":g message\" to communicate!</span>")
				target.reagents.add_reagent("salbutamol", 40) // So they don't choke to death while you interrogate them
				addtimer(CALLBACK(src, .proc/end_link, user, target), 180 SECONDS)

		if(!do_mob(user, target, 2 SECONDS))
			to_chat(user, "<span class='warning'>Our link with [target] has ended!</span>")
			target.remove_language("Changeling")
			cling.is_linking = FALSE
			target.mind.linglink = FALSE
			return FALSE

/datum/action/changeling/linglink/proc/end_link(mob/living/user, mob/living/carbon/target)
	target.remove_language("Changeling")
	cling.is_linking = FALSE
	target.mind.linglink = FALSE
	to_chat(user, "<span class='notice'>You cannot sustain the connection any longer, your victim fades from the hivemind</span>")
	to_chat(target, "<span class='userdanger'>The link cannot be sustained any longer, your connection to the hivemind has faded!</span>")
	return TRUE
