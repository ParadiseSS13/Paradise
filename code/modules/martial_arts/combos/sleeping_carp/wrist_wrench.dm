/datum/martial_combo/sleeping_carp/wrist_wrench
	name = "Вывих запястья"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Выбивает предмет из руки."

/datum/martial_combo/sleeping_carp/wrist_wrench/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.stunned && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] схватил[genderize_ru(user.gender,"","а","о","и")] запястье [target] и выворачива[pluralize_ru(user.gender,"ет","ют")] его назад!</span>", \
						  "<span class='userdanger'>[user] схватил[genderize_ru(user.gender,"","а","о","и")] вас за запястье и яростно вывернул[genderize_ru(user.gender,"","а","о","и")] его назад!</span>")
		playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Wrist Wrench", ATKLOG_ALL)
		if(prob(60))
			user.say(pick("КРАПИВА!", "ДЕРИСЬ КАК МУЖЧИНА!", "ТЫ ОБЕСЧЕСТИЛ СЕБЯ", "НУ ДАВАЙ!", "НУ И ГДЕ ТЕПЕРЬ ТВОЙ СТАНБАТОН?", "ПРОСИ ПОЩАДЫ!"))
		target.emote("scream")
		target.drop_item()
		target.apply_damage(5, BRUTE, pick("l_arm", "r_arm"))
		target.Weaken(2)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
