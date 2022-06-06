/datum/martial_combo/plasma_fist/throwback
	name = "Отбросить"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Отбрасывает цель далеко вперед"

/datum/martial_combo/plasma_fist/throwback/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] попада[pluralize_ru(user.gender,"ет","ют")] в [target] Плазменным ударом!</span>", \
								"<span class='userdanger'>[user] попада[pluralize_ru(user.gender,"ет","ют")] в [target] Плазменным ударом!</span>")
	playsound(target.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
	target.throw_at(throw_target, 10, 4, user)
	user.say("ХЬЙА!")
	return MARTIAL_COMBO_DONE
