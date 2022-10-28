/datum/martial_combo/sleeping_carp/gnashing_teeth
	name = "Gnashing Teeth"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Every second consecutive punch deals extra damage, and you will shout to strike fear into your opponent's heart."

/datum/martial_combo/sleeping_carp/gnashing_teeth/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("precisely kicks", "brutally chops", "cleanly hits", "viciously slams")
	target.visible_message("<span class='danger'>[user] [atk_verb] [target]!</span>",
					"<span class='userdanger'>[user] [atk_verb] you!</span>")
	playsound(get_turf(target), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Gnashing Teeth", ATKLOG_ALL)
	target.apply_damage(20, BRUTE, user.zone_selected)
	if(target.health >= 0)
		user.say(pick("HUAH!", "HYA!", "CHOO!", "WUO!", "KYA!", "HUH!", "HIYOH!", "CARP STRIKE!", "CARP BITE!"))
	else
		user.say(pick("BANZAIII!", "KIYAAAA!", "OMAE WA MOU SHINDEIRU!", "YOU CAN'T SEE ME!", "MY TIME IS NOW!", "COWABUNGA!")) // COWABUNGA
	return MARTIAL_COMBO_DONE
