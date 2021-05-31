/datum/martial_combo/synthojitsu/lock
	name = "Lock"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Allows user to grab opponent quickly"

/datum/martial_combo/synthojitsu/lock/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/MA)
	var/obj/item/grab/G = target.grabbedby(user, 1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : aggressively grabbed", ATKLOG_ALL)
		user.adjust_nutrition(-25)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
