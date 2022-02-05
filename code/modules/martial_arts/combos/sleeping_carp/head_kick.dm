/datum/martial_combo/sleeping_carp/head_kick
	name = "Head Kick"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Decent damage, forces opponent to drop item in hand."

/datum/martial_combo/sleeping_carp/head_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] kicks [target] in the head!</span>", \
						  "<span class='userdanger'>[user] kicks you in the jaw!</span>")
		target.apply_damage(20, BRUTE, "head")
		target.drop_item()
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Head Kick", ATKLOG_ALL)
		if(prob(60))
			user.say(pick("OOHYOO!", "OOPYAH!", "HYOOAA!", "WOOAAA!", "SHURYUKICK!", "HIYAH!"))
		target.Weaken(2)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
