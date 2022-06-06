/datum/martial_combo/mimejutsu/smokebomb
	name = "Дымовая шашка"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Бросить пантомимовую дымовую шашку."

/datum/martial_combo/mimejutsu/smokebomb/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] броса[pluralize_ru(user.gender,"ет","ют")] невидимую дымовую шашку!</span>")

	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(5, 0, target.loc)
	smoke.start()

	return MARTIAL_COMBO_DONE_BASIC_HIT
