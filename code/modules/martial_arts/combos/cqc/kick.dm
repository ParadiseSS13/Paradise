/datum/martial_combo/cqc/kick
	name = "CQC Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Knocks opponent away. Knocks out stunned or knocked down opponents."

/datum/martial_combo/cqc/kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	. = MARTIAL_COMBO_FAIL
	if(!target.stat || !target.IsWeakened())
		target.visible_message("<span class='warning'>[user] kicks [target] back!</span>", \
							"<span class='userdanger'>[user] kicks you back!</span>")
		playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/bump_impact)
		target.throw_at(throw_target, 1, 14, user, callback = CALLBACK(src, .proc/unregister_bump_impact, target))
		target.apply_damage(10, BRUTE)
		objective_damage(user, target, 10, BRUTE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	if(target.IsWeakened() && !target.stat)
		target.visible_message("<span class='warning'>[user] kicks [target]'s head, knocking [target.p_them()] out!</span>", \
					  		"<span class='userdanger'>[user] kicks your head, knocking you out!</span>")
		playsound(get_turf(user), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		target.SetSleeping(4)
		target.adjustBrainLoss(5)
		add_attack_logs(user, target, "Knocked out with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE

/datum/martial_combo/cqc/kick/proc/bump_impact(mob/living/target, atom/hit_atom, throwingdatum)
	if(target && !iscarbon(hit_atom) && hit_atom.density)
		target.Weaken(1)
		target.take_organ_damage(10)

/datum/martial_combo/cqc/kick/proc/unregister_bump_impact(mob/living/target)
	UnregisterSignal(target, COMSIG_MOVABLE_IMPACT)
