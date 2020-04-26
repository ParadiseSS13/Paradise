/datum/martial_combo/cqc/restrain
	name = "TEXT"
	steps = list()
	explaination_text = "TEXT"
	combo_text = "TEXT"

/datum/martial_combo/cqc/restrain/perform_combo(mob/living/carbon/human/user, mob/living/target, /datum/martial_art/MA)
	if(MA.restraining)
		return MARTIAL_COMBO_FAIL
	if(!D.stat)
		D.visible_message("<span class='warning'>[A] locks [D] into a restraining position!</span>", \
							"<span class='userdanger'>[A] locks you into a restraining position!</span>")
		D.adjustStaminaLoss(20)
		D.Stun(5)
		restraining = TRUE
		addtimer(CALLBACK(MA, /datum/martial_art/.proc/drop_restraining), 50, TIMER_UNIQUE)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Restrain", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
