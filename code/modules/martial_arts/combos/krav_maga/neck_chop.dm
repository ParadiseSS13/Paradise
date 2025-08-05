/datum/martial_combo/krav_maga/neck_chop
	name = "Neck Chop"
	explaination_text = "Injures the neck, stopping the victim from speaking for a while."

/datum/martial_combo/krav_maga/neck_chop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(user.a_intent == INTENT_HELP)
		return FALSE
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message("<span class='warning'>[user] karate chops [target]'s neck!</span>", \
		"<span class='userdanger'>[user] karate chops your neck, rendering you unable to speak for a short time!</span>")
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
	target.AdjustSilence(20 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Neck Chop", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
