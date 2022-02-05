/datum/martial_combo/sleeping_carp/wrist_wrench
	name = "Wrist Wrench"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Forces opponent to drop item in hand."

/datum/martial_combo/sleeping_carp/wrist_wrench/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.stunned && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] grabs [target]'s wrist and wrenches it sideways!</span>", \
						  "<span class='userdanger'>[user] grabs your wrist and violently wrenches it to the side!</span>")
		playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Wrist Wrench", ATKLOG_ALL)
		if(prob(60))
			user.say(pick("WRISTY TWIRLY!", "WE FIGHT LIKE MEN!", "YOU DISHONOR YOURSELF!", "POHYAH!", "WHERE IS YOUR BATON NOW?", "SAY UNCLE!"))
		target.emote("scream")
		target.drop_item()
		target.apply_damage(5, BRUTE, pick("l_arm", "r_arm"))
		target.Weaken(1)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
