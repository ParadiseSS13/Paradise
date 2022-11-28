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

/*
 * Раньше адреналин регенился посредством наполнения костюма Радием.
 * Позже я решила, что это не лучший метод в наших реалиях и радий для ниндзя слишком легко достать
 * Потому заменила на уран. Но старый код оставлю тут, на всякий случай

	if(istype(I, /obj/item/reagent_containers/glass) && I.reagents.has_reagent("radium", a_transfer) && a_boost != TRUE)//If it's a glass beaker, and what we're transferring is radium.
		I.reagents.remove_reagent("radium", a_transfer)
		a_boost = TRUE;
		to_chat(ninja, span_notice("The suit's adrenaline boost is now reloaded."))
		return
*/

	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		var/obj/item/stack/sheet/mineral/uranium/uranium_stack = I
		if(uranium_stack.amount >= a_transfer && !a_boost)
			a_boost = TRUE
			uranium_stack.use(a_transfer)
			for(var/datum/action/item_action/ninjaboost/ninja_action in actions)
				toggle_ninja_action_active(ninja_action, TRUE)
			to_chat(ninja, span_notice("The suit's adrenaline boost is now reloaded."))
		else if(uranium_stack.amount >= a_transfer && !heal_available)
			heal_available = TRUE
			uranium_stack.use(a_transfer)
			for(var/datum/action/item_action/ninjaheal/ninja_action in actions)
				toggle_ninja_action_active(ninja_action, TRUE)
			to_chat(ninja, span_notice("The suit's restorative cocktail is now reloaded."))
		return

	else if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/new_cell = I
		var/obj/item/stock_parts/cell/old_cell = cell
		if(cell.maxcharge == 100000)
			to_chat(ninja, span_danger("Upgrade limit reached! Further cell upgrade's aren't possible."))
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
				new_cell.maxcharge = min(new_cell.maxcharge, 100000)
				if(new_cell.maxcharge == 100000)
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
