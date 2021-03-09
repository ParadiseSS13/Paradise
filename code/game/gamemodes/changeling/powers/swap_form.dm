/datum/action/changeling/swap_form
	name = "Swap Forms"
	desc = "We force ourselves into the body of another form, pushing their consciousness into the form we left behind. Costs 40 chemicals."
	helptext = "We will bring all our abilities with us, but we will lose our old form DNA in exchange for the new one. The process will seem suspicious to any observers."
	button_icon_state = "mindswap"
	chemical_cost = 40
	dna_cost = 1
	req_human = 1 //Monkeys can't grab

/datum/action/changeling/swap_form/can_sting(var/mob/living/carbon/user)
	if(!..())
		return
	var/obj/item/grab/G = user.get_active_hand()
	if(!istype(G) || (G.state < GRAB_AGGRESSIVE))
		to_chat(user, "<span class='warning'>We must have an aggressive grab on creature in our active hand to do this!</span>")
		return
	var/mob/living/carbon/human/target = G.affecting
	if((NOCLONE || SKELETON || HUSK) in target.mutations)
		to_chat(user, "<span class='warning'>DNA of [target] is ruined beyond usability!</span>")
		return
	if(!istype(target) || !target.mind || issmall(target) || (NO_DNA in target.dna.species.species_traits))
		to_chat(user, "<span class='warning'>[target] is not compatible with this ability.</span>")
		return
	if(target.mind.changeling)
		to_chat(user, "<span class='warning'>We are unable to swap forms with another changeling!</span>")
		return
	if(target.has_brain_worms() || user.has_brain_worms())
		to_chat(user, "<span class='warning'>A foreign presence repels us from this body!</span>")
		return
	return 1

/datum/action/changeling/swap_form/sting_action(var/mob/living/carbon/user)
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	var/datum/changeling/changeling = user.mind.changeling

	to_chat(user, "<span class='notice'>We tighten our grip. We must hold still....</span>")
	target.do_jitter_animation(500)
	user.do_jitter_animation(500)

	if(!do_mob(user, target, 10 SECONDS))
		to_chat(user, "<span class='warning'>The body swap has been interrupted!</span>")
		return

	to_chat(target, "<span class='userdanger'>[user] tightens [user.p_their()] grip as a painful sensation invades your body.</span>")

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
		GLOB.non_respawnable_keys -= ghost.ckey //they have a new body, let them be able to re-enter their corpse if they die
		user.key = ghost.key
	qdel(ghost)
	user.Paralyse(2)
	target.add_language("Changeling")
	user.remove_language("Changeling")
	user.regenerate_icons()
	if(target.stat == DEAD && target.suiciding)  //If Target committed suicide, unset flag for User
		target.suiciding = 0

	for(var/power in lingpowers)
		var/datum/action/changeling/S = power
		target.mind.changeling.purchasedpowers += S
		if(istype(S) && S.needs_button)
			S.Grant(target)

	to_chat(target, "<span class='warning'>Our genes cry out as we swap our [user] form for [target].</span>")
	return 1
