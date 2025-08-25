/datum/martial_combo/bearserk/paw_slam
	name = "Paw Slam"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Slap an opponent with a mighty paw, knocking them down. Beats down harder on already knocked down opponents."

/datum/martial_combo/bearserk/paw_slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(IS_HORIZONTAL(target))
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message(span_warning("[user] pounds down on [target] with both fists!"), \
						span_userdanger("[user] pounds down on you with both fists!"))
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 25, vary = TRUE, extrarange = -1)
		target.apply_damage(20, BRUTE, user.zone_selected)
		target.Slowed(2 SECONDS)
		if(isliving(target) && target.stat != DEAD)
			user.adjustStaminaLoss(-40)
			user.apply_status_effect(STATUS_EFFECT_BEARSERKER_RAGE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Paw Slam", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	target.visible_message(span_warning("[user] strikes [target] to the ground with a mighty slap!"), \
						span_userdanger("[user] slaps you so hard, you fall over!"))
	playsound(get_turf(user), 'sound/weapons/slap.ogg', 25, vary = TRUE, extrarange = -1)
	target.apply_damage(10, BRUTE, user.zone_selected)
	target.KnockDown(4 SECONDS)
	target.Slowed(6 SECONDS)
	if(isliving(target) && target.stat != DEAD)
		user.adjustStaminaLoss(-40)
		user.apply_status_effect(STATUS_EFFECT_BEARSERKER_RAGE)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Paw Slam", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
