/obj/machinery/space_heater
	anchored = FALSE
	density = TRUE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 100, FIRE = 80, ACID = 10)
	var/obj/item/stock_parts/cell/cell
	var/on = FALSE
	var/open = FALSE
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000

/obj/machinery/space_heater/get_cell()
	return cell

/obj/machinery/space_heater/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell(src)
	update_icon()

/obj/machinery/space_heater/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/space_heater/update_icon_state()
	icon_state = "sheater[on]"

/obj/machinery/space_heater/update_overlays()
	. = ..()
	if(open)
		. += "sheater-open"

/obj/machinery/space_heater/examine(mob/user)
	. = ..()
	. += "The heater is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"]."
	if(open)
		. += "The power cell is [cell ? "installed" : "missing"]."
	else
		. += "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
		SStgui.update_uis(src)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, "There is already a power cell inside.")
				return
			else
				// insert cell
				var/obj/item/stock_parts/cell/C = user.get_active_hand()
				if(istype(C))
					if(user.drop_item())
						cell = C
						C.forceMove(src)
						C.add_fingerprint(user)

						user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
		else
			to_chat(user, "The hatch must be open to insert a power cell.")
			return

	else
		return ..()

/obj/machinery/space_heater/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	open = !open
	if(open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	SStgui.update_uis(src)
	update_icon()

/obj/machinery/space_heater/proc/toggle_power(mob/user)
	if(!cell)
		return
	on = !on
	user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] [src].</span>")
	update_icon()
	SStgui.update_uis(src)

/obj/machinery/space_heater/attack_hand(mob/user)
	add_fingerprint(user)
	if(open)
		ui_interact(user)
	else
		toggle_power(user)

/obj/machinery/space_heater/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SpaceHeater", "Space Heater Internals", 360, 250)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/space_heater/ui_data(mob/user)
	var/list/data = list()
	data["Powercell"] = cell ? cell : FALSE
	data["CellPercent"] = cell ? round(cell.percent(),1) : 0
	data["Temp"] = set_temperature
	data["on"] = on
	data["open"] = open
	return data

/obj/machinery/space_heater/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..() || !open)
		return

	. = TRUE

	switch(action)
		if("change_temp")
			set_temperature = dd_range(0, 90, text2num(params["change_temp"]))
		if("add_cell")
			if(!open || cell)
				return
			var/obj/item/stock_parts/cell/C = usr.get_active_hand()
			if(!istype(C))
				return
			usr.drop_item()
			cell = C
			C.forceMove(src)
			C.add_fingerprint(usr)

			usr.visible_message("<span class='notice'>[usr] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
		if("remove_cell")
			if(!open || !cell || usr.get_active_hand())
				return
			on = FALSE
			cell.update_icon()
			usr.put_in_hands(cell)
			cell.add_fingerprint(usr)
			cell = null
			usr.visible_message("<span class='notice'>[usr] removes the power cell from [src].</span>", "<span class='notice'>You remove the power cell from [src].</span>")

		if("toggle_power")
			toggle_power(usr)

	if(.)
		add_fingerprint(usr)

/obj/machinery/space_heater/process()
	if(on)
		if(cell && cell.charge > 0)
			var/turf/simulated/L = loc
			if(istype(L))
				var/datum/gas_mixture/env = L.return_air()
				if(env.temperature != set_temperature + T0C)
					var/transfer_moles = 0.25 * env.total_moles()

					var/datum/gas_mixture/removed = env.remove(transfer_moles)

					if(removed)
						var/heat_capacity = removed.heat_capacity()

						if(heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
							if(removed.temperature < set_temperature + T0C)
								removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
							else
								removed.temperature = max(removed.temperature - heating_power/heat_capacity, TCMB)
							cell.use(heating_power/20000)
					env.merge(removed)
					air_update_turf()
		else
			on = FALSE
			update_icon()
