/datum/martial_combo/cqc/consecutive
	name = "Consecutive CQC"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Mainly offensive move, huge damage and decent stamina damage."

/datum/martial_combo/cqc/consecutive/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat)
		target.visible_message("<span class='warning'>[user] strikes [target]'s abdomen, neck and back consecutively</span>", \
							"<span class='userdanger'>[user] strikes your abdomen, neck and back consecutively!</span>")
		playsound(get_turf(target), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		var/obj/item/I = target.get_active_hand()
		if(I && target.drop_item())
			user.put_in_hands(I)
		target.adjustStaminaLoss(50)
		target.apply_damage(25, BRUTE)
		objective_damage(user, target, 25, BRUTE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Consecutive", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
