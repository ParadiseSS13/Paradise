/datum/martial_combo/superhuman/piston_kick
	name = "Piston Kick"
	explaination_text = "We use explosive chemical reactions to kick someone with such a force that it sends them flying."
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)

/datum/martial_combo/superhuman/piston_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(user != target)
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		user.apply_damage(5, BURN, pick(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)) //your leg is literally exploding like a piston
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 10, 14, user)
		target.visible_message("<span class='warning'>[user]'s lower leg is explosively propelled into [target], sending [target.p_them()] flying!</span>",
						"<span class='userdanger'>[user]'s lower leg is explosively propelled into you, disorienting you and sending you flying!</span>")
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Piston Kick", ATKLOG_ALL)
		target.Confused(5)
		target.apply_damage(10, BRUTE)
		playsound(get_turf(target), 'sound/weapons/punchmiss.ogg', 80, TRUE, -1)
		return MARTIAL_COMBO_DONE
