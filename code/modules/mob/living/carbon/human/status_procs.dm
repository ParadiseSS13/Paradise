/mob/living/carbon/human/SetStunned(amount, updating = 1, force = 0)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()

/mob/living/carbon/human/SetWeakened(amount, updating = 1, force = 0)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()

/mob/living/carbon/human/SetParalysis(amount, updating = 1, force = 0)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()

/mob/living/carbon/human/SetSleeping(amount, updating = 1, no_alert = FALSE)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()