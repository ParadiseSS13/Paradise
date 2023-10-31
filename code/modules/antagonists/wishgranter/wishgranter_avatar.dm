/datum/antagonist/wishgranter
	name = "Wishgranter Avatar"
	special_role = "Avatar of the Wish Granter"

/datum/antagonist/wishgranter/give_objectives()
	add_antag_objective(/datum/objective/hijack)

/datum/antagonist/wishgranter/greet()
	. = ..()
	. += "<span class='notice'>Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!</span>"

/datum/antagonist/wishgranter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/H = ..()
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
