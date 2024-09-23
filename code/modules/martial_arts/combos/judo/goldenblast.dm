/datum/martial_combo/judo/goldenblast
	// This is incredibly stupid. I love it.
	name = "Golden Blast"
	steps = list(MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HELP)
	explaination_text = "Through use of a martial arts form, you can stun a foe with life energy. Or by overcharging the belt's nanites. Take your Pick."
	combo_text_override = "Help, Disarm, Help, Grab, Disarm, Disarm, Grab, Help, Disarm, Disarm, Grab, Help"

/datum/martial_combo/judo/goldenblast/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] blasts [target] with energy, sending [target.p_them()] to the ground!</span>", \
						"<span class='userdanger'>[user] makes strange hand gestures, screams wildly and prods you directly in the chest! You feel the wrath of the GOLDEN BOLT surge through your body! You've been utterly robusted!</span>")
	playsound(get_turf(target), 'sound/weapons/taser.ogg', 55, TRUE, -1)
	playsound(get_turf(target), 'sound/weapons/tase.ogg', 55, TRUE, -1)
	target.SpinAnimation(10, 1)
	do_sparks(5, FALSE, target)
	user.say("GOLDEN BLAST!")
	playsound(get_turf(user), 'sound/weapons/goldenblast.ogg', 60, TRUE, -1)
	target.apply_damage(120, STAMINA)
	target.KnockDown(30 SECONDS)
	target.SetConfused(30 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Golden Blast", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
