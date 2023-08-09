/datum/martial_combo/mimejutsu/execution
	name = "Silent Execution"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Breaks bones or causes massive damage to the body if the bones are already broken."

/datum/martial_combo/mimejutsu/execution/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/MA)
	var/datum/martial_art/mimejutsu/mimejutsu = MA
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!istype(mimejutsu))
		return MARTIAL_COMBO_FAIL
	if(!target.stat)
		if(!(affected.status & ORGAN_BROKEN) && !(affected.is_robotic()) && !(affected.cannot_break))
			affected.fracture()
			user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		else
			target.apply_damage(40, BRUTE, user.zone_selected)
			objective_damage(user, target, 40, BRUTE)
			user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Silent Execution", ATKLOG_ALL)
		playsound(get_turf(user), 'sound/weapons/blunthit_mimejutsu.ogg', 10, 1, -1)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
