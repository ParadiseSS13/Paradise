/obj/item/storage/part_replacer/afterattack(obj/machinery/power/apc/T as obj, mob/living/carbon/human/user as mob, flag, params)
	..()
	if(flag)
		return
	else if(works_from_distance)
		if(istype(T))
			T.exchange_parts(user, src)
			user.Beam(T,icon_state="rped_upgrade",icon='icons/effects/effects.dmi',time=5)
			return

/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	var/shouldplaysound = FALSE
	if(wiresexposed || W.works_from_distance)
		if(W.works_from_distance)
			if(cell)
				to_chat(user, "<span class='notice'> the APC has a [cell.name].</span>")
			else
				to_chat(user, "<span class='notice'>the APC does not have a power cell.</span>")
		for(var/obj/item/stock_parts/cell/C in W.contents)
			if(istype(C, /obj/item/stock_parts/cell))
				if(cell)
					if(C.rating > cell.rating)
						if(cell.charge > C.charge)
							var/tempcharge = cell.charge
							cell.charge = C.charge
							C.charge = tempcharge
						cell.update_icon()
						W.handle_item_insertion(cell, 1)
						W.remove_from_storage(C, src)
						to_chat(user, "<span class='notice'>[cell.name] replaced with [C.name].</span>")
						C.forceMove(src)
						cell = C
						C.update_icon()
						charging = 0
						chargecount = 0
						shouldplaysound = TRUE
						break
				if(!cell)
					W.remove_from_storage(C, src)
//					C.forceMove(src) //probamos esto en contraste a la linea de abajo //esto no se ha testeado aun
					C.loc = src // esto funciona solo para los rped normales //testeemos esto de nuevo con cambios a la hora de ver si está vacio o no, segundo test
					cell = C
					charging = 0
					chargecount = 0
					shouldplaysound = TRUE
					C.update_icon()
					update_icon()
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
