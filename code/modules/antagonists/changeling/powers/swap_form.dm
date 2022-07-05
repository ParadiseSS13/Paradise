/datum/action/changeling/swap_form
	name = "Swap Forms"
	desc = "We force ourselves into the body of another form, pushing their consciousness into the form we left behind. Costs 40 chemicals."
	helptext = "We will bring all our abilities with us, but we will lose our old form DNA in exchange for the new one. The process will seem suspicious to any observers."
	button_icon_state = "mindswap"
	chemical_cost = 40
	dna_cost = 1
	req_human = TRUE //Monkeys can't grab
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/swap_form/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE
	var/obj/item/grab/G = user.get_active_hand()
	if(!istype(G) || (G.state < GRAB_AGGRESSIVE))
		to_chat(user, "<span class='warning'>We must have an aggressive grab on creature in our active hand to do this!</span>")
		return FALSE
	var/mob/living/carbon/human/target = G.affecting
	if(HAS_TRAIT(target, TRAIT_BADDNA) || HAS_TRAIT(target, TRAIT_HUSK) || HAS_TRAIT(target, TRAIT_SKELETONIZED))
		to_chat(user, "<span class='warning'>DNA of [target] is ruined beyond usability!</span>")
		return FALSE
	if(!istype(target) || !target.mind || issmall(target) || HAS_TRAIT(target, TRAIT_GENELESS))
		to_chat(user, "<span class='warning'>[target] is not compatible with this ability.</span>")
		return FALSE
	if(ischangeling(target))
		to_chat(user, "<span class='warning'>We are unable to swap forms with another changeling!</span>")
		return FALSE
	if(target.has_brain_worms() || user.has_brain_worms())
		to_chat(user, "<span class='warning'>A foreign presence repels us from this body!</span>")
		return FALSE
	return TRUE

/datum/action/changeling/swap_form/sting_action(mob/living/carbon/user)
	var/obj/item/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting

	to_chat(user, "<span class='notice'>We tighten our grip. We must hold still....</span>")
	target.Jitter(1000 SECONDS)
	user.Jitter(1000 SECONDS)

	if(!do_mob(user, target, 10 SECONDS))
		to_chat(user, "<span class='warning'>The body swap has been interrupted!</span>")
		return

	to_chat(target, "<span class='userdanger'>[user] tightens [user.p_their()] grip as a painful sensation invades your body.</span>")

	var/datum/dna/DNA = cling.get_dna(user.dna)
	cling.absorbed_dna -= DNA
	cling.protected_dna -= DNA
	cling.absorbed_count--
	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)
	cling.trim_dna()

	var/mob/dead/observer/ghost = target.ghostize(FALSE)
	user.mind.transfer_to(target)
	if(ghost && ghost.mind)
		ghost.mind.transfer_to(user)
		GLOB.non_respawnable_keys -= ghost.ckey //they have a new body, let them be able to re-enter their corpse if they die
		user.key = ghost.key
	qdel(ghost)
	user.Paralyse(4 SECONDS)
	user.regenerate_icons()
	if(target.stat == DEAD && target.suiciding)  //If Target committed suicide, unset flag for User
		target.suiciding = FALSE

	to_chat(target, "<span class='warning'>Our genes cry out as we swap our [user] form for [target].</span>")
	return TRUE
