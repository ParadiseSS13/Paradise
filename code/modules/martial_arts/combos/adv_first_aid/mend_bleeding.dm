/datum/martial_combo/adv_first_aid/mend_bleeding
	name = "Mend Artery"
	steps = list(MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Mends an instance of internal bleeding in the targeted limb."

/datum/martial_combo/adv_first_aid/mend_bleeding/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!do_after(user, 10 SECONDS, TRUE, target))
		to_chat(user, "<span class='warning' You were interrupted! </span>")
		return

	if(ishuman(target))
		target.visible_message("<span class='warning'>[user] creates a tourniquet using [target]'s clothing. </span>", \
								"<span class='userdanger'>[user] makes a tourniquet out of your clothes.</span>")
		var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
		if(affected && affected.internal_bleeding)
			target.apply_damage(10, BRUTE)
			target.Slowed(5)
			affected.internal_bleeding = FALSE
		add_attack_logs(user, target, "Healed with martial-art [MA] : [src]", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
