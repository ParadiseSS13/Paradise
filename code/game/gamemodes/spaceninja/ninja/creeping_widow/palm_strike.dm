/datum/martial_combo/ninja_martial_art/palm_strike
	name = "Palm Strike"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Sends enemies flying backwards if you are focused."

/datum/martial_combo/ninja_martial_art/palm_strike/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/ninja_martial_art/creeping_widow)
	if(!target.stat && !target.weakened && !target.resting)
		if(creeping_widow.has_focus)
			user.say("クモのキック!")
			creeping_widow.has_focus = 0
			user.face_atom(target)
			user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
			playsound(get_turf(user), 'sound/weapons/contractorbatonhit.ogg', 50, TRUE, -1)
			var/strike_adjective = pick(creeping_widow.attack_names)
			target.visible_message("<span class='danger'>[user] sends [target] flying backwards with a [strike_adjective] palm strike!</span>", \
				"<span class='userdanger'>[user] delivers a [strike_adjective] palm strike to you and sends you flying!</span>")

			var/atom/throw_target = get_ranged_target_turf(target, get_dir(target, get_step_away(target, user)), 3) // Get a turf 3 tiles away from the target relative to our direction from him.
			target.throw_at(throw_target, 200, 4) // Throw the poor bastard at the target we just gabbed.
			target.Weaken(2)
			add_attack_logs(user, target, "Melee attacked with martial-art [creeping_widow.name] : [name]")
			playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, TRUE, -1)
			addtimer(CALLBACK(creeping_widow, /datum/martial_art/ninja_martial_art/.proc/regain_focus, user), 50)
			return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL

