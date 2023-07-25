/datum/action/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment. Costs 25 chemicals."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off."
	button_icon_state = "chameleon_skin"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 25
	req_human = TRUE


/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/h_owner = user
	if(!istype(h_owner))	// SHOULD always be human, because req_human = TRUE, but better safe than sorry
		return FALSE

	if(h_owner.dna.GetSEState(GLOB.chameleonblock))
		h_owner.dna.SetSEState(GLOB.chameleonblock, FALSE)
		genemutcheck(h_owner, GLOB.chameleonblock, null, MUTCHK_FORCED)
	else
		h_owner.dna.SetSEState(GLOB.chameleonblock, TRUE)
		genemutcheck(h_owner, GLOB.chameleonblock, null, MUTCHK_FORCED)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/datum/action/changeling/chameleon_skin/Remove(mob/user)
	var/mob/living/carbon/c_owner = user
	if(!QDELETED(c_owner) && c_owner.dna?.GetSEState(GLOB.chameleonblock))
		c_owner.dna.SetSEState(GLOB.chameleonblock, FALSE)
		genemutcheck(c_owner, GLOB.chameleonblock, null, MUTCHK_FORCED)
	..()
