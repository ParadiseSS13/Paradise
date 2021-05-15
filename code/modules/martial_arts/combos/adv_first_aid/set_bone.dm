/datum/martial_combo/adv_first_aid/set_bone
	name = "Set Bone"
	steps = list(MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Sets a broken bone, mending it in the targeted limb."

/datum/martial_combo/adv_first_aid/set_bone/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!do_after(user, 10 SECONDS, TRUE, target))
		to_chat(user, "<span class='warning' You were interrupted! </span>")
		return

	if(ishuman(target))
		target.visible_message("<span class='warning'>[user] sets [target]'s broken bone. </span>", \
								"<span class='userdanger'>[user] sets your broken bone, mending it.</span>")
		var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
		if(affected && affected.status & ORGAN_BROKEN)
			target.apply_damage(10, BRUTE)
			target.Slowed(5)
			affected.mend_fracture()
		add_attack_logs(user, target, "Healed with martial-art [MA] : [src]", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
