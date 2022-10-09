// CQC COMBOS

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
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Consecutive", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL


/datum/martial_combo/cqc/kick
	name = "CQC Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Knocks opponent away. Knocks out stunned or knocked down opponents."

/datum/martial_combo/cqc/kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	. = MARTIAL_COMBO_FAIL
	if(!target.stat || !target.IsWeakened())
		target.visible_message("<span class='warning'>[user] kicks [target] back!</span>", \
							"<span class='userdanger'>[user] kicks you back!</span>")
		playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 1, 14, user)
		target.apply_damage(10, BRUTE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	if(target.IsWeakened() && !target.stat)
		target.visible_message("<span class='warning'>[user] kicks [target]'s head, knocking [target.p_them()] out!</span>", \
					  		"<span class='userdanger'>[user] kicks your head, knocking you out!</span>")
		playsound(get_turf(user), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		target.SetSleeping(30 SECONDS)
		target.adjustBrainLoss(15)
		add_attack_logs(user, target, "Knocked out with martial-art [src] : Kick", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE


/datum/martial_combo/cqc/pressure
	name = "Pressure"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Decent stamina damage."

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] forces their arm on [target]'s neck!</span>")
	target.adjustStaminaLoss(60)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE


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
		target.adjustStaminaLoss(20)
		target.Stun(10 SECONDS)
		CQC.restraining = TRUE
		addtimer(CALLBACK(CQC, /datum/martial_art/cqc/.proc/drop_restraining), 50, TIMER_UNIQUE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Restrain", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL


/datum/martial_combo/cqc/slam
	name = "Slam"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Slam opponent into the ground, knocking them down."
	combo_text_override = "Grab, switch hands, Harm"

/datum/martial_combo/cqc/slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.IsWeakened() || IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] slams [target] into the ground!</span>", \
						"<span class='userdanger'>[user] slams you into the ground!</span>")
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, 1, -1)
	target.apply_damage(10, BRUTE)
	target.Weaken(12 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Slam", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE

