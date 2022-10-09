// KRAV MAGA COMBOS

// Leg Sweep
/datum/martial_combo/krav_maga/leg_sweep
	name = "Leg Sweep"
	explaination_text = "Trips the victim, rendering them prone for a short time."

/datum/martial_combo/krav_maga/leg_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.stat || target.IsWeakened())
		return FALSE
	if(!user.get_num_legs())
		to_chat(user, "<span class='warning'>You suddenly notice you have no legs with which to sweep - how did that happen?!</span>")
		return MARTIAL_COMBO_DONE_CLEAR_COMBOS
	if(!target.get_num_legs())
		to_chat(user, "<span class='warning'>[target] has no legs to sweep!</span>")
		return MARTIAL_COMBO_DONE_CLEAR_COMBOS
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	target.visible_message("<span class='warning'>[user] leg sweeps [target]!</span>", \
					  	"<span class='userdanger'>[user] leg sweeps you!</span>")
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	target.apply_damage(5, BRUTE)
	target.KnockDown(4 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Leg Sweep", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS

// Lung Punch
/datum/martial_combo/krav_maga/lung_punch
	name = "Lung Punch"
	explaination_text = "Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time, and can be incapacitated with a few more punches."

/datum/martial_combo/krav_maga/lung_punch/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message("<span class='warning'>[user] pounds [target] on the chest!</span>", \
				  	"<span class='userdanger'>[user] slams your chest! You can't breathe!</span>")
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	target.AdjustLoseBreath(10 SECONDS)
	target.adjustStaminaLoss(30)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Lung Punch", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS

// Neck Chop
/datum/martial_combo/krav_maga/neck_chop
	name = "Neck Chop"
	explaination_text = "Injures the neck, stopping the victim from speaking for a while."

/datum/martial_combo/krav_maga/neck_chop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message("<span class='warning'>[user] karate chops [target]'s neck!</span>", \
		"<span class='userdanger'>[user] karate chops your neck, rendering you unable to speak for a short time!</span>")
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
	target.AdjustSilence(20 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Neck Chop", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
