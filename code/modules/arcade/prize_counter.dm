
/obj/machinery/prize_counter
	name = "Prize Counter"
	desc = "A machine which exchanges tickets for a variety of fabulous prizes!"
	icon = 'icons/obj/arcade.dmi'
	icon_state = "prize_counter-on"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 40
	/// Amount of arcade tickets in the prize counter.
	var/tickets = 0

/obj/machinery/prize_counter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/prize_counter(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/prize_counter/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/prize_counter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrizeCounter", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/prize_counter/ui_data(mob/user)
	var/list/data = list()
	data["tickets"] = tickets
	return data

/obj/machinery/prize_counter/ui_static_data(mob/user)
	var/list/static_data = list()

	var/list/prizes = list()
	for(var/datum/prize_item/prize in GLOB.global_prizes.prizes)
		var/obj/prize_item = prize.typepath
		prizes += list(list(
			"name" = initial(prize.name),
			"desc" = initial(prize.desc),
			"cost" = prize.cost,
			"icon" = prize_item.icon,
			"icon_state" = prize_item.icon_state,
			"itemID" = GLOB.global_prizes.prizes.Find(prize),
		))
	static_data["prizes"] = prizes

	return static_data

/obj/machinery/prize_counter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE

	add_fingerprint(usr)
	switch(action)
		if("purchase")
			var/itemID = text2num(params["purchase"])
			if(!GLOB.global_prizes.PlaceOrder(src, itemID))
				return
			return TRUE
		if("eject")
			print_tickets(usr)
			return TRUE

/obj/machinery/prize_counter/update_icon_state()
	if(stat & BROKEN)
		icon_state = "prize_counter-broken"
	else if(panel_open)
		icon_state = "prize_counter-open"
	else if(stat & NOPOWER)
		icon_state = "prize_counter-off"
	else
		icon_state = "prize_counter-on"

/obj/machinery/prize_counter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/tickets))
		var/obj/item/stack/tickets/T = used
		if(user.drop_item_to_ground(T))
			tickets += T.amount
			SStgui.update_uis(src)
			qdel(T)
		else
			to_chat(user, "<span class='warning'>\The [T] seems stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE
	if(panel_open)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/prize_counter/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open || !component_parts)
		return
	. = TRUE
	if(tickets)		//save the tickets!
		print_tickets()
	default_deconstruction_crowbar(user, I)

/obj/machinery/prize_counter/screwdriver_act(mob/living/user, obj/item/I)
	if(!anchored)
		return
	. = TRUE
	if(!I.use_tool(src, user, I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance panel.</span>")
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/prize_counter/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	default_unfasten_wrench(user, I, time = 6 SECONDS)

/obj/machinery/prize_counter/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/prize_counter/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/prize_counter/proc/print_tickets()
	if(tickets <= 0)
		tickets = 0 // Reset tickets to zero when trying to print a negative number
		return
	if(tickets >= 9999)
		new /obj/item/stack/tickets(get_turf(src), 9999) // Max stack size
		tickets -= 9999
	else
		new /obj/item/stack/tickets(get_turf(src), tickets)
		tickets = 0
