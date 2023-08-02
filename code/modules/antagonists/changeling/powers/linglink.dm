/datum/action/changeling/linglink
	name = "Hivemind Link"
	desc = "We link our victim's mind into the hivemind for personal interrogation."
	helptext = "If we find a human mad enough to support our cause, this can be a helpful tool to stay in touch."
	button_icon_state = "hivemind_link"
	power_type = CHANGELING_INNATE_POWER
	chemical_cost = 0
	req_human = TRUE


/datum/action/changeling/linglink/can_sting(mob/living/carbon/user, ignore_linking = FALSE)
	if(!..())
		return FALSE

	if(cling.is_linking && !ignore_linking)
		to_chat(user, span_warning("We have already formed a link with the victim!"))
		return FALSE

	var/obj/item/grab/grab = user.get_active_hand()
	if(!istype(grab))
		to_chat(user, span_warning("We must be tightly grabbing a creature in our active hand to link with them!"))
		return FALSE

	if(grab.state <= GRAB_AGGRESSIVE)
		to_chat(user, span_warning("We must have a tighter grip to link with this creature!"))
		return FALSE

	var/mob/living/carbon/target = grab.affecting
	if(!ishuman(target))
		return FALSE

	if(!target.mind)
		to_chat(user, span_warning("The victim has no mind to link to!"))
		return FALSE

	if(target.stat == DEAD)
		to_chat(user, span_warning("The victim is dead, you cannot link to a dead mind!"))
		return FALSE

	if(target.has_brain_worms())
		to_chat(user, span_warning("Alien intelligence in victims's body prevents us from linking!"))
		return FALSE

	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_warning("We can not form a link with our kin!"))
		return FALSE

	return TRUE


/datum/action/changeling/linglink/sting_action(mob/user)
	var/obj/item/grab/grab = user.get_active_hand()
	var/mob/living/carbon/human/target = grab.affecting
	cling.is_linking = TRUE

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, span_notice("This creature is compatible. We must hold still..."))

			if(2)
				user.visible_message(span_warning("[user] extends a small proboscis!"), \
									span_notice("We stealthily stab [target] with a minor proboscis..."))
				to_chat(target, span_userdanger("You experience a stabbing sensation and your ears begin to ring..."))

			if(3)
				to_chat(target, span_userdanger("A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!"))

		if(!do_mob(user, target, 2 SECONDS) || !can_sting(user, TRUE))
			to_chat(user, span_warning("Linking process was interrupted!"))
			cling?.is_linking = FALSE
			return FALSE

	user.visible_message(span_danger("[user] stabs [target] with the proboscis!"), \
						span_notice("You mold the [target]'s mind like clay, [target.p_they()] can now speak in the hivemind!"))
	to_chat(target, "<font color=#800040><span class='boldannounce'>You can now communicate in the changeling hivemind, say \":g message\" to communicate!</span>")

	for(var/mob/ling in GLOB.mob_list)
		if(GLOB.all_languages["Changeling"] in ling.languages)
			to_chat(ling, span_changeling("We can sense a foreign presence in the hivemind..."))

	cling?.is_linking = FALSE
	target.add_language("Changeling")
	target.say(":g AAAAARRRRGGGGGHHHHH!!")
	target.reagents.add_reagent("salbutamol", 40) // So they don't choke to death while you interrogate them

	addtimer(CALLBACK(src, PROC_REF(remove_language), target, user), 3 MINUTES, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE


/datum/action/changeling/linglink/proc/remove_language(mob/target, mob/user)
	if(QDELETED(target))
		return

	target.remove_language("Changeling")
	to_chat(target, span_userdanger("The link cannot be sustained any longer, your connection to the hivemind has faded!"))

	if(!QDELETED(user))
		to_chat(user, span_changeling("You cannot sustain the connection any longer, your victim fades from the hivemind"))

