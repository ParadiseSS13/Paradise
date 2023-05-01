/datum/martial_art/grav_stomp
	name = "Gravitational Boots"

/datum/martial_art/grav_stomp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with [src]")
	var/picked_hit_type = "kicks"
	var/bonus_damage = 10
	if(D.IsWeakened() ||  D.resting || D.lying)
		bonus_damage = 15
		picked_hit_type = "stomps on"
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(bonus_damage, BRUTE)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	return TRUE
