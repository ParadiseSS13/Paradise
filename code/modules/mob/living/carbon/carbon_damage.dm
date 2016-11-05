/mob/living/carbon/getStaminaLoss()
	return staminaloss

/mob/living/carbon/adjustStaminaLoss(var/amount)
	. = ..()
	update_stamina()

/mob/living/carbon/setStaminaLoss(var/amount)
	update_stamina()
