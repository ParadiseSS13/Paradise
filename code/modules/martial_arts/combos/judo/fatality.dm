/datum/martial_combo/judo/fatailty
	name = "Meele Finisher"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "From an armbar, flip your opponent over your shoulder, slamming them onto the floor"
	combo_text_override = "Grab, swap hands, Disarm, Harm"

/datum/martial_combo/judo/fatailty/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || !IS_HORIZONTAL(target) || !(target.IsImmobilized()))
		return MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] raises [target] over their shoulder, and slams them into the ground!</span>", \
						"<span class='userdanger'>[user] !</span>")
	playsound(get_turf(user), 'sound/magic/tail_swing.ogg', 40, 1, -1)
	target.SpinAnimation(10.1)
	target.apply_damage(200, STAMINA)
	target.SetWeakened(1 SECONDS)
	target.KnockDown(15 SECONDS)
	target.SetConfused(10 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  meeleFatality", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
