/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = EQUIP
	var/obj/item/weapon/stock_parts/cell/charging = null
	var/chargelevel = -1
	proc
		updateicon()
			icon_state = "ccharger[charging ? 1 : 0]"

			if(charging && !(stat & (BROKEN|NOPOWER)) )

				var/newlevel = 	round(charging.percent() * 4.0 / 99)
//				to_chat(world, "nl: [newlevel]")

				if(chargelevel != newlevel)

					overlays.Cut()
					overlays += "ccharger-o[newlevel]"

					chargelevel = newlevel
			else
				overlays.Cut()
	examine(mob/user)
		if(..(user, 5))
			to_chat(user, "There's [charging ? "a" : "no"] cell in the charger.")
			if(charging)
				to_chat(user, "Current charge: [charging.charge]")

	attackby(obj/item/weapon/W, mob/user, params)
		if(stat & BROKEN)
			return

		if(istype(W, /obj/item/weapon/stock_parts/cell) && anchored)
			if(charging)
				to_chat(user, "\red There is already a cell in the charger.")
				return
			else
				var/area/a = loc.loc // Gets our locations location, like a dream within a dream
				if(!isarea(a))
					return
				if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
					to_chat(user, "\red The [name] blinks red as you try to insert the cell!")
					return

				user.drop_item()
				W.loc = src
				charging = W
				user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
				chargelevel = -1
			updateicon()
		else if(istype(W, /obj/item/weapon/wrench))
			if(charging)
				to_chat(user, "\red Remove the cell first!")
				return

			anchored = !anchored
			to_chat(user, "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)

	attack_hand(mob/user)
		if(charging)
			usr.put_in_hands(charging)
			charging.add_fingerprint(user)
			charging.updateicon()

			src.charging = null
			user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
			chargelevel = -1
			updateicon()

	attack_ai(mob/user)
		return

	emp_act(severity)
		if(stat & (BROKEN|NOPOWER))
			return
		if(charging)
			charging.emp_act(severity)
		..(severity)


	process()
//		to_chat(world, "ccpt [charging] [stat]")
		if(!charging || (stat & (BROKEN|NOPOWER)) || !anchored)
			return

		use_power(2000)		//this used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
		charging.give(1750)	//inefficiency.

		updateicon()
