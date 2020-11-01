#define RECHARGER_POWER_USAGE_GUN 250
#define RECHARGER_POWER_USAGE_MISC 200

/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	desc = "A charging dock for energy based weaponry."
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 200
	pass_flags = PASSTABLE

	var/list/allowed_devices = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/rcs, /obj/item/bodyanalyzer, /obj/item/handheld_chem_dispenser)
	var/icon_state_off = "rechargeroff"
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0"
	var/recharge_coeff = 1

	var/obj/item/charging = null // The item that is being charged
	var/using_power = FALSE // Whether the recharger is actually transferring power or not, used for icon

/obj/machinery/recharger/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	var/allowed = is_type_in_list(G, allowed_devices)

	if(allowed)
		if(anchored)
			if(charging)
				return TRUE

			//Checks to make sure he's not in space doing it, and that the area got proper power.
			var/area/a = get_area(src)
			if(!isarea(a) || !a.power_equip)
				to_chat(user, "<span class='notice'>[src] blinks red as you try to insert [G].</span>")
				return TRUE

			if(istype(G, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = G
				if(!E.can_charge)
					to_chat(user, "<span class='notice'>Your gun has no external power connector.</span>")
					return TRUE

			if(!user.drop_item())
				return TRUE
			G.forceMove(src)
			charging = G
			use_power = ACTIVE_POWER_USE
			using_power = check_cell_needs_recharging(get_cell_from(G))
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] isn't connected to anything!</span>")
		return TRUE
	return ..()

/obj/machinery/recharger/crowbar_act(mob/user, obj/item/I)
	if(panel_open && !charging && default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/recharger/screwdriver_act(mob/user, obj/item/I)
	if(anchored && !charging && default_deconstruction_screwdriver(user, "rechargeropen", "recharger0", I))
		return TRUE

/obj/machinery/recharger/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(charging)
		to_chat(user, "<span class='warning'>Remove the charging item first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE

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

	using_power = try_recharging_if_possible()
	update_icon()

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = charging
		if(E.cell)
			E.cell.emp_act(severity)

	else if(istype(charging, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = charging
		if(B.cell)
			B.cell.charge = 0
	..(severity)

/obj/machinery/recharger/power_change()
	..()
	update_icon()

/obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
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

/obj/machinery/recharger/proc/get_cell_from(obj/item/I)
	if(istype(I, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = I
		return E.cell

	if(istype(I, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = I
		return B.cell

	if(istype(I, /obj/item/rcs))
		var/obj/item/rcs/R = I
		return R.rcell

	if(istype(I, /obj/item/bodyanalyzer))
		var/obj/item/bodyanalyzer/B = I
		return B.cell

	return null

/obj/machinery/recharger/proc/check_cell_needs_recharging(obj/item/stock_parts/cell/C)
	if(!C || C.charge >= C.maxcharge)
		return FALSE
	return TRUE

/obj/machinery/recharger/proc/recharge_cell(obj/item/stock_parts/cell/C, power_usage)
	C.give(C.chargerate * recharge_coeff)
	use_power(power_usage)

/obj/machinery/recharger/proc/try_recharging_if_possible()
	var/obj/item/stock_parts/cell/C = get_cell_from(charging)
	if(!check_cell_needs_recharging(C))
		return FALSE

	if(istype(charging, /obj/item/gun/energy))
		recharge_cell(C, RECHARGER_POWER_USAGE_GUN)

		var/obj/item/gun/energy/E = charging
		E.on_recharge()
	else
		recharge_cell(C, RECHARGER_POWER_USAGE_MISC)

	return TRUE

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(charging && (!in_range(user, src) && !issilicon(user) && !isobserver(user)))
		. += "<span class='warning'>You're too far away to examine [src]'s contents and display!</span>"
		return

	if(charging)
		. += "<span class='notice'>\The [src] contains:</span>"
		. += "<span class='notice'>- \A [charging].</span>"
		if(!(stat & (NOPOWER|BROKEN)))
			var/obj/item/stock_parts/cell/C = charging.get_cell()
			. += "<span class='notice'>The status display reads:<span>"
			if(using_power)
				. += "<span class='notice'>- Recharging <b>[(C.chargerate/C.maxcharge)*100]%</b> cell charge per cycle.<span>"
			if(charging)
				. += "<span class='notice'>- \The [charging]'s cell is at <b>[C.percent()]%</b>.<span>"

// Atlantis: No need for that copy-pasta code, just use var to store icon_states instead.
/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon_state = "wrecharger0"
	icon_state_off = "wrechargeroff"
	icon_state_idle = "wrecharger0"
	icon_state_charging = "wrecharger1"
	icon_state_charged = "wrecharger2"

#undef RECHARGER_POWER_USAGE_GUN
#undef RECHARGER_POWER_USAGE_MISC
