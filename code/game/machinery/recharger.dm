#define RECHARGER_POWER_USAGE_GUN 250
#define RECHARGER_POWER_USAGE_MISC 200

/obj/machinery/recharger
	name = "recharger"
	icon_state = "recharger0"
	base_icon_state = "recharger"
	desc = "A charging dock for energy based weaponry."
	anchored = TRUE
	idle_power_consumption = 4
	active_power_consumption = 200
	pass_flags = PASSTABLE

	var/list/allowed_devices = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/rcs, /obj/item/bodyanalyzer, /obj/item/handheld_chem_dispenser, /obj/item/clothing/suit/armor/reactive, /obj/item/wormhole_jaunter/wormhole_weaver, /obj/item/clothing/neck/link_scryer, /obj/item/melee/secsword)
	var/recharge_coeff = 1

	var/obj/item/charging = null // The item that is being charged
	var/using_power = FALSE // Whether the recharger is actually transferring power or not, used for icon
	var/anchor_toggleable = TRUE

/obj/machinery/recharger/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/allowed = is_type_in_list(used, allowed_devices)

	if(!allowed)
		return ..()

	if(!anchored)
		to_chat(user, "<span class='notice'>[src] isn't connected to anything!</span>")
		return ITEM_INTERACT_COMPLETE
	if(panel_open)
		to_chat(user, "<span class='warning'>Close the maintenance panel first!</span>")
		return ITEM_INTERACT_COMPLETE
	if(charging)
		to_chat(user, "<span class='warning'>There's \a [charging] inserted in [src] already!</span>")
		return ITEM_INTERACT_COMPLETE

	//Checks to make sure he's not in space doing it, and that the area got proper power.
	var/area/A = get_area(src)
	if(!istype(A) || !A.powernet.has_power(PW_CHANNEL_EQUIPMENT))
		to_chat(user, "<span class='warning'>[src] blinks red as you try to insert [used].</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = used
		if(!E.can_charge)
			to_chat(user, "<span class='notice'>Your gun has no external power connector.</span>")
			return ITEM_INTERACT_COMPLETE

	if(!user.drop_item())
		return ITEM_INTERACT_COMPLETE

	used.forceMove(src)
	charging = used
	change_power_mode(ACTIVE_POWER_USE)
	using_power = check_cell_needs_recharging(get_cell_from(used))
	update_icon()

	return ITEM_INTERACT_COMPLETE

/obj/machinery/recharger/crowbar_act(mob/user, obj/item/I)
	if(panel_open && !charging && default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/recharger/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] needs to be secured down first!</span>")
		return
	if(charging)
		to_chat(user, "<span class='warning'>Remove the charging item first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	if(panel_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()

/obj/machinery/recharger/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchor_toggleable)	// Unwrenching wall rechargers and dragging them off all kinds of cursed.
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>Close the maintenance panel first!</span>")
		return
	if(charging)
		to_chat(user, "<span class='warning'>Remove the charging item first!</span>")
		return
	default_unfasten_wrench(user, I, 0)

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		return

	add_fingerprint(user)
	if(charging)
		charging.update_icon()
		charging.forceMove(loc)
		user.put_in_hands(charging)
		charging = null
		change_power_mode(IDLE_POWER_USE)
		update_icon()

/obj/machinery/recharger/attack_tk(mob/user)
	if(charging)
		charging.update_icon()
		charging.forceMove(loc)
		charging = null
		change_power_mode(IDLE_POWER_USE)
		update_icon()

/obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored || panel_open)
		return
	if(!charging)
		return

	var/old_power_state = using_power
	using_power = try_recharging_if_possible()
	if(using_power != old_power_state)
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
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()

/obj/machinery/recharger/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]open"
		return
	if(stat & (NOPOWER|BROKEN) || !anchored)
		icon_state = "[base_icon_state]off"
		return
	if(charging)
		if(using_power)
			icon_state = "[base_icon_state]1"
		else
			icon_state = "[base_icon_state]2"
		return
	icon_state = initial(icon_state)

/obj/machinery/recharger/update_overlays()
	. = ..()
	underlays.Cut()

	if((stat & NOPOWER) || panel_open)
		return

	underlays += emissive_appearance(icon, "[icon_state]_lightmask")

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

	if(istype(I, /obj/item/clothing/suit/armor/reactive))
		var/obj/item/clothing/suit/armor/reactive/A = I
		return A.cell

	if(istype(I, /obj/item/wormhole_jaunter/wormhole_weaver))
		var/obj/item/wormhole_jaunter/wormhole_weaver/W = I
		return W.wcell
	if(istype(I, /obj/item/clothing/neck/link_scryer))
		var/obj/item/clothing/neck/link_scryer/LS = I
		return LS.cell

	if(istype(I, /obj/item/melee/secsword))
		var/obj/item/melee/secsword/secsword = I
		return secsword.cell

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

	if(!check_cell_needs_recharging(C)) // we recharged cell, does it still need power? If no, recharger should blink yellow
		return FALSE

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
				. += "<span class='notice'>- Recharging <b>[((C.chargerate * recharge_coeff) / C.maxcharge) * 100]%</b> cell charge per cycle.<span>"
			if(charging)
				. += "<span class='notice'>- \The [charging]'s cell is at <b>[C.percent()]%</b>.<span>"

// Atlantis: No need for that copy-pasta code, just use var to store icon_states instead.
/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon_state = "wrecharger0"
	base_icon_state = "wrecharger"
	anchor_toggleable = FALSE

/obj/machinery/recharger/wallcharger/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	RefreshParts()

#undef RECHARGER_POWER_USAGE_GUN
#undef RECHARGER_POWER_USAGE_MISC
