/obj/effect/proc_holder/changeling/linglink
	name = "Hivemind Link"
	desc = "Link your victim's mind into the hivemind for personal interrogation"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/linglink/can_sting(mob/living/carbon/user)
	if(!..())
		return
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/grab/G = user.get_active_hand()

	if(changeling.islinking)
		to_chat(user, "<span class='warning'>We have already formed a link with the victim!</span>")
		return
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be tightly grabbing a creature in our active hand to link with them!</span>")
		return
	if(G.state <= GRAB_AGGRESSIVE)
		to_chat(user, "<span class='warning'>We must have a tighter grip to link with this creature!</span>")
		return
	if(iscarbon(G.affecting))
		var/mob/living/carbon/target = G.affecting
		if(!target.mind)
			to_chat(user, "<span class='warning'>The victim has no mind to link to!</span>")
			return
		if(target.stat == DEAD)
			to_chat(user, "<span class='warning'>The victim is dead, you cannot link to a dead mind!</span>")
			return
		if(target.mind.changeling)
			to_chat(user, "<span class='warning'>The victim is already a part of the hivemind!</span>")
			return
		return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/linglink/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/target = G.affecting
	changeling.islinking = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(user, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We stealthily stab [target] with a minor proboscis...</span>")
				to_chat(target, "<span class='userdanger'>You experience a stabbing sensation and your ears begin to ring...</span>")
			if(3)
				to_chat(user, "<span class='notice'>You mold the [target]'s mind like clay, [target.p_they()] can now speak in the hivemind!</span>")
				to_chat(target, "<span class='userdanger'>A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!</span>")
				for(var/mob/M in GLOB.mob_list)
					if(GLOB.all_languages["Changeling"] in M.languages)
						to_chat(M, "<i><font color=#800080>We can sense a foreign presence in the hivemind...</font></i>")
				target.mind.linglink = 1
				target.add_language("Changeling")
				target.say(":g AAAAARRRRGGGGGHHHHH!!")
				to_chat(target, "<font color=#800040><span class='boldannounce'>You can now communicate in the changeling hivemind, say \":g message\" to communicate!</span>")
				target.reagents.add_reagent("salbutamol", 40) // So they don't choke to death while you interrogate them
				sleep(1800)
		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 20))
			to_chat(user, "<span class='warning'>Our link with [target] has ended!</span>")
			target.remove_language("Changeling")
			changeling.islinking = 0
			target.mind.linglink = 0
			return

	target.remove_language("Changeling")
	changeling.islinking = 0
	target.mind.linglink = 0
	to_chat(user, "<span class='notice'>You cannot sustain the connection any longer, your victim fades from the hivemind</span>")
	to_chat(target, "<span class='userdanger'>The link cannot be sustained any longer, your connection to the hivemind has faded!</span>")
