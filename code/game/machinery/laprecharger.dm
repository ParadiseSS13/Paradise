//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/laprecharger
	name = "laptop recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	active_power_usage = 2500
	var/obj/item/charging = null
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0"

/obj/machinery/laprecharger/attackby(obj/item/weapon/G as obj, mob/user as mob, params)
	if(istype(user,/mob/living/silicon))
		return
	if(istype(G, /obj/item/weapon/gun/energy) || istype(G, /obj/item/weapon/melee/baton))
		user << "\red The laptop recharger blinks red as you try to insert the item!"
		return
	if(istype(G,/obj/item/device/laptop))
		if(charging)
			return


		// Checks to make sure he's not in space doing it, and that the area got proper power.
		var/area/a = get_area(src)
		if(!isarea(a))
			user << "\red The [name] blinks red as you try to insert the item!"
			return
		if(a.power_equip == 0)
			user << "\red The [name] blinks red as you try to insert the item!"
			return

		if(istype(G, /obj/item/device/laptop))
			var/obj/item/device/laptop/L = G
			if(!L.stored_computer.battery)
				user << "There's no battery in it!"
				return
		user.drop_item()
		G.loc = src
		charging = G
		use_power = 2
		update_icon()
	else if(istype(G, /obj/item/weapon/wrench))
		if(charging)
			user << "\red Remove the laptop first!"
			return
		anchored = !anchored
		user << "You [anchored ? "attached" : "detached"] the recharger."
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)

/obj/machinery/laprecharger/attack_hand(mob/user as mob)
	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		charging.loc = loc
		charging = null
		use_power = 1
		update_icon()

/obj/machinery/laprecharger/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/laprecharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/device/laptop))
			var/obj/item/device/laptop/L = charging
			if(L.stored_computer.battery.charge < L.stored_computer.battery.maxcharge)
				L.stored_computer.battery.give(1000)
				icon_state = icon_state_charging
				use_power(2500)
			else
				icon_state = icon_state_charged
			return


/obj/machinery/laprecharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

/obj/machinery/laprecharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = icon_state_charging
	else
		icon_state = icon_state_idle

// Atlantis: No need for that copy-pasta code, just use var to store icon_states instead.
obj/machinery/laprecharger/wallcharger
	name = "wall laptop recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	icon_state_idle = "wrecharger0"
	icon_state_charging = "wrecharger1"
	icon_state_charged = "wrecharger2"
