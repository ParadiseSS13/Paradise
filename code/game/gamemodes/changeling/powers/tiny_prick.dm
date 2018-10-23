/obj/effect/proc_holder/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby"
	var/sting_icon = null

/obj/effect/proc_holder/changeling/sting/Click()
	var/mob/user = usr
	if(!user || !user.mind || !user.mind.changeling)
		return
	if(!(user.mind.changeling.chosen_sting))
		set_sting(user)
	else
		unset_sting(user)
	return

/obj/effect/proc_holder/changeling/sting/proc/set_sting(var/mob/user)
	to_chat(user, "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>")
	user.mind.changeling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/obj/effect/proc_holder/changeling/sting/proc/unset_sting(var/mob/user)
	to_chat(user, "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>")
	user.mind.changeling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = 101

/mob/living/carbon/proc/unset_sting()
	if(mind && mind.changeling && mind.changeling.chosen_sting)
		mind.changeling.chosen_sting.unset_sting(src)

/obj/effect/proc_holder/changeling/sting/can_sting(var/mob/user, var/mob/target)
	if(!..())
		return
	if(!user.mind.changeling.chosen_sting)
		to_chat(user, "We haven't prepared our sting yet!")
	if(!iscarbon(target))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.isSynthetic())
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

/obj/effect/proc_holder/changeling/sting/sting_feedback(var/mob/user, var/mob/target)
	if(!target)
		return
	to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	if(target.mind && target.mind.changeling)
		to_chat(target, "<span class='warning'>You feel a tiny prick.</span>")
		add_attack_logs(user, target, "Unsuccessful sting (changeling)")
	return 1


/obj/effect/proc_holder/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform."
	helptext = "The victim will transform much like a changeling would. The effects will be obvious to the victim, and the process will damage our genomes."
	sting_icon = "sting_transform"
	chemical_cost = 50
	dna_cost = 3
	genetic_damage = 100
	var/datum/dna/selected_dna = null

/obj/effect/proc_holder/changeling/sting/transformation/Click()
	var/mob/user = usr
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.chosen_sting)
		unset_sting(user)
		return
	selected_dna = changeling.select_dna("Select the target DNA: ", "Target DNA")
	if(!selected_dna)
		return
	if((NOTRANSSTING in selected_dna.species.species_traits) || selected_dna.species.is_small)
		to_chat(user, "<span class='warning'>The selected DNA is incompatible with our sting.</span>")
		return
	..()

/obj/effect/proc_holder/changeling/sting/transformation/can_sting(var/mob/user, var/mob/target)
	if(!..())
		return
	if((HUSK in target.mutations) || (!ishuman(target)))
		to_chat(user, "<span class='warning'>Our sting appears ineffective against its DNA.</span>")
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(NO_DNA in H.dna.species.species_traits)
			to_chat(user, "<span class='warning'>This won't work on a creature without DNA.</span>")
			return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/sting/transformation/sting_action(var/mob/user, var/mob/target)
	add_attack_logs(user, target, "Transformation sting (changeling) (new identity is [selected_dna.real_name])")
	if(issmall(target))
		to_chat(user, "<span class='notice'>Our genes cry out as we sting [target.name]!</span>")

	if(iscarbon(target) && (target.status_flags & CANWEAKEN))
		var/mob/living/carbon/C = target
		C.do_jitter_animation(500)

	target.visible_message("<span class='danger'>[target] begins to violenty convulse!</span>","<span class='userdanger'>You feel a tiny prick and a begin to uncontrollably convulse!</span>")

	spawn(10)
		transform_dna(target,selected_dna)//target is always human so no problem here
	feedback_add_details("changeling_powers","TS")
	return TRUE

obj/effect/proc_holder/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	sting_icon = "sting_extract"
	chemical_cost = 25
	dna_cost = 0

/obj/effect/proc_holder/changeling/sting/extract_dna/can_sting(var/mob/user, var/mob/target)
	if(..())
		return user.mind.changeling.can_absorb_dna(user, target)

/obj/effect/proc_holder/changeling/sting/extract_dna/sting_action(var/mob/user, var/mob/living/carbon/human/target)
	add_attack_logs(user, target, "Extraction sting (changeling)")
	if(!(user.mind.changeling.has_dna(target.dna)))
		user.mind.changeling.absorb_dna(target, user)
	feedback_add_details("changeling_powers","ED")
	return 1

obj/effect/proc_holder/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	sting_icon = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/mute/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_attack_logs(user, target, "Mute sting (changeling)")
	target.AdjustSilence(30)
	feedback_add_details("changeling_powers","MS")
	return 1

obj/effect/proc_holder/changeling/sting/blind
	name = "Blind Sting"
	desc = "Temporarily blinds the target."
	helptext = "This sting completely blinds a target for a short time."
	sting_icon = "sting_blind"
	chemical_cost = 25
	dna_cost = 1

/obj/effect/proc_holder/changeling/sting/blind/sting_action(var/mob/living/user, var/mob/living/target)
	add_attack_logs(user, target, "Blind sting (changeling)")
	to_chat(target, "<span class='danger'>Your eyes burn horrifically!</span>")
	target.BecomeNearsighted()
	target.EyeBlind(20)
	target.EyeBlurry(40)
	feedback_add_details("changeling_powers","BS")
	return 1

obj/effect/proc_holder/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "Causes terror in the target."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	sting_icon = "sting_lsd"
	chemical_cost = 10
	dna_cost = 1

/obj/effect/proc_holder/changeling/sting/LSD/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_attack_logs(user, target, "LSD sting (changeling)")
	spawn(rand(300,600))
		if(target)
			target.Hallucinate(400)
	feedback_add_details("changeling_powers","HS")
	return 1

obj/effect/proc_holder/changeling/sting/cryo //Enable when mob cooling is fixed so that frostoil actually makes you cold, instead of mostly just hungry.
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals that freeze them."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	sting_icon = "sting_cryo"
	chemical_cost = 15
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/cryo/sting_action(var/mob/user, var/mob/target)
	add_attack_logs(user, target, "Cryo sting (changeling)")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("ice", 30)
	feedback_add_details("changeling_powers","CS")
	return 1
