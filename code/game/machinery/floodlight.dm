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
		if(cell && !cell.use(use))
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
		to_chat(user, "<span class='warning'>You remove the power cell.</span>")
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
			to_chat(user, "<span class='warning'>You try to turn on [src] but nothing happens! Seems like it <b>lacks a power cell</b>.</span>")
			return
		if(cell.charge <= 0)
			to_chat(user, "<span class='warning'>[src] hardly glows at all! Seems like the <b>power cell is empty</b>.</span>")
			return
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
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
				to_chat(user, "<span class='warning'>There is a power cell already installed.</span>")
			else
				playsound(loc, W.usesound, 50, TRUE)
				user.drop_item()
				W.loc = src
				cell = W
				to_chat(user, "<span class='notice'>You insert the power cell.</span>")
		update_icon(UPDATE_ICON_STATE)
		return
	return ..()

/obj/machinery/floodlight/screwdriver_act(mob/living/user, obj/item/I)
	if(open)
		to_chat(user, "<span class='warning'>The screws can't reach while its open.</span>")
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		return

	if(unlocked)
		to_chat(user, "<span class='notice'>You screw the battery panel in place.</span>")
	else
		to_chat(user, "<span class='notice'>You unscrew the battery panel.</span>")
	unlocked = !unlocked
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/crowbar_act(mob/living/user, obj/item/I)
	if(!unlocked)
		to_chat(user, "<span class='notice'>The cover is screwed tightly down.</span>")
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		to_chat(user, "<span class='notice'>You pry the panel closed.</span>")
	else
		to_chat(user, "<span class='notice'>You pry the panel open.</span>")
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
		. +="<span class='notice'>The panel is <b>screwed</b> shut.</span>"
	else
		if(open)
			. +="<span class='notice'>The panel is <b>pried</b> open, looks like you could fit a cell in there.</span>"
		else
			. +="<span class='notice'>The panel looks like it could be <b>pried</b> open, or <b>screwed</b> shut.</span>"
