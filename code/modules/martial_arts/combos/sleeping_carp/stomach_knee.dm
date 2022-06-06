/datum/martial_combo/sleeping_carp/stomach_knee
	name = "Коленом в живот"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Роняет оппонента на землю и оглушает его."
	combo_text_override = "Захват, смена рук, захват"

/datum/martial_combo/sleeping_carp/stomach_knee/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] ударя[pluralize_ru(user.gender,"ет","ют")] коленом в живот [target]!</span>", \
						  "<span class='userdanger'>[user] ударя[pluralize_ru(user.gender,"ет","ют")] вас коленом в живот!</span>")
		target.audible_message("<b>[target]</b> gags!")
		target.AdjustLoseBreath(10)
		target.Weaken(3)
		target.adjustStaminaLoss(15)
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Stomach Knee", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("ХОП!", "КХУ!", "ЙАКХУ!", "КЬЯ!", "КОЛЕННЫЙ УДАР!", "ЗАДЕРЖИ ДЫХАНИЕ!", "НЕ ЗЕВАЙ!", "ВЫДЫХАЙ!", "ВЫПЛЮНЬ ЛЁГКИЕ!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
