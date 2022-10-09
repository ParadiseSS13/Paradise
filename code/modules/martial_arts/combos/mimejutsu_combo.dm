// MIMEJUTSU COMBOS

/datum/martial_combo/mimejutsu/mimechucks
	name = "Mimechucks"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Hits the opponent with invisible nunchucks."

/datum/martial_combo/mimejutsu/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsStunned() && !target.IsWeakened())
		var/damage = rand(5, 8) + user.dna.species.punchdamagelow
		if(!damage)
			playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			target.visible_message("<span class='warning'>[user] swings invisible nunchcuks at [target]..and misses?</span>")
			return MARTIAL_COMBO_DONE


		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, MELEE)

		target.visible_message("<span class='danger'>[user] has hit [target] with invisible nunchucks!</span>", \
								"<span class='userdanger'>[user] has hit [target] with a with invisible nunchuck!</span>")
		playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		target.apply_damage(damage, STAMINA, affecting, armor_block)
		add_attack_logs(user, target, "Melee attacked with [src] (mimechuck)")

		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT


/datum/martial_combo/mimejutsu/silent_palm
	name = "Silent Palm"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Use mime energy to throw someone back."

/datum/martial_combo/mimejutsu/silent_palm/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsStunned() && !target.IsWeakened())
		target.visible_message("<span class='danger'>[user] has barely touched [target] with [user.p_their()] palm!</span>", \
						"<span class='userdanger'>[user] hovers [user.p_their()] palm over your face!</span>")

		var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
		target.throw_at(throw_target, 200, 4, user)
	return MARTIAL_COMBO_DONE_BASIC_HIT


/datum/martial_combo/mimejutsu/smokebomb
	name = "Smokebomb"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Drops a mime smokebomb."

/datum/martial_combo/mimejutsu/smokebomb/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] throws an invisible smoke bomb!!</span>")

	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(5, 0, target.loc)
	smoke.start()

	return MARTIAL_COMBO_DONE_BASIC_HIT
