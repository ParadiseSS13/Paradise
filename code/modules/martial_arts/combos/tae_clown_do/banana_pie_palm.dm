/datum/martial_combo/tae_clown_do/banana_pie_palm
	name = "Banana Pie Palm"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Sends a banana cream pie directly into your opponents face. Causes a decent amount of stamina damage."

/datum/martial_combo/tae_clown_do/banana_pie_palm/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat)
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		target.visible_message("<span class='warning'>[user] slams a banana cream pie into [target]'s face aggresively!</span>",
							"<span class='userdanger'>[user] aggresively slams a banana cream pie into your face!</span>")
		playsound(target.loc, 'sound/effects/splat.ogg', 50, TRUE, -1)
		target.adjustStaminaLoss(40)
		target.Weaken(3)
		new/obj/effect/decal/cleanable/pie_smudge(get_turf(target))
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Banana Pie Palm", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
