/turf/simulated/floor/mech_bay_recharge_floor
	name = "Mech Bay Recharge Station"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"

/turf/simulated/floor/mech_bay_recharge_floor/airless
	icon_state = "recharge_floor_asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/obj/machinery/mech_bay_recharge_port
	name = "Mech Bay Power Port"
	density = 1
	anchored = 1
	dir = EAST
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	var/obj/mecha/recharging_mecha
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/max_charge = 50
	var/on = 0
	var/turf/recharging_turf = null

/obj/machinery/mech_bay_recharge_port/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mech_recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_recharge_turf()

/obj/machinery/mech_bay_recharge_port/proc/update_recharge_turf()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mech_recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_recharge_turf()

/obj/machinery/mech_bay_recharge_port/upgraded/unsimulated/process()
	if(!recharging_mecha)
		recharging_mecha = locate(/obj/mecha) in recharging_turf
	if(recharging_mecha && recharging_mecha.cell)
		if(recharging_mecha.cell.charge < recharging_mecha.cell.maxcharge)
			var/delta = min(max_charge, recharging_mecha.cell.maxcharge - recharging_mecha.cell.charge)
			recharging_mecha.give_power(delta)
		if(recharging_mecha.loc != recharging_turf)
			recharging_mecha = null

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/MC
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		MC += C.rating
	max_charge = MC * 25

/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return

	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/mech_bay_recharge_port/Destroy()
	if(recharge_console)
		recharge_console.recharge_port = null
		recharge_console.update_icon()
	return ..()

/obj/machinery/mech_bay_recharge_port/process()
	if(stat & NOPOWER || !recharge_console)
		return
	if(!recharging_mecha)
		recharging_mecha = locate(/obj/mecha) in recharging_turf
		if(recharging_mecha)
			recharge_console.update_icon()
	if(recharging_mecha && recharging_mecha.cell)
		if(recharging_mecha.cell.charge < recharging_mecha.cell.maxcharge)
			var/delta = min(max_charge, recharging_mecha.cell.maxcharge - recharging_mecha.cell.charge)
			recharging_mecha.give_power(delta)
			use_power(delta*150)
		else
			recharge_console.update_icon()
		if(recharging_mecha.loc != recharging_turf)
			recharging_mecha = null
			recharge_console.update_icon()


/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	density = 1
	anchored = 1
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "recharge_comp"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/mech_bay_power_console
	var/obj/machinery/mech_bay_recharge_port/recharge_port


/obj/machinery/computer/mech_bay_power_console/update_icon()
	if(!recharge_port || !recharge_port.recharging_mecha || !recharge_port.recharging_mecha.cell || !(recharge_port.recharging_mecha.cell.charge < recharge_port.recharging_mecha.cell.maxcharge) || stat & (NOPOWER|BROKEN))
		icon_screen = "recharge_comp"
	else
		icon_screen = "recharge_comp_on"
	..()

/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port)
		for(var/D in cardinal)
			var/turf/A = get_step(src, D)
			A = get_step(A, D)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in A
			if(recharge_port)
				if(!recharge_port.recharge_console)
					break
				else
					recharge_port = null
	if(recharge_port)
		if(!recharge_port.recharge_console)
			recharge_port.recharge_console = src
		else
			recharge_port = null


/obj/machinery/computer/mech_bay_power_console/Destroy()
	if(recharge_port)
		recharge_port.recharge_console = null
	return ..()

/obj/machinery/computer/mech_bay_power_console/attack_hand(mob/user as mob)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/mech_bay_power_console/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "mech_bay_console.tmpl", "Mech Bay Control Console", 500, 325)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/computer/mech_bay_power_console/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	if(!recharge_port)
		reconnect()
	if(recharge_port && !QDELETED(recharge_port))
		data["recharge_port"] = list("mech" = null)
		if(recharge_port.recharging_mecha && !QDELETED(recharge_port.recharging_mecha))
			data["recharge_port"]["mech"] = list("health" = recharge_port.recharging_mecha.health, "maxhealth" = initial(recharge_port.recharging_mecha.health), "cell" = null)
			if(recharge_port.recharging_mecha.cell && !QDELETED(recharge_port.recharging_mecha.cell))
				data["has_mech"] = 1
				data["mecha_name"] = recharge_port.recharging_mecha || "None"
				data["mecha_charge"] = isnull(recharge_port.recharging_mecha) ? 0 : recharge_port.recharging_mecha.cell.charge
				data["mecha_maxcharge"] = isnull(recharge_port.recharging_mecha) ? 0 : recharge_port.recharging_mecha.cell.maxcharge
				data["mecha_charge_percentage"] = isnull(recharge_port.recharging_mecha) ? 0 : round(recharge_port.recharging_mecha.cell.percent())
			else
				data["has_mech"] = 0

	return data

/obj/machinery/computer/mech_bay_power_console/Initialize()
	reconnect()
	update_icon()
	return ..()
