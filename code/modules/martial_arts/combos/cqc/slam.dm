/datum/martial_combo/cqc/slam
	name = "Slam"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Slam opponent into the ground, knocking them down and confusing them."
	combo_text_override = "Grab, switch hands, Harm"

/datum/martial_combo/cqc/slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] slams [target] into the ground!</span>", \
						"<span class='userdanger'>[user] slams you into the ground!</span>")
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 40, TRUE, -1)
	target.apply_damage(50, STAMINA)
	target.KnockDown(7 SECONDS)
	target.SetConfused(12 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Slam", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE

