/mob/living/carbon/human/SetStunned(amount, updating = 1, force = 0)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/SetWeakened(amount, updating = 1, force = 0)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/SetParalysis(amount, updating = 1, force = 0)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/SetSleeping(amount, updating = 1, no_alert = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()
