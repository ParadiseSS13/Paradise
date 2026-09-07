#define LITER_PRICE 1
#define NOZZLE_RANGE 4

/obj/machinery/fuel_pump
	name = "fuel pump"
	desc = "A tank full of industrial welding fuel. Do not consume."
	icon = 'icons/obj/spacepods/gas_station.dmi'
	icon_state = "spacegas"
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER

	var/balance = 0
	var/target_fuel = 0

	var/obj/item/nozzle/nozzle
	var/datum/beam/current_beam

/obj/machinery/fuel_pump/update_icon_state()
	icon_state = "[initial(icon_state)]"
	if(stat & BROKEN)
		icon_state += "-broken"
	else if(stat & NOPOWER)
		icon_state += "-off"
	return ..()

/obj/machinery/fuel_pump/Initialize(mapload)
	. = ..()
	nozzle = new(src)
	update_icon()

/obj/machinery/fuel_pump/update_overlays()
	. = ..()

	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return

	if(panel_open)
		return

	underlays += emissive_appearance(icon, "spacegas-light-mask", src, alpha = alpha)

/obj/machinery/fuel_pump/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()

/obj/machinery/fuel_pump/update_appearance(updates=ALL)
	. = ..()
	set_light((!(stat & BROKEN|NOPOWER)) ? MINIMUM_USEFUL_LIGHT_RANGE : 0)

/obj/machinery/fuel_pump/Destroy()
	QDEL_NULL(nozzle)
	QDEL_NULL(current_beam)
	. = ..()

/obj/machinery/fuel_pump/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<i>Alt-Click</i> to remove the pump nozzle.")
	. += SPAN_GREEN("Has [balance] credits on [name] balance.")
	. += SPAN_GREEN("[LITER_PRICE] credits for 1 liter of liquid plasma fuel!")

/obj/machinery/fuel_pump/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == nozzle)
		nozzle.snap_back(user)
		return ITEM_INTERACT_COMPLETE

	if(istype(tool, /obj/item/card/id))
		var/obj/item/card/id/id = tool
		var/datum/money_account/account = id.get_card_account()
		if(account.try_withdraw_credits(50))
			balance += 50
			to_chat(user, SPAN_NOTICE("50 credits deposited."))
		else
			to_chat(user, SPAN_NOTICE("Less than 50 credits available in account."))

		return ITEM_INTERACT_COMPLETE

	return NONE

/obj/machinery/fuel_pump/AltClick(mob/user, modifiers)
	if(nozzle.loc != src)
		return

	if(!user.put_in_active_hand(nozzle))
		return

	current_beam = user.Beam(
		src,
		"hose",
		'icons/obj/spacepods/beam.dmi',
		time = INFINITY,
	)

	return

/obj/machinery/fuel_pump/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/fuel_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FuelTank", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/fuel_pump/ui_data(mob/user)
	var/list/data = list()
	data["balance"] = balance
	data["fuel"] = round(target_fuel)
	data["maxfuel"] = round(balance)
	data["price"] = LITER_PRICE

	return data

/obj/machinery/fuel_pump/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("fuel")
			var/pressure = params["fuel"]
			if(pressure == "max")
				pressure = balance
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_fuel = clamp(pressure, 0, balance)

/obj/machinery/fuel_pump/proc/detach_nozzle()
	nozzle = null

	QDEL_NULL(current_beam)

/obj/item/nozzle
	name = "fuel hose"
	desc = "A device help to transport fuel."
	icon = 'icons/obj/spacepods/gas_station.dmi'
	icon_state = "spacegas-pistol-unhands"
	inhand_icon_state = "atropen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	new_attack_chain = TRUE
	var/obj/machinery/fuel_pump/tank

/obj/item/nozzle/Destroy(force)
	. = ..()

	if(tank)
		tank.detach_nozzle()
		tank = null

/obj/item/nozzle/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/tgvehicle/sealed/vectorcraft/spacepod))
		var/obj/tgvehicle/sealed/vectorcraft/spacepod/pod = target
		if(tank.balance == 0)
			to_chat(user, SPAN_WARNING("You haven't added any credit balance to the fuel pump!"))
			return ITEM_INTERACT_COMPLETE
		if(tank.target_fuel == 0)
			to_chat(user, SPAN_WARNING("The fuel pump is empty!"))
			return ITEM_INTERACT_COMPLETE
		if(pod.pod_fueltank.reagents.has_reagent("plasma", pod.max_fuel))
			to_chat(user, SPAN_WARNING("Your [name] is already full!"))
			return ITEM_INTERACT_COMPLETE
		if(do_after(user, 60, target = user))
			tank.balance -= tank.target_fuel
			pod.pod_fueltank.reagents.add_reagent("plasma", tank.target_fuel)
			user.visible_message(
				SPAN_NOTICE("[user] refills [user.p_their()] [name]."),
				SPAN_NOTICE("You refill [src]."),
			)
			playsound(src, 'sound/effects/refill.ogg', 40, TRUE)
			return ITEM_INTERACT_COMPLETE

/obj/item/nozzle/proc/snap_back(mob/user)
	if(!tank)
		return

	if(user.l_hand == src)
		user.drop_l_hand(force = TRUE)
	else if(user.r_hand == src)
		user.drop_r_hand(force = TRUE)

	forceMove(tank)
	qdel(tank.current_beam)

/obj/item/nozzle/proc/check_range()
	SIGNAL_HANDLER // COMSIG_MOVABLE_MOVED

	if(!tank)
		return

	if(get_dist(src, tank) > NOZZLE_RANGE)
		if(isliving(loc))
			var/mob/living/user = loc
			to_chat(user, SPAN_WARNING("[tank]'s hose overextends and snaps back into [tank]!"))
			snap_back(user)
		else
			visible_message(SPAN_NOTICE("[src] snap back into [tank]."))

/obj/item/nozzle/Initialize(mapload)
	. = ..()

	if(!loc || !istype(loc, /obj/machinery/fuel_pump))
		return INITIALIZE_HINT_QDEL

	tank = loc

/obj/item/nozzle/can_enter_storage(obj/item/storage/S, mob/user)
	return FALSE

/obj/item/nozzle/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	to_chat(user, SPAN_NOTICE("The hose snaps back into the tank."))
	snap_back(user)

/obj/item/nozzle/equipped(mob/user, slot)
	. = ..()

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

/obj/item/nozzle/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()

	check_range()

#undef LITER_PRICE
#undef NOZZLE_RANGE
