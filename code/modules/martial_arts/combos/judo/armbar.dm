/datum/martial_combo/judo/armbar
	name = "Armbar"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "place an opponent who has been knocked down into an armbar, disarming them"
	combo_text_override = "Disarm, disarm, grab"

/datum/martial_combo/judo/armbar/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] puts [target] into an armbar!</span>", \
						"<span class='userdanger'>[user] wrestles you into an armbar!</span>")
	playsound(get_turf(user), 'sound/weapons/slashmiss.ogg', 40, TRUE, -1)
	if(!IS_HORIZONTAL(user))
		target.drop_l_hand()
		target.drop_r_hand()
	target.apply_damage(45, STAMINA)
	target.apply_status_effect(STATUS_EFFECT_ARMBAR)
	target.KnockDown(5 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Armbar", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
