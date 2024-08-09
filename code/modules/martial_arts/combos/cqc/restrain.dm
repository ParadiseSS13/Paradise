/datum/martial_combo/cqc/restrain
	name = "Restrain"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Locks opponents into a restraining position that is more effective the more stamina damage the target has taken, \
						disarm to begin a chokehold that will knock them out."
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
		var/stam_damage = target.getStaminaLoss()
		switch(stam_damage)
			if(0 to 40)
				target.Immobilize(4 SECONDS)
				target.apply_damage(35, STAMINA)
			if(41 to 80)
				target.Stun(6 SECONDS)
			if(81 to 120)
				target.apply_damage(40, STAMINA)

		CQC.restraining = TRUE
		addtimer(CALLBACK(CQC, TYPE_PROC_REF(/datum/martial_art/cqc, drop_restraining)), 5 SECONDS, TIMER_UNIQUE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Restrain", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
