/datum/action/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment. Costs 25 chemicals."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off."
	button_icon_state = "chameleon_skin"
	dna_cost = 2
	chemical_cost = 25
	req_human = 1

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/H = user //SHOULD always be human, because req_human = 1
	if(!istype(H)) // req_human could be done in can_sting stuff.
		return
	if(H.dna.GetSEState(GLOB.chameleonblock))
		H.dna.SetSEState(GLOB.chameleonblock, 0)
		singlemutcheck(H, GLOB.chameleonblock, MUTCHK_FORCED)
	else
		H.dna.SetSEState(GLOB.chameleonblock, 1)
		singlemutcheck(H, GLOB.chameleonblock, MUTCHK_FORCED)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	var/mob/living/carbon/C = user
	if(C.dna.GetSEState(GLOB.chameleonblock))
		C.dna.SetSEState(GLOB.chameleonblock, 0)
		singlemutcheck(C, GLOB.chameleonblock, MUTCHK_FORCED)
	..()
