/mob/living/carbon/human/SetStunned(amount, updating = 1, force = 0)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/SetWeakened(amount, updating = 1, force = 0)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/SetParalysis(amount, updating = TRUE, force = 0, ane = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/SetSleeping(amount, updating = TRUE, no_alert = FALSE, ane = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()
