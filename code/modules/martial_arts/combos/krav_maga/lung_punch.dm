/datum/martial_combo/krav_maga/lung_punch
	name = "Lung Punch"
	explaination_text = "Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."

/datum/martial_combo/krav_maga/lung_punch/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] pounds [target] on the chest!</span>", \
				  	"<span class='userdanger'>[user] slams your chest! You can't breathe!</span>")
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	target.AdjustLoseBreath(5)
	target.adjustOxyLoss(10)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Lung Punch", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
