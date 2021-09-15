
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, used_weapon, spread_damage = FALSE)
	var/hit_percent = (100 - blocked) / 100
	if(!damage || (hit_percent <= 0))
		return FALSE
	var/damage_amount =  damage * hit_percent
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage_amount)
		if(BURN)
			adjustFireLoss(damage_amount)
		if(TOX)
			adjustToxLoss(damage_amount)
		if(OXY)
			adjustOxyLoss(damage_amount)
		if(CLONE)
			adjustCloneLoss(damage_amount)
		if(STAMINA)
			adjustStaminaLoss(damage_amount)
	updatehealth("apply damage")
	return TRUE

/mob/living/proc/apply_damage_type(damage = 0, damagetype = BRUTE) //like apply damage except it always uses the damage procs
	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(damage)
		if(BURN)
			return adjustFireLoss(damage)
		if(TOX)
			return adjustToxLoss(damage)
		if(OXY)
			return adjustOxyLoss(damage)
		if(CLONE)
			return adjustCloneLoss(damage)
		if(STAMINA)
			return adjustStaminaLoss(damage)
		if(BRAIN)
			return adjustBrainLoss(damage)

/mob/living/proc/get_damage_amount(damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return getBruteLoss()
		if(BURN)
			return getFireLoss()
		if(TOX)
			return getToxLoss()
		if(OXY)
			return getOxyLoss()
		if(CLONE)
			return getCloneLoss()
		if(STAMINA)
			return getStaminaLoss()


/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = 0, stamina = 0)
	if(blocked >= 100)	return 0
	if(brute)	apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)	apply_damage(burn, BURN, def_zone, blocked)
	if(tox)		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)	apply_damage(clone, CLONE, def_zone, blocked)
	if(stamina) apply_damage(stamina, STAMINA, def_zone, blocked)
	return 1



/mob/living/proc/apply_effect(effect = 0, effecttype = STUN, blocked = 0)
	blocked = (100 - blocked) / 100
	if(!effect || (blocked <= 0))
		return FALSE
	switch(effecttype)
		if(STUN)
			Stun(effect * blocked)
		if(WEAKEN)
			Weaken(effect * blocked)
		if(PARALYZE)
			Paralyse(effect * blocked)
		if(IRRADIATE)
			if(!HAS_TRAIT(src, TRAIT_RADIMMUNE))
				radiation += max(effect * blocked, 0)
		if(SLUR)
			Slur(effect * blocked)
		if(STUTTER)
			Stuttering(effect * blocked)
		if(EYE_BLUR)
			EyeBlurry(effect * blocked)
		if(DROWSY)
			Drowsy(effect * blocked)
		if(JITTER)
			if(status_flags & CANSTUN)
				Jitter(effect * blocked)
	updatehealth("apply effect")
	return TRUE

/mob/living/proc/apply_effects(stun = 0, weaken = 0, paralyze = 0, irradiate = 0, slur = 0, stutter = 0, eyeblur = 0, drowsy = 0, blocked = 0, stamina = 0, jitter = 0)
	if(blocked >= 100)
		return FALSE
	if(stun)
		apply_effect(stun, STUN, blocked)
	if(weaken)
		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)
		apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)
		apply_effect(irradiate, IRRADIATE, blocked)
	if(slur)
		apply_effect(slur, SLUR, blocked)
	if(stutter)
		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, DROWSY, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)
	if(jitter)
		apply_effect(jitter, JITTER, blocked)
	return TRUE


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_bruteloss = bruteloss
	bruteloss = max(bruteloss + amount, 0)
	if(old_bruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustBruteLoss")

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		oxyloss = 0
		return FALSE	//godmode
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		oxyloss = 0
		return FALSE
	var/old_oxyloss = oxyloss
	oxyloss = max(oxyloss + amount, 0)
	if(status_flags & MOAED && oxyloss > 0) return // GET MOAED
	if(old_oxyloss == oxyloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustOxyLoss")

/mob/living/proc/setOxyLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		oxyloss = 0
		return FALSE	//godmode
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		oxyloss = 0
		return FALSE
	var/old_oxyloss = oxyloss
	oxyloss = amount
	if(old_oxyloss == oxyloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setOxyLoss")

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_toxloss = toxloss
	toxloss = max(toxloss + amount, 0)
	if(old_toxloss == toxloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustToxLoss")

/mob/living/proc/setToxLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_toxloss = toxloss
	toxloss = amount
	if(old_toxloss == toxloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setToxLoss")

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_fireloss = fireloss
	fireloss = max(fireloss + amount, 0)
	if(old_fireloss == fireloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustFireLoss")

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_cloneloss = cloneloss
	cloneloss = max(cloneloss + amount, 0)
	if(old_cloneloss == cloneloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustCloneLoss")

/mob/living/proc/setCloneLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_cloneloss = cloneloss
	cloneloss = amount
	if(old_cloneloss == cloneloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setCloneLoss")

/mob/living/proc/getBrainLoss()
	return 0

/mob/living/proc/adjustBrainLoss(amount, updating = TRUE)
	return STATUS_UPDATE_NONE

/mob/living/proc/setBrainLoss(amount, updating = TRUE)
	return STATUS_UPDATE_NONE

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, updating = TRUE)
	if(status_flags & GODMODE)
		return FALSE
	var/old_stamloss = staminaloss
	staminaloss = min(max(staminaloss + amount, 0), 120)
	if(old_stamloss == staminaloss)
		updating = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(amount > 0)
		stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
	if(updating)
		update_health_hud()
		update_stamina()

/mob/living/proc/setStaminaLoss(amount, updating = TRUE)
	if(status_flags & GODMODE)
		return FALSE
	var/old_stamloss = staminaloss
	staminaloss = min(max(amount, 0), 120)
	if(old_stamloss == staminaloss)
		updating = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(amount > 0)
		stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
	if(updating)
		update_health_hud()
		update_stamina()

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth



// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(brute, burn, updating_health = TRUE)
	adjustBruteLoss(-brute, FALSE)
	adjustFireLoss(-burn, FALSE)
	if(updating_health)
		updatehealth("heal organ damage")

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(brute, burn, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	adjustBruteLoss(brute, FALSE)
	adjustFireLoss(burn, FALSE)
	if(updating_health)
		updatehealth("take organ damage")

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(brute, burn, updating_health = TRUE)
	adjustBruteLoss(-brute, FALSE)
	adjustFireLoss(-burn, FALSE)
	if(updating_health)
		updatehealth("heal overall damage")

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(brute, burn, updating_health = TRUE, used_weapon = null)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	adjustBruteLoss(brute, FALSE)
	adjustFireLoss(burn, FALSE)
	if(updating_health)
		updatehealth("take overall damage")

/mob/living/proc/has_organic_damage()
	return (maxHealth - health)

//heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = amount //we'll return the amount of damage healed
	for(var/i in damage_types)
		var/amount_to_heal = min(amount, get_damage_amount(i)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			apply_damage_type(-amount_to_heal, i)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
	. -= amount //if there's leftover healing, remove it from what we return
