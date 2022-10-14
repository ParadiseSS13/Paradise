/obj/item/stock_parts/cell/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN
	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	add_game_logs("draining energy from [src] [COORD(src)]", ninja)
	if(charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(charge > 0 && !maxcapacity)
			// Берём 20% от макс. заряда
			drain = maxcharge * 0.2
			// Лимитируем
			// Проверяем меньше ли оно чем mindrain
			drain = drain < ninja_gloves.mindrain ? ninja_gloves.mindrain : drain
			// Проверяем больше ли оно чем maxdrain
			drain = drain > ninja_gloves.maxdrain ? ninja_gloves.maxdrain : rand(drain, ninja_gloves.maxdrain)
			// Проверяем больше ли drain, чем нынешний заряд
			if(charge < drain)
				drain = charge
			// Зарядились до конца
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			// Сама зарядка
			if(do_after(ninja,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break
		charge = 0
		corrupt()
		update_icon()

	return drain_total
