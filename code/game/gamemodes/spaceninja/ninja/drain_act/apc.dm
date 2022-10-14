/obj/machinery/power/apc/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	add_game_logs("draining energy from [src] [COORD(src)]", ninja)
	var/area/area = get_area(src)
	if(area && (istype(area, /area/engine/engineering) || istype(area, /area/engine/supermatter)))
		//На русском чтобы даже полному идиоту было ясно, почему им не даётся сосать ток из этого АПЦ
		to_chat(ninja, span_danger("Внимание: Высасывание энергии из АПЦ в этой зоне потенциально может привести к неконтролируемым разрушениям. Процесс отменён."))
		return INVALID_DRAIN
	if(cell?.charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		while(cell.charge > 0 && !maxcapacity)
			// Берём 20% от макс. заряда
			drain = cell.maxcharge * 0.2
			// Лимитируем
			// Проверяем меньше ли оно чем mindrain
			drain = drain < ninja_gloves.mindrain ? ninja_gloves.mindrain : drain
			// Проверяем больше ли оно чем maxdrain
			drain = drain > ninja_gloves.maxdrain ? ninja_gloves.maxdrain : rand(drain, ninja_gloves.maxdrain)
			// Проверяем больше ли drain, чем нынешний заряд
			if(cell.charge < drain)
				drain = cell.charge
			// Зарядились до конца
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			// Сама зарядка
			if(do_after(ninja ,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

		if(!(on_blueprints & emagged))
			flick("apc-spark", ninja_gloves)
			playsound(loc, "sparks", 50, TRUE, 5)
			emagged = TRUE
			locked = FALSE
			update_icon()

	return drain_total
