/datum/martial_combo/cqc/pressure
	name = "Прессинг"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Выдавливает из оппонента всю выносливость."

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] сжима[pluralize_ru(user.gender,"ет","ют")] горло [target]!</span>")
	target.adjustStaminaLoss(60)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
