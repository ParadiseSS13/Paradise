/datum/martial_combo/superhuman/foot_skewer
	name = "Foot Skewer"
	explaination_text = "We reform our leg into a serrated blade and jab it deep into our opponent's foot, piercing tendons and ligaments, crippling their mobility."
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)

/datum/martial_combo/superhuman/foot_skewer/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
		playsound(get_turf(target), 'sound/weapons/slash.ogg', 50, TRUE, -1)
		target.visible_message("<span class='warning'>[user] reforms their foot into a blade and jabs it deep into [target]'s foot!</span>",
						  "<span class='userdanger'>[user] reforms [user.p_their()] foot into a blade and sinks it deep into your foot, crippling your ability to walk!</span>")
		target.apply_damage(15, BRUTE, pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
		target.Slowed(5)
		target.emote("scream")
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Foot Skewer", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
