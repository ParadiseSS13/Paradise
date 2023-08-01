/datum/martial_combo/mr_chang/steal_card
	name = "Bonus card please!"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Забирает у цели любой предмет, находящийся в слоте ID-карты и помещает его в руку атакующего."
	combo_text_override = "Grab, switch hands, Disarm"

/datum/martial_combo/mr_chang/steal_card/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/mob/living/carbon/human/T = target
	if(!istype(T))
		return MARTIAL_COMBO_FAIL

	var/obj/item/I = T.get_item_by_slot(slot_wear_id)
	if(istype(I))
		T.drop_item_ground(I)
		user.put_in_hands(I, ignore_anim = FALSE)
		user.say(pick("Ваша бонусная карта!", "5000 баллов списано!", "Принимаем карты всех банков!", \
						"Наше лучшее предложение!", "Безналичный рассчёт!", "Хватай! Бесплатно!!"))
		var/attack_verb = pick("cashbacked", "discounted", "traded", "contracted")
		target.visible_message("<span class='warning'>[user] [attack_verb] [target]!</span>", \
						"<span class='userdanger'>[user] [attack_verb] you!</span>")
		var/sound = pick('sound/weapons/mr_chang/mr_chang_steal_card_1.mp3', 'sound/weapons/mr_chang/mr_chang_steal_card_2.mp3', \
						'sound/weapons/mr_chang/mr_chang_steal_card_3.mp3', 'sound/weapons/mr_chang/mr_chang_steal_card_4.mp3')
		playsound(get_turf(user), sound, 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Steal Card", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	else
		return MARTIAL_COMBO_FAIL
