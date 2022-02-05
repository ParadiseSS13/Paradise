/datum/martial_combo/sleeping_carp/elbow_drop
	name = "Elbow Drop"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Opponent must be on the ground. Deals huge damage, instantly kills anyone in critical condition."

/datum/martial_combo/sleeping_carp/elbow_drop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || target.resting || target.stat)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] elbow drops [target]!</span>", \
						  "<span class='userdanger'>[user] piledrives you with [user.p_their()] elbow!</span>")
		if(target.health <= HEALTH_THRESHOLD_CRIT)
			target.death() //FINISH HIM!
		target.apply_damage(50, BRUTE, "chest")
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 75, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Elbow Drop", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("BANZAIII!", "KIYAAAA!", "OMAE WA MOU SHINDEIRU!", "YOU CAN'T SEE ME!", "MY TIME IS NOW!", "COWABUNGA"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
