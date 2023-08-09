/datum/martial_combo/mimejutsu/silent_palm
	name = "Silent Palm"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Use mime energy to throw someone back."

/datum/martial_combo/mimejutsu/silent_palm/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsStunned() && !target.IsWeakened())
		var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
		target.throw_at(throw_target, 4, 4, user)
		target.SetWeakened(1 SECONDS)
		target.apply_damage(20, BRUTE)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(user), 'sound/weapons/blunthit_mimejutsu.ogg', 10, 1, -1)
		add_attack_logs(user, target, "Melee attacked with [src] : Silent Palm", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_BASIC_HIT
