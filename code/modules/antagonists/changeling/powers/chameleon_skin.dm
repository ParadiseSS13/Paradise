/datum/action/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment. Costs 25 chemicals."
	helptext = "Allows us to become invisible after a few seconds of standing still. While active, silences our footsteps and muddles our fingerprints. Can be toggled on and off."
	button_icon_state = "chameleon_skin"
	dna_cost = 4
	chemical_cost = 25
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	menu_location = CLING_MENU_UTILITY

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/H = user //SHOULD always be human, because req_human = TRUE
	if(HAS_TRAIT_FROM(user, TRAIT_SILENT_FOOTSTEPS, CHANGELING_TRAIT))
		REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, CHANGELING_TRAIT)
	else
		ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, CHANGELING_TRAIT)
	if(H.dna.GetSEState(GLOB.chameleonblock))
		H.dna.SetSEState(GLOB.chameleonblock, 0)
		singlemutcheck(H, GLOB.chameleonblock, MUTCHK_FORCED)
		H.dna.SetSEState(GLOB.noprintsblock, 0)
		singlemutcheck(H, GLOB.noprintsblock, MUTCHK_FORCED)
		REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, CHANGELING_TRAIT)
	else
		H.dna.SetSEState(GLOB.chameleonblock, 1)
		singlemutcheck(H, GLOB.chameleonblock, MUTCHK_FORCED)
		H.dna.SetSEState(GLOB.noprintsblock, 1)
		singlemutcheck(H, GLOB.noprintsblock, MUTCHK_FORCED)
		ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, CHANGELING_TRAIT)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	var/mob/living/carbon/C = user
	if(C.dna.GetSEState(GLOB.chameleonblock))
		C.dna.SetSEState(GLOB.chameleonblock, 0)
		singlemutcheck(C, GLOB.chameleonblock, MUTCHK_FORCED)
	if(C.dna.GetSEState(GLOB.noprintsblock))
		C.dna.SetSEState(GLOB.noprintsblock, 0)
		singlemutcheck(C, GLOB.noprintsblock, MUTCHK_FORCED)
	..()
