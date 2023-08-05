/datum/martial_combo/judo/eyepoke
	name = "Eye Poke"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Jab your opponent in the eye, damaging and blinding them breifly. Opponents with eye protection are still affected."
	combo_text_override = "Disarm, Harm"

/datum/martial_combo/judo/eyepoke/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] jabs [target] in [user.p_their()] eyes!</span>", \
						"<span class='userdanger'>[user] jabs you in the eyes!</span>")
	playsound(get_turf(user), 'sound/weapons/whip.ogg', 40, TRUE, -1)
	target.apply_damage(10, BRUTE)
	target.AdjustEyeBlurry(50, 0, 30 SECONDS)
	target.EyeBlind(2 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Eye Poke", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
