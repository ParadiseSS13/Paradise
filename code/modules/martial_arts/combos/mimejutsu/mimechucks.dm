/datum/martial_combo/mimejutsu/mimechucks
	name = "Mimechucks"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Hits the opponent with invisible nunchucks."

/datum/martial_combo/mimejutsu/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsStunned() && !target.IsWeakened())
		var/damage = 60

		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, "melee")
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.apply_damage(damage, STAMINA, affecting, armor_block)
		add_attack_logs(user, target, "Melee attacked with [src] : Mimechucks", ATKLOG_ALL)
		playsound(get_turf(user), 'sound/weapons/mimechucks_mimejutsu.ogg', 10, 1, -1)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
