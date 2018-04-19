

/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/U, params)
	if(U==suitOccupant)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		if(istype(I, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/CELL
			if(CELL.maxcharge > cell.maxcharge && suitGloves)
				to_chat(U, "<span class='notice'>Higher maximum capacity detected.\nUpgrading...</span>")
				if(n_gloves && n_gloves.candrain && do_after(U, s_delay, target = U))
					U.drop_item()
					CELL.loc = src
					CELL.charge = min(CELL.charge+cell.charge, CELL.maxcharge)
					var/obj/item/stock_parts/cell/old_cell = cell
					old_cell.charge = 0
					U.put_in_hands(old_cell)
					old_cell.add_fingerprint(U)
					old_cell.corrupt()
					old_cell.updateicon()
					cell = CELL
					to_chat(U, "<span class='notice'>Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%</span>")
				else
					to_chat(U, "<span class='danger'>Procedure interrupted. Protocol terminated.</span>")
			return
	..()