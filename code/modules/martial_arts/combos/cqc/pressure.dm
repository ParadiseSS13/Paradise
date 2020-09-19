/datum/martial_combo/cqc/pressure
	name = "Pressure"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Decent stamina damage."

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] forces their arm on [target]'s neck!</span>")
	target.adjustStaminaLoss(60)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
