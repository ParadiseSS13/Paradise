/datum/martial_art/torque
	name = "Torque enhancer"
	weight = 500 // You shouldn't be able to override this, it's a passive you actively buy
	/// What level is the passive at
	var/level = 1

/datum/martial_art/torque/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/attack_sound
	var/list/attack_verb = list()
	switch(level)
		if(FLAYER_POWER_LEVEL_ONE)
			attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
			attack_verb = list("bashes", "batters")
		if(FLAYER_POWER_LEVEL_TWO)
			attack_sound = 'sound/effects/meteorimpact.ogg'
			attack_verb = list("blugeons", "beats")
		if(FLAYER_POWER_LEVEL_THREE)
			attack_sound = 'sound/misc/demon_attack1.ogg'
			attack_verb = list("destroys", "demolishes", "hammers")

	var/datum/species/attacking = A.dna?.species
	var/damage = 5 // In case the attacker doesn't have a species somehow
	if(attacking)
		damage = rand(attacking.punchdamagelow, attacking.punchdamagehigh)
		damage += 5 * level

	var/picked_hit_type = pick(attack_verb)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	D.apply_damage(damage, BRUTE)

	if(level >= 2) // This is to mimic species unarmed attacks, if you deal more than 10 damage the attackee is knocked down
		D.KnockDown(4 SECONDS) // The threshold for a knockdown is 9 damage, so at level 2 your minimum is already higher than that

	if(attack_sound)
		playsound(get_turf(D), attack_sound, 50, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with [src]")
	return TRUE
