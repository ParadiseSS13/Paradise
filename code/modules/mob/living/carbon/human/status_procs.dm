/mob/living/carbon/human/SetLoseBreath(amount)
	if(NO_BREATHE in dna.species.species_traits)
		losebreath = 0
		return FALSE
	. = ..()

/mob/living/carbon/human/SetStun(amount, updating = 1, force = 0)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()

/mob/living/carbon/human/SetKnockdown(amount, updating = 1, force = 0)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()

/mob/living/carbon/human/SetUnconscious(amount, updating = 1, force = 0)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()

/mob/living/carbon/human/SetSleeping(amount, updating = 1, no_alert = FALSE)
	if(dna.species)
		amount = amount * dna.species.stun_mod
	..()