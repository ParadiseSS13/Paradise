/datum/martial_combo/sleeping_carp/back_kick
	name = "Back Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Opponent must be facing away. Knocks down."

/datum/martial_combo/sleeping_carp/back_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(user.dir == target.dir && !target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] kicks [target] in the back!</span>", \
						  "<span class='userdanger'>[user] kicks you in the back, making you stumble and fall!</span>")
		step_to(target,get_step(target,target.dir),1)
		target.Weaken(2)
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Back Kick", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("SURRPRIZU!","BACK STRIKE!","WOPAH!", "WATAAH", "ZOTA!", "Never turn your back to the enemy!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
