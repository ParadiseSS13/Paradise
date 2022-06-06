/datum/martial_combo/sleeping_carp/back_kick
	name = "Удар в спину"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Используется только сзади. Сбивает оппонента с ног."

/datum/martial_combo/sleeping_carp/back_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(user.dir == target.dir && !target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		var/hit_name = pick("пина[pluralize_ru(user.gender,"ет","ют")]", "ударя[pluralize_ru(user.gender,"ет","ют")]", "толка[pluralize_ru(user.gender,"ет","ют")]")
		target.visible_message("<span class='warning'>[user] [hit_name] [target] в спину!</span>", \
						  "<span class='userdanger'>[user] [hit_name] вас в спину, заставив вас споткнуться и упасть!</span>")
		step_to(target,get_step(target,target.dir),1)
		target.Weaken(3)
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Back Kick", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("СУРПРАЙЗО!","УДАР В СПИНУ!","УДАР В ПСИНУ!","ВУОПХАА!", "ВУАТАА", "ЗУОТАА!", "ОБЕРНИСЬ!", "СЗАДИ!", "СЛЕДИ ЗА ТЫЛОМ!", "ПОДЗАТЫЛЬНИК!", "ПЕНДЕЛЬ!", "Никогда не показывай спину!", "Не поворачивайся спиной к врагу!", "Тебе передали привет!", "Я передаю привет!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
