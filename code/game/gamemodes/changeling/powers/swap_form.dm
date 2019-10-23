/datum/action/changeling/swap_form
	name = "Swap Forms"
	desc = "We force ourselves into another form, husking our original body in the process. Costs 10 chemicals."
	helptext = "We will bring all our abilities with us, but we will lose our old form DNA in exchange for the new one. The process is slow, requires the target strangled, and will seem suspicious to observers. "
	button_icon_state = "mindswap"
	chemical_cost = 5 //very slow to use is already a significant downside, doesnt need a significant cost
	dna_cost = 1
	req_human = 1 //Monkeys can't grab

/datum/action/changeling/swap_form/can_sting(var/mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isswapping)
		to_chat(user, "<span class='warning'>We are already swapping form!</span>")
		return

	var/obj/item/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to swap with them.</span>")
		return
	var/mob/living/carbon/human/target = G.affecting
	if((NOCLONE || SKELETON || HUSK) in target.mutations)
		to_chat(user, "<span class='warning'>DNA of [target] is ruined beyond usability!</span>")
		return
	if(!istype(target) || issmall(target) || NO_DNA in target.dna.species.species_traits)
		to_chat(user, "<span class='warning'>[target] is not compatible with this ability.</span>")
		return
	if(target.mind.changeling)
		to_chat(user, "<span class='warning'>We are unable to swap forms with another changeling!</span>")
		return
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	return TRUE

/datum/action/changeling/swap_form/sting_action(var/mob/living/carbon/user)
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	var/datum/changeling/changeling = user.mind.changeling
	changeling.isswapping = TRUE

	for(var/stage = 1, stage <= 3, stage++)
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
				target.take_overall_damage(10)
		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our swapping with [target] has been interrupted!</span>")
			changeling.isswapping = FALSE
			return

	to_chat(user, "<span class='notice'>We have swapped forms with [target]!</span>")
	user.visible_message("<span class='danger'>[user] suddenly drops dead and lets go of [target].</span>")
	to_chat(target, "<span class='danger'>Your body has been taken over by the changeling!</span>")

	var/lingpowers = list()
	for(var/power in changeling.purchasedpowers)
		lingpowers += power

	changeling.absorbed_dna -= changeling.find_dna(user.dna)
	changeling.protected_dna -= changeling.find_dna(user.dna)
	changeling.absorbedcount -= 1
	if(!changeling.has_dna(target.dna))
		changeling.absorb_dna(target, user)
	changeling.trim_dna()

	var/mob/dead/observer/ghost = target.ghostize(0)
	user.mind.transfer_to(target)
	if(ghost && ghost.mind)
		ghost.mind.transfer_to(user)
		GLOB.non_respawnable_keys -= ghost.ckey //they have a new body, let them be able to re-enter their corpse
		user.key = ghost.key
	qdel(ghost)
	target.add_language("Changeling")
	user.remove_language("Changeling")
	user.regenerate_icons()

	for(var/power in lingpowers)
		var/datum/action/changeling/S = power
		target.mind.changeling.purchasedpowers += S
		if(istype(S) && S.needs_button)
			S.Grant(target)

	changeling.isswapping = FALSE

	var/mob/living/carbon/human/H = user
	H.death(0)
	H.Drain()
	return TRUE