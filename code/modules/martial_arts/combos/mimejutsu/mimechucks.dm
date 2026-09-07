/datum/martial_combo/mimejutsu/mimechucks
	name = "Mimechucks"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Hits the opponent with invisible nunchucks."

/datum/martial_combo/mimejutsu/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsStunned() && !target.IsWeakened())
		var/damage = rand(5, 8) + user.dna.species.punchdamagelow
		if(!damage)
			playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			target.visible_message(SPAN_WARNING("[user] swings invisible nunchcuks at [target]..and misses?"))
			return MARTIAL_COMBO_DONE


		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, MELEE)

		target.visible_message(SPAN_DANGER("[user] has hit [target] with invisible nunchucks!"), \
								SPAN_USERDANGER("[user] has hit [target] with a with invisible nunchuck!"))
		playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		target.apply_damage(damage, STAMINA, affecting, armor_block)
		add_attack_logs(user, target, "Melee attacked with [src] (mimechuck)")

		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
