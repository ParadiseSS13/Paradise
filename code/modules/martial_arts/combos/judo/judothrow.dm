/datum/martial_combo/judo/judothrow
	name = "Throw"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Establish a gripset on your opponent and throw them to the floor, inflicting stamina damage"
	combo_text_override = "Grab, Disarm"
/datum/martial_combo/judo/judothrow/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(IS_HORIZONTAL(user) || IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] judo throws [target] to ground!</span>", \
						"<span class='userdanger'>[user] judo throws you to the ground!</span>")
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 40, TRUE, -1)
	target.apply_damage(25, STAMINA)
	target.KnockDown(7 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Judo Throw", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
