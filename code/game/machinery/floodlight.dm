/obj/machinery/floodlight
	name = "emergency floodlight"
	desc = "An artificial sun, except a lot smaller and a lot less powerful."
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = TRUE
	max_integrity = 100
	integrity_failure = 80
	light_power = 10
	var/on = FALSE
	var/obj/item/stock_parts/cell/high/cell = null
	var/use = 30
	var/unlocked = FALSE
	var/open = FALSE
	var/brightness_on = 14

/obj/machinery/floodlight/get_cell()
	return cell

/obj/machinery/floodlight/Initialize(mapload)
	. = ..()
	cell = new(src)
	mapVarInit()

/obj/machinery/floodlight/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/floodlight/update_icon_state()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"

/obj/machinery/floodlight/process()
	if(on)
		if(cell && !cell.use(use))
			on = FALSE
			update_icon(UPDATE_ICON_STATE)
			set_light(0)
			visible_message(SPAN_WARNING("[src] shuts down due to lack of power!"))

/obj/machinery/floodlight/attack_ai()
	return

/obj/machinery/floodlight/attack_hand(mob/user as mob)
	if(open && cell)
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hands(cell)
		else
			cell.loc = loc

		cell.add_fingerprint(user)
		cell.update_icon(UPDATE_ICON_STATE)

		cell = null
		to_chat(user, SPAN_WARNING("You remove the power cell."))
		if(on)
			on = FALSE
			visible_message(SPAN_WARNING("[src] shuts down due to lack of power!"))
			set_light(0)
		update_icon(UPDATE_ICON_STATE)
		return

	if(on)
		on = FALSE
		to_chat(user, SPAN_NOTICE("You turn off the light."))
		set_light(0)
	else
		if(!cell)
			to_chat(user, SPAN_WARNING("You try to turn on [src] but nothing happens! Seems like it <b>lacks a power cell</b>."))
			return
		if(cell.charge <= 0)
			to_chat(user, SPAN_WARNING("[src] hardly glows at all! Seems like the <b>power cell is empty</b>."))
			return
		if(!anchored)
			to_chat(user, SPAN_WARNING("[src] must be anchored first!"))
			return
		on = TRUE
		to_chat(user, SPAN_NOTICE("You turn on the light."))
		set_light(brightness_on)

	update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/proc/mapVarInit()
	if(on)
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		set_light(brightness_on)
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, SPAN_WARNING("There is a power cell already installed."))
			else
				playsound(loc, used.usesound, 50, TRUE)
				user.drop_item()
				used.loc = src
				cell = used
				to_chat(user, SPAN_NOTICE("You insert the power cell."))

		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/floodlight/screwdriver_act(mob/living/user, obj/item/I)
	if(open)
		to_chat(user, SPAN_WARNING("The screws can't reach while its open."))
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		return

	if(unlocked)
		to_chat(user, SPAN_NOTICE("You screw the battery panel in place."))
	else
		to_chat(user, SPAN_NOTICE("You unscrew the battery panel."))
	unlocked = !unlocked
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/crowbar_act(mob/living/user, obj/item/I)
	if(!unlocked)
		to_chat(user, SPAN_NOTICE("The cover is screwed tightly down."))
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		to_chat(user, SPAN_NOTICE("You pry the panel closed."))
	else
		to_chat(user, SPAN_NOTICE("You pry the panel open."))
	open = !open
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(anchored)
		extinguish_light()
	default_unfasten_wrench(user, I)

/obj/machinery/floodlight/extinguish_light(force = FALSE)
	on = FALSE
	set_light(0)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/examine(mob/user)
	. = ..()
	if(!unlocked)
		. +=SPAN_NOTICE("The panel is <b>screwed</b> shut.")
	else
		if(open)
			. +=SPAN_NOTICE("The panel is <b>pried</b> open, looks like you could fit a cell in there.")
		else
			. +=SPAN_NOTICE("The panel looks like it could be <b>pried</b> open, or <b>screwed</b> shut.")

/obj/machinery/floodlight/anchored
	anchored = TRUE

/obj/machinery/floodlight/anchored/darker_on
	brightness_on = 4
	light_power = 5
	light_range = 5
	on = TRUE
