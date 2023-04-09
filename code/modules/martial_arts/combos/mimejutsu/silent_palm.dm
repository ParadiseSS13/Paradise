/datum/martial_combo/mimejutsu/silent_palm
	name = "Silent Palm"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Use mime energy to throw someone back."

/datum/martial_combo/mimejutsu/silent_palm/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.stunned && !target.IsWeakened())
		target.visible_message("<span class='danger'>[user] has barely touched [target] with [user.p_their()] palm!</span>", \
						"<span class='userdanger'>[user] hovers [user.p_their()] palm over your face!</span>")

		var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
		target.throw_at(throw_target, 4, 4, user)
	return MARTIAL_COMBO_DONE_BASIC_HIT
