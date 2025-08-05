/obj/machinery/space_heater
	name = "space heater"
	desc = "A free-standing mobile space heater for heating rooms, featuring a temperature adjustment dial and an easy-swap power cell holder which are hidden behind a screwed-on panel."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater0"
	density = TRUE
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 100, FIRE = 80, ACID = 10)
	var/obj/item/stock_parts/cell/cell
	var/on = FALSE
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000

/obj/machinery/space_heater/get_cell()
	return cell

/obj/machinery/space_heater/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/space_heater(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/cell(null)
	RefreshParts()
	update_icon()
	return

/obj/machinery/space_heater/RefreshParts()
	cell = null
	for(var/obj/item/stock_parts/cell/P in component_parts)
		cell = P
		return

/obj/machinery/space_heater/deconstruct(disassembled)
	if(cell)
		cell.forceMove(loc)
		cell = null
	return ..()

/obj/machinery/space_heater/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/space_heater/update_icon_state()
	icon_state = "sheater[on]"

/obj/machinery/space_heater/update_overlays()
	. = ..()
	if(panel_open)
		. += "sheater-open"

/obj/machinery/space_heater/examine(mob/user)
	. = ..()
	. += "The heater is [on ? "on" : "off"] and the hatch is [panel_open ? "open" : "closed"]."
	if(panel_open)
		. += "The power cell is [cell ? "installed" : "missing"]."
	else
		. += "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/stock_parts/cell))
		return ..()

	if(!panel_open)
		to_chat(user, "The hatch must be open to insert a power cell.")
		return ITEM_INTERACT_COMPLETE

	if(cell)
		to_chat(user, "There is already a power cell inside.")
		return ITEM_INTERACT_COMPLETE

	// insert cell
	var/obj/item/stock_parts/cell/C = used
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE

	component_parts += C
	RefreshParts()
	cell.forceMove(src)
	C.add_fingerprint(user)
	user.visible_message(
		"<span class='notice'>[user] inserts a power cell into [src].</span>",
		"<span class='notice'>You insert the power cell into [src].</span>"
	)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/space_heater/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	panel_open = !panel_open
	if(panel_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		on = FALSE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()
	if(!panel_open && user.machine == src)
		user << browse(null, "window=spaceheater")
		user.unset_machine()

/obj/machinery/space_heater/crowbar_act(mob/living/user, obj/item/I)
	if(panel_open && !on && default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/space_heater/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 0)
	return TRUE	

/obj/machinery/space_heater/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/space_heater/interact(mob/user as mob)
	if(panel_open)
		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<a href='byond://?src=[UID()];op=cellremove'>Installed</a><br>"
		else
			dat += "<a href='byond://?src=[UID()];op=cellinstall'>Removed</a><br>"

		dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<br><br>"

		dat += "Set Temperature: "

		dat += "<a href='byond://?src=[UID()];op=temp;val=-5'>-</a>"

		dat += " [set_temperature]&deg;C "
		dat += "<a href='byond://?src=[UID()];op=temp;val=5'>+</a><br>"

		user.set_machine(src)
		user << browse("<!DOCTYPE html><meta charset='utf-8'><head><title>Space Heater Control Panel</title></head><tt>[dat]</tt>", "window=spaceheater")
		onclose(user, "spaceheater")

	else
		on = !on
		user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] [src].</span>")
		update_icon()
	return

/obj/machinery/space_heater/Topic(href, href_list)
	if(..())
		return TRUE

	if((in_range(src, usr) && isturf(src.loc)) || (issilicon(usr)))
		usr.set_machine(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 20-90 degC
				set_temperature = dd_range(0, 90, set_temperature + value)

			if("cellremove")
				if(panel_open && cell && !usr.get_active_hand())
					cell.update_icon()
					cell.forceMove(loc)
					if(Adjacent(usr) && !issilicon(usr))
						usr.put_in_hands(cell)
					cell.add_fingerprint(usr)
				for(var/obj/item/stock_parts/cell/C in component_parts)
					component_parts -= C
				cell = null
				RefreshParts()
				usr.visible_message(
					"<span class='notice'>[usr] removes the power cell from [src].</span>",
					"<span class='notice'>You remove the power cell from [src].</span>"
					)

			if("cellinstall")
				if(panel_open && !cell)
					var/obj/item/stock_parts/cell/C = usr.get_active_hand()
					if(istype(C))
						if(usr.drop_item())
							component_parts += C
							RefreshParts()
							C.forceMove(src)
							C.add_fingerprint(usr)

							usr.visible_message(
								"<span class='notice'>[usr] inserts a power cell into [src].</span>",
								"<span class='notice'>You insert the power cell into [src].</span>"
								)
						else
							to_chat(usr, "<span class='warning'>[C] is stuck to your hand!</span>")

		updateDialog()
	else
		usr << browse(null, "window=spaceheater")
		usr.unset_machine()
	return

/obj/machinery/space_heater/process()
	var/datum/milla_safe/space_heater_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/space_heater_process

/datum/milla_safe/space_heater_process/on_run(obj/machinery/space_heater/heater)
	if(heater.on)
		if(heater.cell && heater.cell.charge > 0)
			var/turf/simulated/L = get_turf(heater)
			if(!istype(L))
				return
			var/datum/gas_mixture/env = get_turf_air(L)
			if(env.temperature() == heater.set_temperature + T0C)
				return
			var/transfer_moles = 0.25 * env.total_moles()

			var/datum/gas_mixture/removed = env.remove(transfer_moles)

			if(!removed)
				return
			var/heat_capacity = removed.heat_capacity()

			if(heat_capacity)
				if(removed.temperature() < heater.set_temperature + T0C)
					removed.set_temperature(min(removed.temperature() + heater.heating_power / heat_capacity, 1000))
				else
					removed.set_temperature(max(removed.temperature() - heater.heating_power / heat_capacity, TCMB))
				heater.cell.use(heater.heating_power / 20000)
			env.merge(removed)
		else
			heater.on = FALSE
			heater.update_icon()
