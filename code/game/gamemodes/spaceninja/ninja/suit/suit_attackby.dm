/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/ninja, params)
	// Копипаст кода джетпаков в хардсьютах
	if(istype(I, /obj/item/tank/jetpack/suit/ninja))
		if(jetpack)
			to_chat(ninja, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == ninja.get_item_by_slot(slot_wear_suit)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(ninja, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(ninja.unEquip(I))
			I.forceMove(src)
			jetpack = I
			to_chat(ninja, "<span class='notice'>You successfully install the jetpack into [src].</span>")
			return

	if(ninja!=affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		return ..()

	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		var/obj/item/stack/sheet/mineral/uranium/uranium_stack = I
		if(uranium_stack.amount >= a_transfer && a_boost.charge_counter < a_boost.charge_max)
			uranium_stack.use(a_transfer)
			a_boost.action_ready = TRUE
			a_boost.toggle_button_on_off()
			a_boost.recharge_action()
			to_chat(ninja, span_notice("The suit's adrenaline boost is now reloaded."))
	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/crystal_stack = I
		if(crystal_stack.amount >= a_transfer && heal_chems.charge_counter < heal_chems.charge_max)
			crystal_stack.use(a_transfer)
			heal_chems.action_ready = TRUE
			heal_chems.toggle_button_on_off()
			heal_chems.recharge_action()
			to_chat(ninja, span_notice("The suit's restorative cocktail is now reloaded."))
		return

	else if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/new_cell = I
		var/obj/item/stock_parts/cell/old_cell = cell
		if(cell.maxcharge == 100000)
			to_chat(ninja, span_danger("Upgrade limit reached! Further cell upgrade's aren't possible."))
			return
		if(new_cell.rigged)
			to_chat(ninja, span_danger("This cell is hazardous and can explode! Suit's safety system doesn't allow you to put it inside self."))
			return
		if(new_cell.maxcharge > old_cell.maxcharge)
			to_chat(ninja, span_notice("Higher maximum capacity detected.\nUpgrading..."))
			if(do_after(ninja,s_delay, target = src))
				// Отбираем батарейку у игрока
				if(!ninja.drop_item())
					return
				// Запихиваем её в костюм
				new_cell.forceMove(src)
				// На случай если вдруг, как то, игроки умудрятся запихать туда самозарядную батарейку
				new_cell.self_recharge = FALSE
				// Ограничиваем возможный максимальный заряд батареи
				new_cell.maxcharge = min(new_cell.maxcharge, 80000)
				if(new_cell.maxcharge == 80000)
					to_chat(ninja, span_danger("Upgrade limit reached! Further cell upgrade's won't be possible."))
				// Складываем новый заряд со старым не превышая лимита
				new_cell.charge = min(new_cell.charge+old_cell.charge, new_cell.maxcharge)
				// Сохраняем чтобы потом к ней обращаться
				cell = new_cell
				// Обновляем батарейку и на экране статуса
				ninja.mind.ninja.cell = cell
				// Последние шаги со старой батареей
				old_cell.charge = 0
				ninja.put_in_hands(old_cell)
				old_cell.add_fingerprint(ninja)
				old_cell.corrupt()
				old_cell.update_icon()
				to_chat(ninja, span_notice("Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%"))
			else
				to_chat(ninja, span_danger("Procedure interrupted. Protocol terminated."))
		return
	return ..()
