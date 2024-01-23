/datum/martial_combo/bearserk/bear_jaws
	name = "Bear Jaws"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Bite your opponent like a true lunatic, with even more savagery against knocked down targets."

/datum/martial_combo/bearserk/bear_jaws/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_BITE)
	playsound(get_turf(target), 'sound/weapons/bite.ogg', 25, vary = TRUE, extrarange = -1)
	if(IS_HORIZONTAL(target))
		target.visible_message("<span class='warning'>[user] leaps onto [target] and bites them!</span>",
						"<span class='userdanger'>[user] leaps onto you and bites you like a real savage!</span>")
		target.apply_damage(20, BRUTE, user.zone_selected, sharp = TRUE)
		if(isliving(target) && target.stat != DEAD)
			user.adjustStaminaLoss(-60)
			user.apply_status_effect(STATUS_EFFECT_BEARSERKER_RAGE)
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Bear Jaws", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	var/atk_verb = pick("bites", "gnaws", "tears at")
	target.visible_message("<span class='danger'>[user] [atk_verb] [target]!</span>",
					"<span class='userdanger'>[user] [atk_verb] you!</span>")
	target.apply_damage(10, BRUTE, user.zone_selected, sharp = TRUE)
	if(isliving(target) && target.stat != DEAD)
		user.adjustStaminaLoss(-40)
		user.apply_status_effect(STATUS_EFFECT_BEARSERKER_RAGE)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Bear Jaws", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
