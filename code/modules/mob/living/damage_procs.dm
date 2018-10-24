
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/used_weapon = null)
	blocked = (100-blocked)/100
	if(!damage || (blocked <= 0))	return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * blocked)
		if(BURN)
			adjustFireLoss(damage * blocked)
		if(TOX)
			adjustToxLoss(damage * blocked)
		if(OXY)
			adjustOxyLoss(damage * blocked)
		if(CLONE)
			adjustCloneLoss(damage * blocked)
		if(STAMINA)
			adjustStaminaLoss(damage * blocked)
	updatehealth("apply damage")
	return 1

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

/mob/living/proc/apply_damages(var/brute = 0, var/burn = 0, var/tox = 0, var/oxy = 0, var/clone = 0, var/def_zone = null, var/blocked = 0, var/stamina = 0)
	if(blocked >= 100)	return 0
	if(brute)	apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)	apply_damage(burn, BURN, def_zone, blocked)
	if(tox)		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)	apply_damage(clone, CLONE, def_zone, blocked)
	if(stamina) apply_damage(stamina, STAMINA, def_zone, blocked)
	return 1



/mob/living/proc/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0, var/negate_armor = 0)
	blocked = (100-blocked)/100
	if(!effect || (blocked <= 0))
		return 0
	switch(effecttype)
		if(STUN)
			Stun(effect * blocked)
		if(WEAKEN)
			Weaken(effect * blocked)
		if(PARALYZE)
			Paralyse(effect * blocked)
		if(IRRADIATE)
			var/rad_damage = effect
			if(!negate_armor) // Setting negate_armor overrides radiation armor checks, which are automatic otherwise
				rad_damage = max(effect * ((100-run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm."))/100),0)
			radiation += rad_damage
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
	return 1

/mob/living/proc/apply_effects(var/stun = 0, var/weaken = 0, var/paralyze = 0, var/irradiate = 0, var/slur = 0, var/stutter = 0, var/eyeblur = 0, var/drowsy = 0, var/blocked = 0, var/stamina = 0, var/jitter = 0)
	if(blocked >= 100)	return 0
	if(stun)		apply_effect(stun, STUN, blocked)
	if(weaken)		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)	apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)	apply_effect(irradiate, IRRADIATE, blocked)
	if(slur) 		apply_effect(slur, SLUR, blocked)
	if(stutter)		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)		apply_effect(drowsy, DROWSY, blocked)
	if(stamina)		apply_damage(stamina, STAMINA, null, blocked)
	if(jitter) 		apply_effect(jitter, JITTER, blocked)
	return 1


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_bruteloss = bruteloss
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))
	if(old_bruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustBruteLoss")

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_oxyloss = oxyloss
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))
	if(old_oxyloss == oxyloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustOxyLoss")

/mob/living/proc/setOxyLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
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

/mob/living/proc/adjustToxLoss(var/amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_toxloss = toxloss
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))
	if(old_toxloss == toxloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustToxLoss")

/mob/living/proc/setToxLoss(var/amount, updating_health = TRUE)
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

/mob/living/proc/adjustFireLoss(var/amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_fireloss = fireloss
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))
	if(old_fireloss == fireloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustFireLoss")

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	var/old_cloneloss = cloneloss
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))
	if(old_cloneloss == cloneloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustCloneLoss")

/mob/living/proc/setCloneLoss(var/amount, updating_health = TRUE)
	if(status_flags & GODMODE)	return 0	//godmode
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
	staminaloss = min(max(staminaloss + amount, 0),(maxHealth*2))
	if(old_stamloss == staminaloss)
		updating = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(updating)
		handle_hud_icons_health()
		update_stamina()

/mob/living/proc/setStaminaLoss(amount, updating = TRUE)
	if(status_flags & GODMODE)
		return FALSE
	var/old_stamloss = staminaloss
	staminaloss = amount
	if(old_stamloss == staminaloss)
		updating = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(updating)
		handle_hud_icons_health()
		update_stamina()

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
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
