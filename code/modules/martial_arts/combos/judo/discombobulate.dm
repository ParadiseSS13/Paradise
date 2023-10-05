/datum/martial_combo/judo/discombobulate
	name = "Discombobulate"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Deliver a palm strike to your opponents ear, briefly confusing them"
	combo_text_override = "Disarm, Grab"

/datum/martial_combo/judo/discombobulate/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] strikes [target] in the head with [user.p_their()] palm!</span>", \
						"<span class='userdanger'>[user] strikes you with [user.p_their()] palm!</span>")
	playsound(get_turf(user), 'sound/weapons/slap.ogg', 40, TRUE, -1)
	target.apply_damage(10, STAMINA)
	target.AdjustConfused(5 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Discombobulate", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
