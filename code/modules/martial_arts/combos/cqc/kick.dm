/datum/martial_combo/cqc/kick
	name = "CQC Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Knocks opponent away and slows them. Will instead deal massive stamina damage, inflict minor brain damage, and mute opponents who are on the ground."

/datum/martial_combo/cqc/kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	. = MARTIAL_COMBO_FAIL
	if(!IS_HORIZONTAL(target) && user != target)
		target.visible_message("<span class='warning'>[user] kicks [target] back!</span>", \
							"<span class='userdanger'>[user] kicks you back!</span>")
		playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 25, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 1, 14, user)
		target.apply_damage(25, STAMINA)
		target.Slowed(5 SECONDS)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	else if(IS_HORIZONTAL(target) && user != target)
		target.visible_message("<span class='warning'>[user] kicks [target]'s head, disorienting [target.p_them()]!</span>", \
							"<span class='userdanger'>[user] kicks your head, disorienting you!</span>")
		playsound(get_turf(user), 'sound/weapons/genhit1.ogg', 25, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 1, 8, user)
		target.apply_damage(40, STAMINA)
		target.adjustBrainLoss(10)
		target.Silence(3 SECONDS)
		add_attack_logs(user, target, "Kicked in the head with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
