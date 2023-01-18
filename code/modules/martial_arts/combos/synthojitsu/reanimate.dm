/datum/martial_combo/synthojitsu/reanimate
	name = "Reanimate"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HELP)
	explaination_text = "Restarts heart with shock. Use with caution."

/datum/martial_combo/synthojitsu/reanimate/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/MA)
	if(target.stat == DEAD)
		to_chat(user, "<span class='danger'>[target] doesn't respond at all!</span>")
		return MARTIAL_COMBO_FAIL
	if(target.undergoing_cardiac_arrest())
		to_chat(user, "<span class='notice'>[target] inhales deeply!</span>")
		target.adjustOxyLoss(-100)
		target.set_heartattack(FALSE)
		user.adjust_nutrition(-75)
		target.shock_internal_organs(100)
		target.visible_message("<span class='warning'>[user] shocked [target]!</span>", \
				"<span class='userdanger'>[user] shoked you!</span>")
		playsound(get_turf(user), 'sound/weapons/egloves.ogg', 50, 1, -1)
		target.apply_damage(10, BURN)
		objective_damage(user, target, 10, BURN)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : defib", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	else
		to_chat(user, "<span class='notice'>[target] does not require shock.Aborting...</span>")
		return MARTIAL_COMBO_FAIL
