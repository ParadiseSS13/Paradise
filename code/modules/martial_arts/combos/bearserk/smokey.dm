/datum/martial_combo/bearserk/smokey
	name = "Smokey"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Mentally channel the occultic fury of Smoh'Kie to set your opponent aflame!"

/datum/martial_combo/bearserk/smokey/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!isliving(target))
		return
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message("<span class='warning'>[user] sets [target] on fire with otherwordly powers!</span>", \
						"<span class='userdanger'>As [user] punches you with a searing fist, these words echo in your mind; \"remember... only YOU can prevent forest fires!\"</span>")
	target.apply_damage(10, BURN, user.zone_selected)
	playsound(get_turf(user), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	target.adjust_fire_stacks(1.5)
	target.IgniteMob()
	if(isliving(target) && target.stat != DEAD)
		user.adjustStaminaLoss(-40)
		user.apply_status_effect(STATUS_EFFECT_BEARSERKER_RAGE)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Smokey", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
