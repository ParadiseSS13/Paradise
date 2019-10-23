/obj/item/storage/part_replacer/afterattack(obj/machinery/power/apc/T as obj, mob/living/carbon/human/user as mob, flag, params)
	if(flag)
		return
	else if(works_from_distance)
		if(istype(T))
			if(T.cell)
				T.exchange_parts(user, src)
				user.Beam(T,icon_state="rped_upgrade",icon='icons/effects/effects.dmi',time=5)
			else
				to_chat(user, "<span class='notice'>The APC not have a power cell to replace</span>")
	return

/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if(!cell)
		to_chat(user, "<span class='notice'>The APC not have a power cell to replace</span>")
		return FALSE
	var/shouldplaysound = 0
	if(wiresexposed || W.works_from_distance)
		if(W.works_from_distance)
			to_chat(user, "<span class='notice'> the APC has a [cell.name].</span>")
		for(var/obj/item/stock_parts/cell/C in W.contents)
			if(istype(C, /obj/item/stock_parts/cell))
				if(C.rating > cell.rating)
					if(cell.charge > C.charge)
						var/tempcharge = cell.charge
						cell.charge = C.charge
						C.charge = tempcharge
					cell.update_icon()
					C.update_icon()
					W.remove_from_storage(C, src)
					W.handle_item_insertion(cell, 1)
					C.forceMove(src)
					cell = C
					charging = 0
					chargecount = 0
					to_chat(user, "<span class='notice'>[cell.name] replaced with [C.name].</span>")
					shouldplaysound = 1
					break
		RefreshParts()
	else
		to_chat(user, "<span class='notice'> the APC has a [cell.name].</span>")
	if(shouldplaysound)
		W.play_rped_sound()
	return TRUE
