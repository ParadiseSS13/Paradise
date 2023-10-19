/datum/martial_combo/bearserk/bear_jaws
	name = "Bear Jaws"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Grab and bite your opponent like a true barbarian. Likely to cause bleeding."

/datum/martial_combo/bearserk/bear_jaws/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || IS_HORIZONTAL(target))
		user.do_attack_animation(target, ATTACK_EFFECT_BITE)
		target.visible_message("<span class='warning'>[user] leaps onto [target] and bites them, how barbaric!</span>", \
						"<span class='userdanger'>[user] leaps onto you and bites you!</span>")
		playsound(get_turf(target), 'sound/weapons/bite.ogg', 25, TRUE, -1)
		target.apply_damage(20, BRUTE, user.zone_selected, sharp = TRUE)
		if(target.stat != DEAD)
			user.adjustStaminaLoss(-45)
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Bear Jaws", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	user.do_attack_animation(target, ATTACK_EFFECT_BITE)
	var/atk_verb = pick("bites", "gnaws", "tears at")
	target.visible_message("<span class='danger'>[user] [atk_verb] [target]!</span>",
					"<span class='userdanger'>[user] [atk_verb] you!</span>")
	playsound(get_turf(target), 'sound/weapons/bite.ogg', 25, TRUE, -1)
	target.apply_damage (15, BRUTE, user.zone_selected, sharp = TRUE)
	if(target.stat != DEAD)
		user.adjustStaminaLoss(-15)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Bear Jaws", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
