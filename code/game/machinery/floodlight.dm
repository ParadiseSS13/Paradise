/obj/machinery/floodlight
	name = "emergency floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = FALSE
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

/obj/machinery/floodlight/Initialize()
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
		if(!cell.use(use))
			on = FALSE
			update_icon(UPDATE_ICON_STATE)
			set_light(0)
			visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")

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
		to_chat(user, "You remove the power cell.")
		if(on)
			on = FALSE
			visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			set_light(0)
		update_icon(UPDATE_ICON_STATE)
		return

	if(on)
		on = FALSE
		to_chat(user, "<span class='notice'>You turn off the light.</span>")
		set_light(0)
	else
		if(!cell)
			to_chat(user, "<span class='warning'>[src] doesn't do anything! <b>seems</b> like it lacks a power cell.</span>")
			return
		if(cell.charge <= 0)
			to_chat(user, "<span class= 'warning'>[src] hardly glows at all! <b>seems</b> like the power cell is empty.</span>")
			return
		on = TRUE
		to_chat(user, "<span class='notice'>You turn on the light.</span>")
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

/obj/machinery/floodlight/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, "There is a power cell already installed.")
			else
				playsound(loc, W.usesound, 50, 1)
				user.drop_item()
				W.loc = src
				cell = W
				to_chat(user, "You insert the power cell.")
		update_icon(UPDATE_ICON_STATE)
		return
	return ..()

/obj/machinery/floodlight/screwdriver_act(mob/living/user, obj/item/I)
	if(open)
		to_chat(user, "the screws aren't long enough to reach the holes.")
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		return

	if(unlocked)
		to_chat(user, "You screw the battery panel in place.")
	else
		to_chat(user, "You unscrew the battery panel.")
	unlocked = !unlocked
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/crowbar_act(mob/living/user, obj/item/I)
	if(!unlocked)
		to_chat(user, "The cover is screwed tightly down")
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		to_chat(user, "you pry the panel closed")
		open = FALSE
	else
		to_chat(user, "you pry the panel open")
		open = TRUE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/floodlight/extinguish_light(force = FALSE)
	on = FALSE
	set_light(0)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/examine(mob/user)
	. = ..()
	if(!unlocked)
		. +="<span class='notice'>The panel is <b>screwed</b> shut."
	else
		if(open)
			. +="<span class='notice'>The panel is <b>pried</b> open, looks like you could fit a cell in there."
		else
			. +="<span class='notice'>The panel looks like it could be <b>pried</b> open, or <b>screwed</b> shut."
