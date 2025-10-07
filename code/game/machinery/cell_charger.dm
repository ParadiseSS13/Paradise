/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 60
	pass_flags = PASSTABLE
	var/obj/item/stock_parts/cell/charging = null
	var/chargelevel = -1
	/// Cell charge rate (Watts)
	var/charge_rate = 500

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
		charging = I
		check_level()
		update_icon(UPDATE_OVERLAYS)
		break

/obj/machinery/cell_charger/deconstruct()
	if(charging)
		charging.forceMove(drop_location())
	return ..()

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(charging)
	return ..()

/obj/machinery/cell_charger/update_overlays()
	. = ..()
	if(!charging)
		return
	. += "[charging.icon_state]"

	switch(charging.charge / charging.maxcharge)
		if(0.1 to 0.995)
			. += "cell-o1"
		if(0.995 to 1)
			. += "cell-o2"

	if(stat & (BROKEN|NOPOWER))
		return
	. += "ccharger-o[chargelevel]"

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += "There's [charging ? "a" : "no"] cell in the charger."
	if(charging)
		. += "Current charge: [round(charging.percent(), 1)]%"

/obj/machinery/cell_charger/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stock_parts/cell) && !panel_open)
		if(stat & BROKEN)
			to_chat(user, "<span class='warning'>[src] is broken!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] isn't attached to the ground!</span>")
			return ITEM_INTERACT_COMPLETE
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in the charger!</span>")
			return ITEM_INTERACT_COMPLETE
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return ITEM_INTERACT_COMPLETE
			if(!a.powernet.has_power(PW_CHANNEL_EQUIPMENT)) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>[src] blinks red as you try to insert the cell!</span>")
				return ITEM_INTERACT_COMPLETE
			if(!user.drop_item())
				return ITEM_INTERACT_COMPLETE

			used.forceMove(src)
			charging = used
			user.visible_message("[user] inserts a cell into the charger.", "<span class='notice'>You insert a cell into the charger.</span>")
			check_level()
			update_icon(UPDATE_OVERLAYS)
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/cell_charger/crowbar_act(mob/user, obj/item/I)
	if(panel_open && !charging && default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/cell_charger/screwdriver_act(mob/user, obj/item/I)
	if(anchored && !charging && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return TRUE

/obj/machinery/cell_charger/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(charging)
		to_chat(user, "<span class='warning'>Remove the cell first!</span>")
		return
	default_unfasten_wrench(user, I, 0)

/obj/machinery/cell_charger/proc/removecell()
	charging.update_icon()
	charging = null
	chargelevel = -1
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message("[user] removes [charging] from [src].", "<span class='notice'>You remove [charging] from [src].</span>")

	removecell()

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return

	charging.forceMove(loc)
	to_chat(user, "<span class='notice'>You telekinetically remove [charging] from [src].</span>")

	removecell()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return

	if(charging)
		charging.emp_act(severity)

	..(severity)

/obj/machinery/cell_charger/RefreshParts()
	charge_rate = 500
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		charge_rate *= C.rating

/obj/machinery/cell_charger/process()
	if(!charging || !anchored || (stat & (BROKEN|NOPOWER)))
		return

	if(charging.percent() >= 100)
		return

	use_power(charge_rate)
	charging.give(charge_rate)

	if(check_level())
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/cell_charger/proc/check_level()
	var/newlevel = 	round(charging.percent() * 4 / 100)
	if(chargelevel != newlevel)
		chargelevel = newlevel
		return TRUE
