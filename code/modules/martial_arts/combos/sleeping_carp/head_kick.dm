/datum/martial_combo/sleeping_carp/head_kick
	name = "Пинок в голову!"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Приличный урон вынуждающий противника бросить предмет в руке."

/datum/martial_combo/sleeping_carp/head_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		var/hit_name = pick ("у челюсть", " затылок", " висок", "у голову", "у переносицу")
		target.visible_message("<span class='warning'>[user] с разворота пина[pluralize_ru(user.gender,"ет","ют")] [target] в голову!</span>", \
						  "<span class='userdanger'>[user] с разворота попал[genderize_ru(user.gender,"","а","о","и")] ногой в ваш[hit_name]!</span>")
		target.apply_damage(20, BRUTE, "head")
		target.drop_item()
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Head Kick", ATKLOG_ALL)
		if(prob(60))
			user.say(pick("УУХЙОО!", "УПХААА!", "ХЬЙОО!", "ВУАА!", "УДАР ШУРЬЮ!", "КИЙААА!", "ПРИГОТОВЬ ЗУБЫ!", "ГОЛОВНАЯ БОЛЬ!", "ПОРАСКИНЬ МОЗГАМИ!", "БЕЗБАШЕННОСТЬ!", "ОТВАЛ БАШКИ!", "ДА У ТЕБЯ ЛИШНИЕ ЗУБЫ!", "НЕ ЩУРЬСЯ!", "САЕЧКУ ЗА ИСПУГ!"))
		target.Weaken(3)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
