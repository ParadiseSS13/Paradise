// SLEEPING CARP COMBOS

/datum/martial_combo/sleeping_carp/crashing_kick
	name = "Crashing Waves Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Kicks the target square in the chest, sending them flying."

/datum/martial_combo/sleeping_carp/crashing_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target != user) // no you cannot kick yourself across rooms
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] kicks [target] square in the chest, sending them flying!</span>",
					"<span class='userdanger'>You are kicked square in the chest by [user], sending you flying!</span>")
		playsound(target, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 7, 14, user)
		target.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Crashing Waves Kick", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT


/datum/martial_combo/sleeping_carp/gnashing_teeth
	name = "Gnashing Teeth"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Every second consecutive punch deals extra damage, and you will shout to strike fear into your opponent's heart."

/datum/martial_combo/sleeping_carp/gnashing_teeth/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("precisely kicks", "brutally chops", "cleanly hits", "viciously slams")
	target.visible_message("<span class='danger'>[user] [atk_verb] [target]!</span>",
					"<span class='userdanger'>[user] [atk_verb] you!</span>")
	playsound(get_turf(target), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Gnashing Teeth", ATKLOG_ALL)
	target.apply_damage(20, BRUTE, user.zone_selected, sharp = TRUE)
	if(target.health >= 0)
		user.say(pick("HUAH!", "HYA!", "CHOO!", "WUO!", "KYA!", "HUH!", "HIYOH!", "CARP STRIKE!", "CARP BITE!"))
	else
		user.say(pick("BANZAIII!", "KIYAAAA!", "OMAE WA MOU SHINDEIRU!", "YOU CAN'T SEE ME!", "MY TIME IS NOW!", "COWABUNGA!")) // COWABUNGA
	return MARTIAL_COMBO_DONE


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
		target.visible_message("<span class='warning'>[user] kicks [target] in the head, sending them face first into the floor!</span>",
						"<span class='userdanger'>You are kicked in the head by [user], sending you crashing to the floor!</span>")
	else
		target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		target.drop_l_hand()
		target.drop_r_hand()
		target.visible_message("<span class='warning'>[user] kicks [target] in the head, leaving them reeling in pain!</span>",
							"<span class='userdanger'>You are kicked in the head by [user], and you reel in pain!</span>")
	target.apply_damage(40, STAMINA)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Keelhaul", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
