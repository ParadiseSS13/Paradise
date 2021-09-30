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
	singlemutcheck(H, GLOB.hulkblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.fireblock, TRUE)
	singlemutcheck(H, GLOB.fireblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.coldblock, TRUE)
	singlemutcheck(H, GLOB.coldblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.teleblock, TRUE)
	singlemutcheck(H, GLOB.teleblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.increaserunblock, TRUE)
	singlemutcheck(H, GLOB.increaserunblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.breathlessblock, TRUE)
	singlemutcheck(H, GLOB.breathlessblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.regenerateblock, TRUE)
	singlemutcheck(H, GLOB.regenerateblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.shockimmunityblock, TRUE)
	singlemutcheck(H, GLOB.shockimmunityblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.smallsizeblock, TRUE)
	singlemutcheck(H, GLOB.smallsizeblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.soberblock, TRUE)
	singlemutcheck(H, GLOB.soberblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.psyresistblock, TRUE)
	singlemutcheck(H, GLOB.psyresistblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.shadowblock, TRUE)
	singlemutcheck(H, GLOB.shadowblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.cryoblock, TRUE)
	singlemutcheck(H, GLOB.cryoblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.eatblock, TRUE)
	singlemutcheck(H, GLOB.eatblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.jumpblock, TRUE)
	singlemutcheck(H, GLOB.jumpblock, MUTCHK_FORCED)

	H.dna.SetSEState(GLOB.immolateblock, TRUE)
	singlemutcheck(H, GLOB.immolateblock, MUTCHK_FORCED)

	ADD_TRAIT(H, TRAIT_LASEREYES, "wishgranter")
	H.update_mutations()
	H.update_body()
