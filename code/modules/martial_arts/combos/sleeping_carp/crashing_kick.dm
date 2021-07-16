/datum/martial_combo/sleeping_carp/crashing_kick
	name = "Crashing Waves Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Kicks the target square in the chest, sending them flying."

/datum/martial_combo/sleeping_carp/crashing_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target != user) // no you cannot kick yourself across rooms
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] kicks [target] square in the chest, sending them flying!</span>",
					"<span class='userdanger'>You are kicked square in the chest by [user], sending you flying!</span>")
		playsound(target, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 7, 14, user)
		target.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Crashing Waves Kick", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
