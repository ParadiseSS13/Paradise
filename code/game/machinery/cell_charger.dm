/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	anchored = TRUE
	idle_power_consumption = 4
	active_power_consumption = 200
	pass_flags = PASSTABLE
	var/obj/item/stock_parts/cell/cell_inside = null
	var/chargelevel = -1
	/// Charge rate multiplier.
	var/recharge_coeff = 1

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("There's [cell_inside ? "\a [cell_inside.name]" : "no cell"] in [src].")
	if(cell_inside && !(stat & (NOPOWER|BROKEN)))
		. += SPAN_NOTICE("Current charge: <b>[round(cell_inside.percent(), 1)]%</b>")
		if(cell_inside.percent() < 100)
			. += SPAN_NOTICE("- Recharging <b>[((cell_inside.chargerate * recharge_coeff) / cell_inside.maxcharge) * 100]%</b> cell charge per cycle.")

/obj/machinery/cell_charger/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cell_charger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()
	if(!mapload)
		return

	for(var/obj/item/stock_parts/cell/I in get_turf(src)) //suck any cells in at roundstart
		I.forceMove(src)
		cell_inside = I
		update_icon(UPDATE_OVERLAYS)
		break

/obj/machinery/cell_charger/deconstruct()
	if(cell_inside)
		cell_inside.forceMove(drop_location())
	return ..()

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(cell_inside)
	return ..()

/obj/machinery/cell_charger/update_overlays()
	. = ..()
	if(!cell_inside)
		return
	. += "[cell_inside.icon_state]"

	switch(cell_inside.charge / cell_inside.maxcharge)
		if(0.1 to 0.995)
			. += "cell-o1"
		if(0.995 to 1)
			. += "cell-o2"

	if(stat & (BROKEN|NOPOWER))
		return
	check_level()
	. += "ccharger-o[chargelevel]"

/obj/machinery/cell_charger/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stock_parts/cell) && !panel_open)
		if(stat & BROKEN)
			to_chat(user, SPAN_WARNING("[src] is broken!"))
			return ITEM_INTERACT_COMPLETE
		if(!anchored)
			to_chat(user, SPAN_WARNING("[src] isn't attached to the ground!"))
			return ITEM_INTERACT_COMPLETE
		if(cell_inside)
			to_chat(user, SPAN_WARNING("There is already a cell in the charger!"))
			return ITEM_INTERACT_COMPLETE
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return ITEM_INTERACT_COMPLETE
			if(!a.powernet.has_power(PW_CHANNEL_EQUIPMENT)) // There's no APC in this area, don't try to cheat power!
				to_chat(user, SPAN_WARNING("[src] blinks red as you try to insert the cell!"))
				return ITEM_INTERACT_COMPLETE
			if(!user.drop_item())
				return ITEM_INTERACT_COMPLETE

			used.forceMove(src)
			cell_inside = used
			user.visible_message("[user] inserts a cell into the charger.", SPAN_NOTICE("You insert a cell into the charger."))
			update_icon(UPDATE_OVERLAYS)
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/cell_charger/crowbar_act(mob/user, obj/item/I)
	if(panel_open && !cell_inside && default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/cell_charger/screwdriver_act(mob/user, obj/item/I)
	if(anchored && !cell_inside && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return TRUE

/obj/machinery/cell_charger/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(cell_inside)
		to_chat(user, SPAN_WARNING("Remove the cell first!"))
		return
	default_unfasten_wrench(user, I, 0)

/obj/machinery/cell_charger/proc/removecell()
	cell_inside.update_icon()
	cell_inside = null
	chargelevel = -1
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(!cell_inside)
		return

	user.put_in_hands(cell_inside)
	cell_inside.add_fingerprint(user)

	user.visible_message("[user] removes [cell_inside] from [src].", SPAN_NOTICE("You remove [cell_inside] from [src]."))

	removecell()

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!cell_inside)
		return

	cell_inside.forceMove(loc)
	to_chat(user, SPAN_NOTICE("You telekinetically remove [cell_inside] from [src]."))

	removecell()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return

	if(cell_inside)
		cell_inside.emp_act(severity)

	..(severity)

/obj/machinery/cell_charger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/cell_charger/process()
	if(!cell_inside || !anchored || (stat & (BROKEN|NOPOWER)))
		return

	if(cell_inside.percent() >= 100)
		return

	use_power(cell_inside.chargerate * recharge_coeff)
	cell_inside.give(cell_inside.chargerate * recharge_coeff)

	if(check_level())
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/cell_charger/proc/check_level()
	var/newlevel = round(cell_inside.percent() * 4 / 100)
	if(chargelevel != newlevel)
		chargelevel = newlevel
		return TRUE

/obj/machinery/cell_charger/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cell_charger(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	RefreshParts()
