/datum/martial_combo/superhuman/foot_skewer
	name = "Foot Skewer"
	explaination_text = "We reform our foot into a serrated blade and stab it deep into our opponent's foot, eviscerating tendons and ligaments and crippling their mobility."
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)

/datum/martial_combo/superhuman/foot_skewer/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
		playsound(get_turf(target), 'sound/weapons/slash.ogg', 50, TRUE, -1)
		target.visible_message("<span class='warning'>[user] reforms their foot into a blade and stabs it into [target]'s foot!</span>",
						  "<span class='userdanger'>[user] stabs you in the foot, crippling your ability to walk!</span>")
		target.apply_damage(15, BRUTE, pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
		target.Slowed(5)
		target.emote("scream")
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Foot Skewer", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
