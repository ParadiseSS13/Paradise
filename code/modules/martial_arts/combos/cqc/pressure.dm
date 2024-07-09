/datum/martial_combo/cqc/pressure
	name = "Pressure"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Deals stamina damage, and steals your opponent's item out of their active hand."

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='warning'>[user] forces their arm on [target]'s neck!</span>")
	var/obj/item/I = target.get_active_hand()
	if(I && target.drop_item())
		user.put_in_hands(I)
	target.apply_damage(40, STAMINA)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 5, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
