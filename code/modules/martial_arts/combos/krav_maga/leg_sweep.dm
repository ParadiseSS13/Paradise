/datum/martial_combo/krav_maga/leg_sweep
	name = "Leg Sweep"
	explaination_text = "Trips the victim, rendering them prone for a short time."

/datum/martial_combo/krav_maga/leg_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.stat || target.IsWeakened() || user.a_intent == INTENT_HELP)
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
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	target.apply_damage(5, BRUTE)
	target.KnockDown(4 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Leg Sweep", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
