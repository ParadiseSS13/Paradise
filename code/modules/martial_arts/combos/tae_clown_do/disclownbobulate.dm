/datum/martial_combo/tae_clown_do/disclownbobulate
	name = "Disclownbobulate"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Channel a resounding amount of Clown energy into your hands, unleashing it into a devastating clap, resulting in a concussive blast similar to an airhorn."

/datum/martial_combo/tae_clown_do/disclownbobulate/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] annoying claps [user.p_their()] hands directly in [target]'s ear!</span>",
							"<span class='userdanger'>[user] annoying claps [user.p_their()] hands in your ear!</span>")
		playsound(target.loc, 'sound/items/airhorn.ogg', 50, TRUE, -1)
		target.AdjustEarDamage(30)
		target.Stuttering(10)
		target.AdjustConfused(8)
		target.Jitter(10)
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Disclownbobulate", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
