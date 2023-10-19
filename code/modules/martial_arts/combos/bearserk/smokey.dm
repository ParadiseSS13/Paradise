/datum/martial_combo/bearserk/smokey
	name = "Smokey"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Ancient, ursine memories sets your opponent aflame!"

/datum/martial_combo/bearserk/smokey/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message("<span class='warning'>[user] sets [target] on fire with nostalgic powers!</span>", \
						"<span class='userdanger'>As [user] punches you with a searing fist, words echo in your mind; remember... only YOU can prevent forest fires!</span>")
	target.apply_damage(5, BURN, user.zone_selected)
	playsound(get_turf(user), 'sound/weapons/punch1.ogg', 20, 1, -1)
	if(!isliving(target))
		return
	target.adjust_fire_stacks(1.5)
	target.IgniteMob()
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Smokey", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
