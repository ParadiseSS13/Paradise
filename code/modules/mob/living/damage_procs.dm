
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/edge = 0, var/used_weapon = null)
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
	updatehealth()
	return 1


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
	updatehealth()
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
