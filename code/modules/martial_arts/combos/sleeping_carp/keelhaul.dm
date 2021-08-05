/datum/martial_combo/sleeping_carp/keelhaul
	name = "Keelhaul"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Kicks an opponent to the floor, knocking them down and dealing stamina damage to them!"

/datum/martial_combo/sleeping_carp/keelhaul/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	playsound(get_turf(target), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if(!target.IsWeakened() && !target.resting && !target.stat)
		target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		target.Weaken(2)
		target.visible_message("<span class='warning'>[user] kicks [target] in the head, sending them face first into the floor!</span>",
						"<span class='userdanger'>You are kicked in the head by [user], sending you crashing to the floor!</span>")
	else
		target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		target.visible_message("<span class='warning'>[user] kicks [target] in the head, leaving them reeling in pain!</span>",
							"<span class='userdanger'>You are kicked in the head by [user], and you reel in pain!</span>")
	target.apply_damage(40, STAMINA)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Keelhaul", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
