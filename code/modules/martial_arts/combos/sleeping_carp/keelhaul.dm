/datum/martial_combo/sleeping_carp/keelhaul
	name = "Keelhaul"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Kicks an opponent to the floor, knocking them down and dealing stamina damage to them!"

/datum/martial_combo/sleeping_carp/keelhaul/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	playsound(get_turf(target), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if(!IS_HORIZONTAL(target))
		target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		target.KnockDown(6 SECONDS)
		target.visible_message(SPAN_WARNING("[user] kicks [target] in the head, sending them face first into the floor!"),
						SPAN_USERDANGER("You are kicked in the head by [user], sending you crashing to the floor!"))
	else
		target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		target.drop_l_hand()
		target.drop_r_hand()
		target.visible_message(SPAN_WARNING("[user] kicks [target] in the head, leaving them reeling in pain!"),
							SPAN_USERDANGER("You are kicked in the head by [user], and you reel in pain!"))
	target.apply_damage(60, STAMINA)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Keelhaul", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
