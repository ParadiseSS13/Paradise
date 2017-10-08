/obj/effect/proc_holder/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off."
	dna_cost = 2
	chemical_cost = 25
	req_human = 1

/obj/effect/proc_holder/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/H = user //SHOULD always be human, because req_human = 1
	if(!istype(H)) // req_human could be done in can_sting stuff.
		return
	if(H.dna.GetSEState(CHAMELEONBLOCK))
		H.dna.SetSEState(CHAMELEONBLOCK, 0)
		genemutcheck(H, CHAMELEONBLOCK, null, MUTCHK_FORCED)
	else
		H.dna.SetSEState(CHAMELEONBLOCK, 1)
		genemutcheck(H, CHAMELEONBLOCK, null, MUTCHK_FORCED)

	feedback_add_details("changeling_powers","CS")
	return TRUE

/obj/effect/proc_holder/changeling/chameleon_skin/on_refund(mob/user)
	var/mob/living/carbon/C = user
	if(C.dna.GetSEState(CHAMELEONBLOCK))
		C.dna.SetSEState(CHAMELEONBLOCK, 0)
		genemutcheck(C, CHAMELEONBLOCK, null, MUTCHK_FORCED)
