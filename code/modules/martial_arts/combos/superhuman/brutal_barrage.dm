/datum/martial_combo/superhuman/brutal_barrage
	name = "Brutal Barrage"
	explaination_text = "We unleash a flurry of swift blows that completely decimate a weakened oppenent."
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)

/datum/martial_combo/superhuman/brutal_barrage/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(get_turf(target), 'sound/weapons/punch1.ogg', 75, 1, -1)
	if(target.health <= 20)
		target.visible_message("<span class='warning'>[user]'s arm swings, enlarging before impact, striking [target]'s face with great force, knocking them out!</span>", \
						  "<span class='userdanger'>[user] slams you in the face, knocking you out!</span>")
		target.SetSleeping(10) //KO
	else
		target.visible_message("<span class='warning'>[user]'s arm swings, enlarging before impact, striking [target]'s face with great force!</span>", \
						  "<span class='userdanger'>[user] slams you in the face!</span>")
	target.apply_damage(target.getBruteLoss() * 0.8, BRUTE, BODY_ZONE_HEAD)
	return MARTIAL_COMBO_DONE
