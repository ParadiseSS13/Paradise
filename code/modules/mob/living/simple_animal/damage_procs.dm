
/mob/living/simple_animal/proc/adjustHealth(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE
	var/oldbruteloss = bruteloss
	bruteloss = Clamp(bruteloss + amount, 0, maxHealth)
	if(oldbruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth()

/mob/living/simple_animal/adjustBruteLoss(amount, updating_health = TRUE)
	if(damage_coeff[BRUTE])
		return adjustHealth(amount * damage_coeff[BRUTE], updating_health)

/mob/living/simple_animal/adjustFireLoss(amount, updating_health = TRUE)
	if(damage_coeff[BURN])
		return adjustHealth(amount * damage_coeff[BURN], updating_health)

/mob/living/simple_animal/adjustOxyLoss(amount, updating_health = TRUE)
	if(damage_coeff[OXY])
		return adjustHealth(amount * damage_coeff[OXY], updating_health)

/mob/living/simple_animal/adjustToxLoss(amount, updating_health = TRUE)
	if(damage_coeff[TOX])
		return adjustHealth(amount * damage_coeff[TOX], updating_health)

/mob/living/simple_animal/adjustCloneLoss(amount, updating_health = TRUE)
	if(damage_coeff[CLONE])
		return adjustHealth(amount * damage_coeff[CLONE], updating_health)

/mob/living/simple_animal/adjustStaminaLoss(amount, updating_health = TRUE)
	if(damage_coeff[STAMINA])
		return ..(amount*damage_coeff[STAMINA], updating_health)