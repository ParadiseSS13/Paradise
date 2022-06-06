/datum/martial_combo/sleeping_carp/elbow_drop
	name = "Локтевой выпад"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Оппонент должен быть на земле. Наносит гигантский урон и мгновенно убивает при критических повреждениях."

/datum/martial_combo/sleeping_carp/elbow_drop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || target.resting || target.stat)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] в прыжке сверху наносит решающий удар локтем по [target]!</span>", \
						  "<span class='userdanger'>[user] в прыжке добива[pluralize_ru(user.gender,"ет","ют")] вас коронным локтевым выпадом!</span>") 
		if(target.health <= HEALTH_THRESHOLD_CRIT)
			target.death() //FINISH HIM!
		target.apply_damage(50, BRUTE, "chest")
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 75, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Elbow Drop", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("БАНЗАИИИИ!", "КИЙААААА!", "ОМАЕВА МО ШИНДЕРУ!", "ЗАДЕРЖИ ДЫХАНИЕ!", "ТЫ МЕНЯ БОЛЬШЕ НЕ УВИДИШЬ!", "ПРИШЛО МОЁ ВРЕМЯ!", "КАВАБАНГА!", "ИСПУСКАЙ ДУХ!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
