/datum/action/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby"
	var/sting_icon = null
	/// A middle click override used to intercept changeling stings performed on a target.
	var/datum/middleClickOverride/callback_invoker/click_override

/datum/action/changeling/sting/New(Target)
	. = ..()
	click_override = new /datum/middleClickOverride/callback_invoker(CALLBACK(src, .proc/try_to_sting))

/datum/action/changeling/sting/Trigger()
	var/mob/user = owner
	if(!user || !user.mind || !user.mind.changeling)
		return
	if(!(user.mind.changeling.chosen_sting))
		set_sting(user)
	else
		unset_sting(user)
	return

/datum/action/changeling/sting/proc/set_sting(mob/living/user)
	to_chat(user, "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>")
	user.middleClickOverride = click_override
	user.mind.changeling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/datum/action/changeling/sting/proc/unset_sting(mob/living/user)
	to_chat(user, "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>")
	user.middleClickOverride = null
	user.mind.changeling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = 101

/mob/living/carbon/proc/unset_sting()
	if(mind && mind.changeling && mind.changeling.chosen_sting)
		mind.changeling.chosen_sting.unset_sting(src)

/datum/action/changeling/sting/can_sting(var/mob/user, var/mob/target)
	if(!..())
		return
	if(!user.mind.changeling.chosen_sting)
		to_chat(user, "We haven't prepared our sting yet!")
	if(!iscarbon(target))
		return
	if(ismachineperson(target))
		to_chat(user, "<span class='warning'>This won't work on synthetics.</span>")
		return
	if(!isturf(user.loc))
		return
	if(!AStar(user, target.loc, /turf/proc/Distance, user.mind.changeling.sting_range, simulated_only = 0))
		return
	if(target.mind && target.mind.changeling)
		sting_feedback(user,target)
		take_chemical_cost(user.mind.changeling)
		return
	return 1

/datum/action/changeling/sting/sting_feedback(var/mob/user, var/mob/target)
	if(!target)
		return
	to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	if(target.mind && target.mind.changeling)
		to_chat(target, "<span class='warning'>You feel a tiny prick.</span>")
		add_attack_logs(user, target, "Unsuccessful sting (changeling)")
	return 1

/datum/action/changeling/sting/false_armblade //Port from TG, credit to them
	name = "False Armblade Sting"
	desc = "We silently sting a human, injecting a retrovirus that mutates their arm to temporarily appear as an armblade. Costs 20 chemicals."
	helptext = "The victim will form an armblade much like a changeling would, except the armblade is dull and useless."
	button_icon_state = "sting_armblade"
	sting_icon = "sting_armblade"
	chemical_cost = 20
	dna_cost = 2
	genetic_damage = 15
	max_genetic_damage = 25

/obj/item/melee/arm_blade/false
	desc = "A grotesque mass of flesh that used to be your arm. Although it looks dangerous at first, you can tell it's actually quite dull and useless."
	force = 5 //Basically as strong as a punch
	fake = TRUE

/datum/action/changeling/sting/false_armblade/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_attack_logs(user, target, "Fake armblade sting (changeling)")

	if(!target.drop_item())
		to_chat(user, "<span class='warning'>The [target.get_active_hand()] is stuck to [target.p_their()] hand, we cannot grow a false armblade over it!</span>")
		return
	..()

	var/obj/item/melee/arm_blade/false/blade = new(target,1)
	target.put_in_hands(blade)
	target.visible_message("<span class='warning'>A grotesque blade forms around [target.name]\'s arm!</span>", "<span class='userdanger'>Your arm twists and mutates, transforming into a horrific monstrosity!</span>", "<span class='hear'>You hear organic matter ripping and tearing!</span>")

	addtimer(CALLBACK(src, /datum/action/changeling/sting/false_armblade/proc/remove_fake, target, blade), 600)
	return TRUE


/datum/action/changeling/sting/false_armblade/proc/remove_fake(mob/target, obj/item/melee/arm_blade/false/blade)
	target.visible_message("<span class='warning'>With a sickening crunch, [target] reforms [target.p_their()] [blade.name] into an arm!</span>","<span class='userdanger'>Your arm twists and mutates... Back to normal, thank god.</span>",)
	qdel(blade)
	target.update_inv_r_hand()
	target.update_inv_l_hand()

/datum/action/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA. Costs 25 chemicals."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	button_icon_state = "sting_extract"
	sting_icon = "sting_extract"
	chemical_cost = 25
	dna_cost = 0

/datum/action/changeling/sting/extract_dna/can_sting(var/mob/user, var/mob/target)
	if(..())
		return user.mind.changeling.can_absorb_dna(user, target)

/datum/action/changeling/sting/extract_dna/sting_action(var/mob/user, var/mob/living/carbon/human/target)
	add_attack_logs(user, target, "Extraction sting (changeling)")
	if(!(user.mind.changeling.has_dna(target.dna)))
		user.mind.changeling.absorb_dna(target, user)
	feedback_add_details("changeling_powers","ED")
	return 1

/datum/action/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time. Costs 20 chemicals."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	button_icon_state = "sting_mute"
	sting_icon = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/datum/action/changeling/sting/mute/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_attack_logs(user, target, "Mute sting (changeling)")
	target.AdjustSilence(30)
	feedback_add_details("changeling_powers","MS")
	return 1

/datum/action/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "We cause mass terror to our victim. Costs 10 chemicals."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	button_icon_state = "sting_lsd"
	sting_icon = "sting_lsd"
	chemical_cost = 10
	dna_cost = 1

/datum/action/changeling/sting/LSD/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_attack_logs(user, target, "LSD sting (changeling)")
	spawn(rand(300,600))
		if(target)
			target.Hallucinate(400)
	feedback_add_details("changeling_powers","HS")
	return 1

/datum/action/changeling/sting/cryo //Enable when mob cooling is fixed so that frostoil actually makes you cold, instead of mostly just hungry.
	name = "Cryogenic Sting"
	desc = "We silently sting our victim with a cocktail of chemicals that freezes them from the inside. Costs 15 chemicals."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	button_icon_state = "sting_cryo"
	sting_icon = "sting_cryo"
	chemical_cost = 15
	dna_cost = 2

/datum/action/changeling/sting/cryo/sting_action(var/mob/user, var/mob/target)
	add_attack_logs(user, target, "Cryo sting (changeling)")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("ice", 30)
	feedback_add_details("changeling_powers","CS")
	return 1
