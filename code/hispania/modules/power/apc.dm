/obj/machinery/power/apc
	var/newcell = FALSE  //esto es para cuando se le instala una bateria nueva al apc

/obj/machinery/power/apc/proc/update_cell()
	if(cell)	// esto es para que las baterias autorecargables no se recarguen tan rapido
		if(cell.self_recharge)
			if(!cell.minorrecharging)
				cell.minorrecharging = TRUE
				addtimer(CALLBACK(cell, /obj/item/stock_parts/cell/proc/minorrecharge), 20 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		if(newcell) // esto es para descargar las baterias nuevas en el apc
			cell.charge *= GLOB.CELLRATE
			cell.update_icon() //fin hispania
	newcell = FALSE

/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	var/shouldplaysound = FALSE
	if(panel_open || opened || W.works_from_distance)
		if(W.works_from_distance)
			if(cell)
				to_chat(user, "<span class='notice'> the APC has a [cell.name].</span>")
			else
				to_chat(user, "<span class='notice'>the APC does not have a power cell.</span>")
		for(var/obj/item/stock_parts/cell/C in W.contents)
			if(istype(C, /obj/item/stock_parts/cell))
				if(cell)
					if(C.get_part_rating() > cell.get_part_rating())
						var/tempcharge = cell.charge
						cell.charge = 0
						cell.give(C.charge)
						C.charge = 0
						C.give(tempcharge)
						W.handle_item_insertion(cell, 1)
						W.remove_from_storage(C, src)
						to_chat(user, "<span class='notice'>[cell.name] replaced with [C.name].</span>")
						C.forceMove(src)
						cell = C
						charging = 0
						chargecount = 0
						shouldplaysound = TRUE
						break
				if(!cell)
					W.remove_from_storage(C, src)
					C.forceMove(src)
					cell = C
					charging = 0
					chargecount = 0
					shouldplaysound = TRUE
					C.update_icon()
					update_icon()
					newcell = TRUE
					to_chat(user, "<span class='notice'> the APC now has a [C.name].</span>")
					break
		RefreshParts()
	else
		if(cell)
			to_chat(user, "<span class='notice'>the APC has a [cell.name].</span>")
		else
			to_chat(user, "<span class='notice'>the APC does not have a power cell.</span>")
	if(shouldplaysound)
		W.play_rped_sound()
	return TRUE
