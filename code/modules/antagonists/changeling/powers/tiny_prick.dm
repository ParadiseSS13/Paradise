/datum/action/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby"
	power_type = CHANGELING_UNOBTAINABLE_POWER
	req_human = TRUE
	var/sting_icon = null
	/// A middle click override used to intercept changeling stings performed on a target.
	var/datum/middleClickOverride/callback_invoker/click_override


/datum/action/changeling/sting/New(Target)
	. = ..()
	click_override = new(CALLBACK(src, PROC_REF(try_to_sting)))


/datum/action/changeling/sting/Destroy(force, ...)
	if(cling.owner.current && cling.owner.current.middleClickOverride == click_override) // this is a very scuffed way of doing this honestly
		cling.owner.current.middleClickOverride = null
	QDEL_NULL(click_override)
	if(cling.chosen_sting == src)
		cling.chosen_sting = null
	return ..()


/datum/action/changeling/sting/Trigger()
	if(!ischangeling(owner) || !ishuman(owner))
		to_chat(owner, span_warning("We cannot do that in this form!"))
		return

	if(!cling.chosen_sting)
		set_sting()
	else
		unset_sting()


/datum/action/changeling/sting/proc/set_sting()
	var/mob/living/user = owner
	to_chat(user, span_notice("We prepare our sting, use <B>Alt+Click</B> or middle mouse button on a target to sting them."))
	user.middleClickOverride = click_override
	cling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0


/datum/action/changeling/sting/proc/unset_sting()
	var/mob/living/user = owner
	to_chat(user, span_warning("We retract our sting, we can't sting anyone for now."))
	user.middleClickOverride = null
	cling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT


/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..() || !iscarbon(target) || !isturf(user.loc))
		return FALSE

	if(user == target)
		to_chat(user, span_warning("Using sting on ourselves would be pretty stupid..."))
		return FALSE

	if(!cling.chosen_sting)
		to_chat(user, span_warning("We haven't prepared our sting yet!"))
		return FALSE

	if(get_dist(user, target) > cling.sting_range) // Too far, don't bother pathfinding
		to_chat(user, span_warning("Our target is too far for our sting!"))
		return FALSE

	if(ismachineperson(target))
		to_chat(user, span_warning("This won't work on synthetics."))
		return FALSE

	if(ischangeling(target))
		sting_feedback(user, target)
		take_chemical_cost()
		return FALSE

	if(!AStar(user, target.loc, /turf/proc/Distance, cling.sting_range, simulated_only = FALSE))
		to_chat(user, span_warning("Our target is too far for our sting!"))
		return FALSE

	return TRUE


/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return FALSE

	to_chat(user, span_notice("We stealthily sting [target.name]."))
	if(ischangeling(target))
		to_chat(target, span_warning("You feel a tiny prick."))
		add_attack_logs(user, target, "Unsuccessful sting (changeling)")
	return TRUE


/**
 * Extract DNA Sting
 */
/datum/action/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA. Costs 25 chemicals."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	button_icon_state = "sting_extract"
	sting_icon = "sting_extract"
	power_type = CHANGELING_INNATE_POWER
	chemical_cost = 25


/datum/action/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		return cling.can_absorb_dna(target)


/datum/action/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	add_attack_logs(user, target, "Extraction sting (changeling)")
	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/**
 * Transformation Sting
 */
/datum/action/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform. Costs 50 chemicals."
	helptext = "The victim will transform much like a changeling would. The effects will be obvious to the victim, and the process will damage our genomes."
	button_icon_state = "sting_transform"
	sting_icon = "sting_transform"
	power_type = CHANGELING_PURCHASABLE_POWER
	chemical_cost = 50
	dna_cost = 3
	genetic_damage = 100
	var/datum/dna/selected_dna = null


/datum/action/changeling/sting/transformation/Destroy(force, ...)
	selected_dna = null
	return ..()


/datum/action/changeling/sting/transformation/Trigger()
	if(!ishuman(owner))
		to_chat(owner, span_warning("We cannot do that in this form!"))
		return

	if(cling?.chosen_sting)
		unset_sting()
		return

	selected_dna = cling.select_dna("Select the target DNA: ", "Target DNA")

	if(!selected_dna)
		return

	if((NOTRANSSTING in selected_dna.species.species_traits) || selected_dna.species.is_small)
		to_chat(cling?.owner?.current, span_warning("The selected DNA is incompatible with our sting."))
		return

	..()


/datum/action/changeling/sting/transformation/can_sting(mob/user, mob/target)
	if(!..())
		return FALSE

	if((HUSK in target.mutations) || (!ishuman(target)))
		to_chat(user, span_warning("Our sting appears ineffective against its DNA."))
		return FALSE

	if(has_no_DNA(target))
		to_chat(user, span_warning("This won't work on a creature without DNA."))
		return FALSE

	return TRUE


/datum/action/changeling/sting/transformation/sting_action(mob/user, mob/target)
	add_attack_logs(user, target, "Transformation sting (changeling) (new identity is [selected_dna.real_name])")
	if(issmall(target))
		to_chat(user, span_notice("Our genes cry out as we sting [target.name]!"))

	if(iscarbon(target) && (target.status_flags & CANWEAKEN))
		var/mob/living/carbon/C = target
		C.do_jitter_animation(500)

	target.visible_message(span_danger("[target] begins to violenty convulse!"), \
							span_userdanger("You feel a tiny prick and a begin to uncontrollably convulse!"))

	addtimer(CALLBACK(src, PROC_REF(victim_transformation), target, selected_dna), 1 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/datum/action/changeling/sting/transformation/proc/victim_transformation(mob/target, datum/dna/DNA)
	if(QDELETED(target) || QDELETED(DNA))
		return

	transform_dna(target, DNA)


/**
 * Mute Sting
 */
/datum/action/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time. Costs 20 chemicals."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	button_icon_state = "sting_mute"
	sting_icon = "sting_mute"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 20


/datum/action/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	add_attack_logs(user, target, "Mute sting (changeling)")
	target.AdjustSilence(60 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/**
 * Blind Sting
 */
/datum/action/changeling/sting/blind
	name = "Blind Sting"
	desc = "We temporarily blind our victim. Costs 25 chemicals."
	helptext = "This sting completely blinds a target for a short time, and leaves them with blurred vision for a long time."
	button_icon_state = "sting_blind"
	sting_icon = "sting_blind"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 25


/datum/action/changeling/sting/blind/sting_action(mob/living/user, mob/living/target)
	add_attack_logs(user, target, "Blind sting (changeling)")
	to_chat(target, "<span class='danger'>Your eyes burn horrifically!</span>")
	target.BecomeNearsighted()
	target.EyeBlind(40 SECONDS)
	target.EyeBlurry(80 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/**
 * Hallucination Sting
 */
/datum/action/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "We cause mass terror to our victim. Costs 10 chemicals."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	button_icon_state = "sting_lsd"
	sting_icon = "sting_lsd"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 10


/datum/action/changeling/sting/LSD/sting_action(mob/user, mob/living/carbon/target)
	add_attack_logs(user, target, "LSD sting (changeling)")
	addtimer(CALLBACK(src, PROC_REF(start_hallucinations), target, 400 SECONDS), rand(30 SECONDS, 60 SECONDS))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/LSD/proc/start_hallucinations(mob/living/carbon/target, amount)
	if(!QDELETED(target))
		target.Hallucinate(amount)


/**
 * Cryogenic Sting
 */
/datum/action/changeling/sting/cryo //Enable when mob cooling is fixed so that frostoil actually makes you cold, instead of mostly just hungry.
	name = "Cryogenic Sting"
	desc = "We silently sting our victim with a cocktail of chemicals that freezes them from the inside. Costs 15 chemicals."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	button_icon_state = "sting_cryo"
	sting_icon = "sting_cryo"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 15


/datum/action/changeling/sting/cryo/sting_action(mob/user, mob/target)
	add_attack_logs(user, target, "Cryo sting (changeling)")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("ice", 30)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

