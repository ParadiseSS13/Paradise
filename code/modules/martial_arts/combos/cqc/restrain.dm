/datum/martial_combo/cqc/restrain
	name = "Restrain"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Locks opponents into a restraining position, disarm to knock them out with a choke hold."
	combo_text_override = "Grab, switch hands, Grab"

/datum/martial_combo/cqc/restrain/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/datum/martial_art/cqc/CQC = MA
	if(!istype(CQC))
		return MARTIAL_COMBO_FAIL
	if(CQC.restraining)
		return MARTIAL_COMBO_FAIL
	if(!target.stat)
		target.visible_message("<span class='warning'>[user] locks [target] into a restraining position!</span>", \
							"<span class='userdanger'>[user] locks you into a restraining position!</span>")
		target.adjustStaminaLoss(30)
		target.Stun(2)
		CQC.restraining = TRUE
		addtimer(CALLBACK(CQC, /datum/martial_art/cqc/.proc/drop_restraining), 50, TIMER_UNIQUE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Restrain", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
