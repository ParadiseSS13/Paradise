/datum/martial_combo/krav_maga/neck_chop
	name = "Удар в горло"
	explaination_text = "Повреждает шею, временно лишая жертву возможности говорить."

/datum/martial_combo/krav_maga/neck_chop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] бь[pluralize_ru(user.gender,"ёт","ют")] ударом каратэ в горло [target]!</span>", \
		"<span class='userdanger'>[user] бь[pluralize_ru(user.gender,"ёт","ют")] ударом каратэ в горло, временно лишая вас возможности говорить!</span>")
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	target.apply_damage(5, BRUTE)
	target.AdjustSilence(10)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Neck Chop", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
