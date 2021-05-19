/datum/martial_combo/superhuman/hammer_fist
	name = "Hammer Fist"
	explaination_text = "We morph our fist into a bone hammer and slam our target into the ground. Already stunned targets receive twice as much damage."
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)

/datum/martial_combo/superhuman/hammer_fist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(get_turf(target), 'sound/weapons/smash.ogg', 50, TRUE, -1)
	target.visible_message("<span class='warning'>[user]'s hand morphs into a bone hammer and slams [target] into the floor!</span>",
						  "<span class='userdanger'>[user]'s bone hammer slams you into the floor!</span>")
	if(!target.stat || target.IsWeakened())
		target.apply_damage(40, BRUTE)
	else
		target.apply_damage(20, BRUTE)
		target.apply_damage(30, STAMINA)
		target.Weaken(2)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Hammer Fist", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
