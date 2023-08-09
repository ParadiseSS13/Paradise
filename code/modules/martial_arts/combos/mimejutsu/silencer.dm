/datum/martial_combo/mimejutsu/silencer
	name = "Silencer"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Weakens the opponent and prevents him from speaking for a while."
	combo_text_override = "Grab, switch hands, Disarm"

/datum/martial_combo/mimejutsu/silencer/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/datum/martial_art/mimejutsu/mimejutsu = MA
	if(!istype(mimejutsu))
		return MARTIAL_COMBO_FAIL
	if(!target.stat)
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.AdjustSilence(10 SECONDS)
		target.Weaken(3 SECONDS)
		playsound(get_turf(user), 'sound/weapons/silencer_mimejutsu.ogg', 10, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Silencer", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
