/datum/martial_combo/plasma_fist/throwback
	name = "Throwback"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Throws the target and an item at them."

/datum/martial_combo/plasma_fist/throwback/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] has hit [target] with Plasma Punch!</span>", \
								"<span class='userdanger'>[user] has hit [target] with Plasma Punch!</span>")
	playsound(target.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
	target.throw_at(throw_target, 200, 4, user)
	user.say("HYAH!")
	return MARTIAL_COMBO_DONE
