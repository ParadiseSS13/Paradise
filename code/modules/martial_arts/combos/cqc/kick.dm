/datum/martial_combo/cqc/kick
	name = "CQC-пинок"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Сбивает с ног оппонента. Нокаутирует лежачего оппонента, отшвыривая его."

/datum/martial_combo/cqc/kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	. = MARTIAL_COMBO_FAIL
	if(!target.stat || !target.IsWeakened())
		target.visible_message("<span class='warning'>[user] отбрасыва[pluralize_ru(user.gender,"ет","ют")] [target] пинком!</span>", \
							"<span class='userdanger'>[user] отбрасыва[pluralize_ru(user.gender,"ет","ют")] вас пинком!</span>")
		playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 1, 14, user)
		target.apply_damage(10, BRUTE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	if(target.IsWeakened() && !target.stat)
		target.visible_message("<span class='warning'>[user] нокаутиру[pluralize_ru(user.gender,"ет","ют")] [target] пинком в голову!</span>", \
					  		"<span class='userdanger'>[user] нокаутиру[pluralize_ru(user.gender,"ет","ют")] вас пинком в голову!</span>")
		playsound(get_turf(user), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		target.SetSleeping(4)
		target.adjustBrainLoss(5)
		add_attack_logs(user, target, "Knocked out with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
