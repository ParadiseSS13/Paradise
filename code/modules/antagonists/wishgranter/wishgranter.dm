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
	H.dna.SetSEState(GLOB.hulkblock, TRUE)
	genemutcheck(H, GLOB.hulkblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.xrayblock, TRUE)
	genemutcheck(H, GLOB.xrayblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.fireblock, TRUE)
	genemutcheck(H, GLOB.fireblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.coldblock, TRUE)
	genemutcheck(H, GLOB.coldblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.teleblock, TRUE)
	genemutcheck(H, GLOB.teleblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.increaserunblock, TRUE)
	genemutcheck(H, GLOB.increaserunblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.breathlessblock, TRUE)
	genemutcheck(H, GLOB.breathlessblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.regenerateblock, TRUE)
	genemutcheck(H, GLOB.regenerateblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.shockimmunityblock, TRUE)
	genemutcheck(H, GLOB.shockimmunityblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.smallsizeblock, TRUE)
	genemutcheck(H, GLOB.smallsizeblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.soberblock, TRUE)
	genemutcheck(H, GLOB.soberblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.psyresistblock, TRUE)
	genemutcheck(H, GLOB.psyresistblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.shadowblock, TRUE)
	genemutcheck(H, GLOB.shadowblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.cryoblock, TRUE)
	genemutcheck(H, GLOB.cryoblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.eatblock, TRUE)
	genemutcheck(H, GLOB.eatblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.jumpblock, TRUE)
	genemutcheck(H, GLOB.jumpblock, null, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.immolateblock, TRUE)
	genemutcheck(H, GLOB.immolateblock, null, MUTCHK_FORCED)

	H.mutations.Add(LASER)
	H.update_mutations()
	H.update_body()
