/datum/martial_combo/plasma_fist/plasma_fist
	name = "The Plasma Fist"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Knocks the brain out of the opponent and gibs their body."

/datum/martial_combo/plasma_fist/plasma_fist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	playsound(target.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	user.say("PLASMA FIST!")
	target.visible_message("<span class='danger'>[user] has hit [target] with THE PLASMA FIST TECHNIQUE!</span>", \
								"<span class='userdanger'>[user] has hit [target] with THE PLASMA FIST TECHNIQUE!</span>")
	target.gib()
	return MARTIAL_COMBO_DONE
