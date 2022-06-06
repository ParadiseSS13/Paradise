/datum/martial_combo/mimejutsu/mimechucks
	name = "Мимчаки"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Ударить оппонента невидимыми нунчаками."

/datum/martial_combo/mimejutsu/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.stunned && !target.IsWeakened())
		var/damage = rand(5, 8) + user.dna.species.punchdamagelow
		if(!damage)
			playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			target.visible_message("<span class='warning'>[user] бь[pluralize_ru(user.gender,"ёт","ют")] невидимыми нунчаками по [target]… и промахива[pluralize_ru(user.gender,"ется","ются")]?</span>")
			return MARTIAL_COMBO_DONE


		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, "melee")

		target.visible_message("<span class='danger'>[user] ударя[pluralize_ru(user.gender,"ет","ют")] по [target] невидимыми нунчаками!</span>", \
								"<span class='userdanger'>[user] ударя[pluralize_ru(user.gender,"ет","ют")] по [target] невидимыми нунчаками!</span>")
		playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		target.apply_damage(damage, STAMINA, affecting, armor_block)
		add_attack_logs(user, target, "Melee attacked with [src] (mimechuck)")

		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
