
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

/obj/machinery/prize_counter/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/prize_counter)
	)

/obj/machinery/prize_counter/ui_data(mob/user)
	var/list/data = list()
	data["tickets"] = tickets
	return data

/obj/machinery/prize_counter/ui_static_data(mob/user)
	var/list/static_data = list()

	var/list/prizes = list()
	for(var/datum/prize_item/prize in GLOB.global_prizes.prizes)
		prizes += list(list(
			"name" = initial(prize.name),
			"desc" = initial(prize.desc),
			"cost" = prize.cost,
			"itemID" = GLOB.global_prizes.prizes.Find(prize),
			"imageID" = replacetext(replacetext("[prize.typepath]", "/obj/item/", ""), "/", "-"),
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

/obj/machinery/prize_counter/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/tickets))
		var/obj/item/stack/tickets/T = O
		if(user.unEquip(T))		//Because if you can't drop it for some reason, you shouldn't be increasing the tickets var
			tickets += T.amount
			SStgui.update_uis(src)
			qdel(T)
		else
			to_chat(user, "<span class='warning'>\The [T] seems stuck to your hand!</span>")
		return
	if(panel_open)
		if(istype(O, /obj/item/wrench))
			default_unfasten_wrench(user, O, time = 6 SECONDS)
		if(component_parts && istype(O, /obj/item/crowbar))
			if(tickets)		//save the tickets!
				print_tickets()
			default_deconstruction_crowbar(user, O)
		return

	return ..()

/obj/machinery/prize_counter/screwdriver_act(mob/living/user, obj/item/I)
	if(!anchored)
		return
	I.play_tool_sound(src)
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance panel.</span>")
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/prize_counter/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/prize_counter/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/prize_counter/proc/print_tickets()
	if(tickets >= 9999)
		new /obj/item/stack/tickets(get_turf(src), 9999)	//max stack size
		tickets -= 9999
	else
		new /obj/item/stack/tickets(get_turf(src), tickets)
		tickets = 0
