/datum/martial_combo/ninja_martial_art/wrench_wrist
	name = "Wrench Wrist"
	steps = list(MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Wrenches enemy wrist, causing them to drop what they are holding if you are focused."

/datum/martial_combo/ninja_martial_art/wrench_wrist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/ninja_martial_art/creeping_widow)
	if(!target.stat && !target.weakened)
		if(creeping_widow.has_focus)
			user.say("この野郎!")
			creeping_widow.has_focus = 0
			user.face_atom(target)
			user.do_attack_animation(target, ATTACK_EFFECT_KICK)
			playsound(get_turf(user), 'sound/effects/bone_break_2.ogg', 50, TRUE, -1)
			target.visible_message("<span class='warning'>[user] grabs [target]'s wrist and wrenches it sideways!</span>", \
							  "<span class='userdanger'>[user] grabs your wrist and violently wrenches it to the side!</span>")
			playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			target.emote("scream")
			target.drop_item()
			target.apply_damage(5, BRUTE, pick("l_arm", "r_arm"))
			target.Stun(1)
			add_attack_logs(user, target, "Melee attacked with martial-art [creeping_widow.name] : [name]")
			addtimer(CALLBACK(creeping_widow, /datum/martial_art/ninja_martial_art/.proc/regain_focus, user), 50)
			return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL

