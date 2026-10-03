/datum/probe_experiment
	/// Describes what the experiment requires, e.g. "Explore the effects of signifigant brute damage."
	var/desc = "error"
	/// Reward given out on completion
	var/list/reward = list(RESEARCH_POINT_STANDARD = 800) // Each research datum gets 5 of these (at the time of writing) so make it worth.

/// Called by the organ's own on_life() proc, return reward if complete.
/datum/probe_experiment/proc/on_life_effect(mob/living/carbon/human/our_owner)
	log_debug("please tell me we're doing SOMETHING")
	if(!our_owner)
		log_debug("for some reason, there was no our_owner!")
		return
	log_debug("our_owner [our_owner]")

/datum/probe_experiment/wounds
	desc = "Explore the effects of severe brute or burn damage on a living specimen."

/datum/probe_experiment/wounds/on_life_effect(mob/living/carbon/human/our_owner)
	log_debug("we tried brute/burn")
	if(our_owner.getBruteLoss() >= 60 || our_owner.getBruteLoss() >= 60)
		playsound(our_owner, "sound/machines/twobeep.ogg")
		return TRUE

/datum/probe_experiment/special_damage
	desc = "Explore the effects of severe poisoning or suffocation on a living specimen."

/datum/probe_experiment/special_damage/on_life_effect(mob/living/carbon/human/our_owner)
	log_debug("we tried tox/oxy")
	if(our_owner.getToxLoss() >= 60 || our_owner.getOxyLoss() >= 60)
		playsound(our_owner, "sound/machines/twobeep.ogg")
		return TRUE

/datum/probe_experiment/brain_damage
	desc = "Explore the effects of severe brain damage on a living specimen."

/datum/probe_experiment/brain_damage/on_life_effect(mob/living/carbon/human/our_owner)
	log_debug("we tried brain")
	if(our_owner.getBrainLoss() >= 60)
		playsound(our_owner, "sound/machines/twobeep.ogg")
		return TRUE

/datum/probe_experiment/co2_exposure
	desc = "Explore the effects of prolonged carbon dioxide exposure on a living specimen."

/datum/probe_experiment/co2_exposure/on_life_effect(mob/living/carbon/human/our_owner)
	log_debug("we tried co2")
	if(our_owner.co2overloadtime > 200) // 20 seconds
		playsound(our_owner, "sound/machines/twobeep.ogg")
		return TRUE

/datum/probe_experiment/dismemberment
	desc = "Explore the effects of limb dismemberment on a living specimen."

/datum/probe_experiment/dismemberment/on_life_effect(mob/living/carbon/human/our_owner)
	log_debug("we tried dismember")
	for(var/organ_tag in our_owner.dna.species.has_limbs)
		var/obj/item/organ/external/E = our_owner.bodyparts_by_name[organ_tag]
		if(!E)
			playsound(our_owner, "sound/machines/twobeep.ogg")
			return TRUE
