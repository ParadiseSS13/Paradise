/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	desc = "A charging dock for energy based weaponry."
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 250
	var/obj/item/charging = null
	var/list/allowed_devices = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/modular_computer, /obj/item/rcs, /obj/item/bodyanalyzer)
	var/icon_state_off = "rechargeroff"
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0"

/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	if(iswrench(G))
		if(charging)
			to_chat(user, "<span class='notice'>Remove the charging item first!</span>")
			return
		anchored = !anchored
		power_change()
		to_chat(user, "<span class='notice'>You [anchored ? "attached" : "detached"] [src].</span>")
		playsound(loc, G.usesound, 75, 1)
		return

	var/allowed = is_type_in_list(G, allowed_devices)

	if(allowed)
		if(anchored)
			if(charging)
				return 1

			//Checks to make sure he's not in space doing it, and that the area got proper power.
			var/area/a = get_area(src)
			if(!isarea(a) || a.power_equip == 0)
				to_chat(user, "<span class='notice'>[src] blinks red as you try to insert [G].</span>")
				return 1

			if(istype(G, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = G
				if(!E.can_charge)
					to_chat(user, "<span class='notice'>Your gun has no external power connector.</span>")
					return 1

			if(!user.drop_item())
				return 1
			G.forceMove(src)
			charging = G
			use_power = ACTIVE_POWER_USE
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] isn't connected to anything!</span>")
		return 1
	else
		return ..()

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		return

	add_fingerprint(user)
	if(charging)
		charging.update_icon()
		charging.forceMove(loc)
		user.put_in_hands(charging)
		charging = null
		use_power = IDLE_POWER_USE
		update_icon()

/obj/machinery/recharger/attack_tk(mob/user)
	if(charging)
		charging.update_icon()
		charging.forceMove(loc)
		charging = null
		use_power = IDLE_POWER_USE
		update_icon()

/obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	var/using_power = 0
	if(charging)
		if(istype(charging, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(E.power_supply.chargerate)
				use_power(250)
				using_power = 1


		if(istype(charging, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(B.bcell.chargerate))
					use_power(200)
					using_power = 1

		if(istype(charging, /obj/item/modular_computer))
			var/obj/item/modular_computer/C = charging
			var/obj/item/computer_hardware/battery/battery_module = C.all_components[MC_CELL]
			if(battery_module)
				var/obj/item/computer_hardware/battery/B = battery_module
				if(B.battery)
					if(B.battery.charge < B.battery.maxcharge)
						B.battery.give(B.battery.chargerate)
						use_power(200)
						using_power = 1

		if(istype(charging, /obj/item/rcs))
			var/obj/item/rcs/R = charging
			if(R.rcell)
				if(R.rcell.give(R.rcell.chargerate))
					use_power(200)
					using_power = 1

		if(istype(charging, /obj/item/bodyanalyzer))
			var/obj/item/bodyanalyzer/B = charging
			if(B.power_supply)
				if(B.power_supply.give(B.power_supply.chargerate))
					use_power(200)
					using_power = 1

	update_icon(using_power)

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging,  /obj/item/gun/energy))
		var/obj/item/gun/energy/E = charging
		if(E.power_supply)
			E.power_supply.emp_act(severity)

	else if(istype(charging, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = charging
		if(B.bcell)
			B.bcell.charge = 0
	..(severity)

/obj/machinery/recharger/update_icon(using_power = 0)	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(stat & (NOPOWER|BROKEN) || !anchored)
		icon_state = icon_state_off
		return
	if(charging)
		if(using_power)
			icon_state = icon_state_charging
		else
			icon_state = icon_state_charged
		return
	icon_state = icon_state_idle

// Atlantis: No need for that copy-pasta code, just use var to store icon_states instead.
/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon_state = "wrecharger0"
	icon_state_off = "wrechargeroff"
	icon_state_idle = "wrecharger0"
	icon_state_charging = "wrecharger1"
	icon_state_charged = "wrecharger2"
