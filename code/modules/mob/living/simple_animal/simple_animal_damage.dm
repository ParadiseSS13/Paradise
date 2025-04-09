
/mob/living/simple_animal/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(!ckey && stat == CONSCIOUS)//Not unconscious
		if(AIStatus == AI_IDLE)
			toggle_ai(AI_ON)

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
