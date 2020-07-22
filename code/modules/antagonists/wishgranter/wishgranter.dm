/datum/antagonist/wishgranter
	name = "Wishgranter Avatar"

/datum/antagonist/wishgranter/proc/forge_objectives()
	var/datum/objective/hijack/hijack = new
	hijack.owner = owner
	objectives += hijack
	owner.objectives |= objectives

/datum/antagonist/wishgranter/on_gain()
	owner.special_role = "Avatar of the Wish Granter"
	forge_objectives()
	. = ..()
	give_powers()

/datum/antagonist/wishgranter/greet()
	to_chat(owner.current, "<B>Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!</B>")
	owner.announce_objectives()

/datum/antagonist/wishgranter/proc/give_powers()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.ignore_gene_stability = TRUE
	H.dna.SetSEState(HULKBLOCK, TRUE)
	genemutcheck(H, HULKBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(XRAYBLOCK, TRUE)
	genemutcheck(H, XRAYBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(FIREBLOCK, TRUE)
	genemutcheck(H, FIREBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(COLDBLOCK, TRUE)
	genemutcheck(H, COLDBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(TELEBLOCK, TRUE)
	genemutcheck(H, TELEBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(INCREASERUNBLOCK, TRUE)
	genemutcheck(H, INCREASERUNBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(BREATHLESSBLOCK, TRUE)
	genemutcheck(H, BREATHLESSBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(REGENERATEBLOCK, TRUE)
	genemutcheck(H, REGENERATEBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(SHOCKIMMUNITYBLOCK, TRUE)
	genemutcheck(H, SHOCKIMMUNITYBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(SMALLSIZEBLOCK, TRUE)
	genemutcheck(H, SMALLSIZEBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(SOBERBLOCK, TRUE)
	genemutcheck(H, SOBERBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(PSYRESISTBLOCK, TRUE)
	genemutcheck(H, PSYRESISTBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(SHADOWBLOCK, TRUE)
	genemutcheck(H, SHADOWBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(CRYOBLOCK, TRUE)
	genemutcheck(H, CRYOBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(EATBLOCK, TRUE)
	genemutcheck(H, EATBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(JUMPBLOCK, TRUE)
	genemutcheck(H, JUMPBLOCK, null, MUTCHK_FORCED)

	H.dna.SetSEState(IMMOLATEBLOCK, TRUE)
	genemutcheck(H, IMMOLATEBLOCK, null, MUTCHK_FORCED)

	H.mutations.Add(LASER)
	H.update_mutations()
	H.update_body()