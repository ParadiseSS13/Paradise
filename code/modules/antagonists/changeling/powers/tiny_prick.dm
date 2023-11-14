/datum/action/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby"
	power_type = CHANGELING_UNOBTAINABLE_POWER
	menu_location = CLING_MENU_STINGS
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

/datum/action/changeling/sting/Trigger(left_click)
	if(!cling.chosen_sting)
		set_sting()
	else
		unset_sting()

/datum/action/changeling/sting/proc/set_sting()
	var/mob/living/user = owner
	to_chat(user, "<span class='warning'>We prepare our sting, use alt+click or middle mouse button on a target to sting them.</span>")
	user.middleClickOverride = click_override
	cling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/datum/action/changeling/sting/proc/unset_sting()
	var/mob/living/user = owner
	to_chat(user, "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>")
	user.middleClickOverride = null
	cling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = 101

/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..() || !iscarbon(target) || !isturf(user.loc))
		return FALSE
	var/target_distance = get_dist(user, target)
	if(target_distance > cling.sting_range) // Too far, don't bother pathfinding
		to_chat(user, "<span class='warning'>Our target is too far for our sting!</span>")
		return FALSE
	if(target_distance && !length(get_path_to(user, target, max_distance = cling.sting_range, simulated_only = FALSE, skip_first = FALSE))) // If they're not on the same turf, check if it can even reach them.
		to_chat(user, "<span class='warning'>Our sting is blocked from reaching our target!</span>")
		return FALSE
	if(!cling.chosen_sting)
		to_chat(user, "<span class='warning'>We haven't prepared our sting yet!</span>")
		return FALSE
	if(ismachineperson(target))
		to_chat(user, "<span class='warning'>This won't work on synthetics.</span>")
		return FALSE
	if(ischangeling(target))
		sting_feedback(user, target)
		take_chemical_cost()
		return FALSE
	return TRUE

/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	if(ischangeling(target))
		to_chat(target, "<span class='warning'>You feel a tiny prick.</span>")
		add_attack_logs(user, target, "Unsuccessful sting (changeling)")
	return TRUE

/datum/action/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA. Costs 25 chemicals."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	button_icon_state = "sting_extract"
	sting_icon = "sting_extract"
	chemical_cost = 25
	power_type = CHANGELING_INNATE_POWER

/datum/action/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		return cling.can_absorb_dna(target)

/datum/action/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	add_attack_logs(user, target, "Extraction sting (changeling)")
	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time. Costs 20 chemicals."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	button_icon_state = "sting_mute"
	sting_icon = "sting_mute"
	chemical_cost = 20
	dna_cost = 4
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	add_attack_logs(user, target, "Mute sting (changeling)")
	target.AdjustSilence(60 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/blind
	name = "Blind Sting"
	desc = "We temporarily blind our victim. Costs 25 chemicals."
	helptext = "This sting completely blinds a target for a short time, and leaves them with blurred vision for a long time."
	button_icon_state = "sting_blind"
	sting_icon = "sting_blind"
	chemical_cost = 25
	dna_cost = 2
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/blind/sting_action(mob/living/user, mob/living/target)
	add_attack_logs(user, target, "Blind sting (changeling)")
	to_chat(target, "<span class='danger'>Your eyes burn horrifically!</span>")
	target.become_nearsighted(EYE_DAMAGE)
	target.EyeBlind(40 SECONDS)
	target.EyeBlurry(80 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/cryo //Enable when mob cooling is fixed so that frostoil actually makes you cold, instead of mostly just hungry.
	name = "Cryogenic Sting"
	desc = "We silently sting our victim with a cocktail of chemicals that freezes them from the inside. Costs 15 chemicals."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	button_icon_state = "sting_cryo"
	sting_icon = "sting_cryo"
	chemical_cost = 15
	dna_cost = 4
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/cryo/sting_action(mob/user, mob/target)
	add_attack_logs(user, target, "Cryo sting (changeling)")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("ice", 30)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/lethargic
	name = "Lethargic Sting"
	desc = "We silently sting our victim with a chemical that will gradually drain their stamina. Costs 50 chemicals."
	helptext = "Does not provide a warning to the victim, though they will quickly realize they have been poisoned."
	button_icon_state = "sting_lethargic"
	sting_icon = "sting_lethargic"
	chemical_cost = 50
	dna_cost = 4
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/lethargic/sting_action(mob/user, mob/target)
	add_attack_logs(user, target, "Lethargic sting (changeling)")
	if(target.reagents)
		target.reagents.add_reagent("tirizene", 10)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
