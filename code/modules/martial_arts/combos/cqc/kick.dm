/datum/martial_combo/cqc/kick
	name = "CQC Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Knocks opponent away. Knocks out stunned or knocked down opponents."
	combo_text = "Harm Harm"

/datum/martial_combo/cqc/kick/perform_combo(mob/living/carbon/human/user, mob/living/target, /datum/martial_art/MA)
	. = MARTIAL_COMBO_FAIL
	if(!D.stat || !D.IsWeakened())
		D.visible_message("<span class='warning'>[A] kicks [D] back!</span>", \
							"<span class='userdanger'>[A] kicks you back!</span>")
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 1, 14, A)
		D.apply_damage(10, BRUTE)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	if(D.IsWeakened() && !D.stat)
		D.visible_message("<span class='warning'>[A] kicks [D]'s head, knocking [D.p_them()] out!</span>", \
					  		"<span class='userdanger'>[A] kicks your head, knocking you out!</span>")
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		D.SetSleeping(15)
		D.adjustBrainLoss(15)
		add_attack_logs(A, D, "Knocked out with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
