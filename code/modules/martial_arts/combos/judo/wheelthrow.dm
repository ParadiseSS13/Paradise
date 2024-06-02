/datum/martial_combo/judo/wheelthrow
	name = "Wheel Throw"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "From an armbar, flip your opponent over your shoulder, slamming them onto the floor, leaving them stunned."
	combo_text_override = "Grab, Disarm, Harm"

/datum/martial_combo/judo/wheelthrow/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!IS_HORIZONTAL(target) || !target.IsImmobilized())
		return MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] raises [target] over [user.p_their()] shoulder, and slams [target.p_them()] into the ground!</span>", \
						"<span class='userdanger'>[user] throws you over [user.p_their()] shoulder, slamming you into the ground!</span>")
	playsound(get_turf(user), 'sound/magic/tail_swing.ogg', 40, TRUE, -1)
	target.SpinAnimation(10, 1)
	target.apply_damage(120, STAMINA)
	target.KnockDown(15 SECONDS)
	target.SetConfused(10 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Wheel Throw", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
