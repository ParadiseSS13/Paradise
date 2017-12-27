/mob/living/carbon/human/SetStunned(amount, updating = 1, force = 0)
	if(species)
		amount = amount * species.stun_mod
	..()

/mob/living/carbon/human/SetWeakened(amount, updating = 1, force = 0)
	if(species)
		amount = amount * species.stun_mod
	..()

/mob/living/carbon/human/SetParalysis(amount, updating = 1, force = 0)
	if(species)
		amount = amount * species.stun_mod
	..()

/mob/living/carbon/human/SetSleeping(amount, updating = 1, no_alert = FALSE)
	if(species)
		amount = amount * species.stun_mod
	..()