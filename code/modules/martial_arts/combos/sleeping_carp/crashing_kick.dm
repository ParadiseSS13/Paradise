/datum/martial_combo/sleeping_carp/crashing_kick
	name = "Crashing Waves Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Kicks the target square in the chest. Knocks down."

/datum/martial_combo/sleeping_carp/crashing_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] kicks [target] in the chest!</span>",
						  "<span class='userdanger'>[user] kicks you in the chest, making you stumble and fall!</span>")
		step_to(target, get_step (target, target.dir), 1)
		target.Weaken(4)
		playsound(target, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Crashing Kick", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("SURRPRIZU!", "WOPAH!", "WATAAH", "ZOTA!", "SOLE STRIKE!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
