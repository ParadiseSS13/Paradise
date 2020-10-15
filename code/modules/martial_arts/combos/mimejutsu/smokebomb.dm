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
