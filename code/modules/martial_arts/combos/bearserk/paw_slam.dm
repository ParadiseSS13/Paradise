/datum/martial_combo/bearserk/paw_slam
	name = "Paw Slam"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Slap an opponent with a mighty paw, knocking them down."

/datum/martial_combo/bearserk/paw_slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || IS_HORIZONTAL(target))
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] crushes [target] with both fists!</span>", \
						"<span class='userdanger'>[user] crushes you with both fists!</span>")
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
		target.apply_damage(20, BRUTE, user.zone_selected)
		target.Stun(1 SECONDS)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Paw Slam", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	target.visible_message("<span class='warning'>[user] strikes [target] to the ground with a might slap!</span>", \
						"<span class='userdanger'>[user] slaps you so hard, you fall over!</span>")
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 40, 1, -1)
	target.apply_damage(10, BRUTE, user.zone_selected)
	target.KnockDown(5 SECONDS)
	target.Stun(1 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Paw Slam", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE