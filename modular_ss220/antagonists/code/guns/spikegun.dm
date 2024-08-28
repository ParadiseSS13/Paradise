/// Шипомет перезаряжаемый через "вокс батарейки"
/obj/item/gun/energy/spike
	name = "\improper Vox spike gun"
	desc = "Оружие причудливой формы с яркими пурпурными энергетическими светочами. Рукоять предназначена для когтистой руки. Выстреливает энергетическими кристаллами."
	icon = 'modular_ss220/antagonists/icons/guns/vox_guns.dmi'
	lefthand_file = 'modular_ss220/antagonists/icons/guns/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/antagonists/icons/guns/inhands/guns_righthand.dmi'
	icon_state = "spike"
	item_state = "spike"
	charge_sections = 4
	inhand_charge_sections = 4
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound_text = "air gap"
	can_suppress = FALSE
	burst_size = 3	// выстреливает всегда очередью
	shaded_charge = TRUE
	can_charge = FALSE
	charge_delay = 4
	cell_type = /obj/item/stock_parts/cell/vox_spike
	ammo_type = list(/obj/item/ammo_casing/energy/vox_spike)
	var/can_reload = TRUE
	var/is_vox_private = FALSE

/obj/item/gun/energy/spike/pickup(mob/user)
	. = ..()
	if(!is_vox_private)
		is_vox_private = TRUE
		to_chat(user, span_notice("Оружие инициализировало вас, более никто кроме Воксов не сможет им воспользоваться."))

/obj/item/gun/energy/spike/afterattack(atom/target, mob/living/user, flag, params)
	if(is_vox_private && !isvox(user))
		if(prob(20))
			to_chat(user, span_notice("Оружие отказывается с вами работать и не активируется."))
		return FALSE
	. = ..()

/obj/item/gun/energy/spike/emp_act()
	return

// Перезарядка батареями
/obj/item/gun/energy/spike/attackby(obj/item/I, mob/user, params)
	if(can_reload && istype(I, cell_type) && user && user.unEquip(I))
		to_chat(user, span_notice("Вы заменили [I] в [src]!"))
		if(cell)
			user.put_in_hands(cell)
		I.forceMove(src)
		cell = I
		on_recharge()
		update_icon()
		playsound(src, 'modular_ss220/antagonists/sound/guns/m79_break_open.ogg', 50, 1)
		return TRUE
	. = ..()

/obj/item/gun/energy/spike/update_icon_state()
	. = ..()
	var/inhand_ratio = CEILING((cell.charge / cell.maxcharge) * inhand_charge_sections, 1)
	var/new_item_state = "[initial(item_state)][inhand_ratio]"
	item_state = new_item_state


/// Самозаряжаемый шипомет, шипы чуть-чуть слабее, но зато самовосстанавливаются и лучше проходят через броню.
/obj/item/gun/energy/spike/long
	name = "\improper Vox spike longgun"
	desc = "Оружие причудливой формы с яркими пурпурными энергетическими светочами. Рукоять предназначена для когтистой руки. Выстреливает длинными энергетическими самовосстановимыми кристаллами с увеличенной проникающей способностью."
	icon_state = "spike_long"
	item_state = "spike_long"
	charge_sections = 6
	inhand_charge_sections = 6
	selfcharge = TRUE
	charge_delay = 4
	ammo_type = list(/obj/item/ammo_casing/energy/vox_spike/long)

/obj/item/gun/energy/spike/long/process()
	if(selfcharge)
		if(charge_tick < charge_delay)
			return ..()
		playsound(src, 'modular_ss220/antagonists/sound/guns/m79_reload.ogg', 25, 1)
	. = ..()


/// Шипомет заряжаемый за счет нутриентов ВОКСа или крови и мяса гуманоида другой расы. Сильные и болезненные шипы, но всего 4.
/// Батарея несъемная.
/obj/item/gun/energy/spike/bio
	name = "\improper Vox spike biogun"
	desc = "Оружие причудливой формы с шипами-трубками для нанизывания на руку. Рукоять предназначена для когтистой руки и имеет заостренные полые шипы. Выстреливает большими энергетическими распадающимися заостренными кристаллами, выматывающие цель и рикошетящую о поверхность."
	icon_state = "spike_bio"
	item_state = "spike_bio"
	w_class = WEIGHT_CLASS_HUGE
	charge_sections = 4
	inhand_charge_sections = 4
	ammo_type = list(/obj/item/ammo_casing/energy/vox_spike/big)
	selfcharge = TRUE
	can_reload = FALSE
	charge_delay = 8
	var/nutrition_cost = 20 // Сколько нутриентов тратится за 1 тик
	var/brute_cost = 5 // Цена за то что ты не вокс
	var/stamine_cost = 20 // Цена за то что ты не вокс

/obj/item/gun/energy/spike/bio/process()
	if(selfcharge)
		if(!ishuman(loc))
			return FALSE
		if(charge_tick < charge_delay)
			return ..()
		var/mob/living/carbon/human/user = loc
		if(user.nutrition <= NUTRITION_LEVEL_HYPOGLYCEMIA)
			return ..()
		user.adjust_nutrition(-nutrition_cost)
		if(!isvox(user))
			user.adjustBruteLoss(brute_cost)
			user.adjustStaminaLoss(stamine_cost)
		playsound(src, 'modular_ss220/antagonists/sound/guns/m79_reload.ogg', 25, 1)

	. = ..()

