/obj/machinery/floodlight
	name = "emergency floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = FALSE
	density = TRUE
	max_integrity = 100
	integrity_failure = 80
	light_power = 20
	var/on = FALSE
	var/obj/item/stock_parts/cell/high/cell = null
	var/use = 5
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

/obj/machinery/floodlight/proc/updateicon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"

/obj/machinery/floodlight/process()
	if(!cell && on)
		on = FALSE
		visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
		update_icon()
		set_light(0)
	if(on)
		cell.charge -= use
		if(cell.charge <= 0)
			on = FALSE
			updateicon()
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
		cell.update_icon()

		cell = null
		to_chat(user, "You remove the power cell.")
		if(on)
			on = FALSE
			visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			set_light(0)
		updateicon()
		return

	if(on)
		on = FALSE
		to_chat(user, "<span class='notice'>You turn off the light.</span>")
		set_light(0)
	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		on = TRUE
		to_chat(user, "<span class='notice'>You turn on the light.</span>")
		set_light(brightness_on)

	updateicon()

/obj/machinery/floodlight/proc/mapVarInit()
	if(on)
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		set_light(brightness_on)
		updateicon()

/obj/machinery/floodlight/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/wrench))
		if(!anchored && !isinspace())
			playsound(loc, W.usesound, 50, 1)
			user.visible_message( \
				"[user] tightens \the [src]'s casters.", \
				"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
				"You hear ratchet.")
			anchored = TRUE
		else if(anchored)
			playsound(loc, W.usesound, 50, 1)
			user.visible_message( \
				"[user] loosens \the [src]'s casters.", \
				"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
				"You hear ratchet.")
			anchored = FALSE
		updateicon()
		return
	if(istype(W, /obj/item/screwdriver))
		if(!open)
			if(unlocked)
				unlocked = FALSE
				to_chat(user, "You screw the battery panel in place.")
			else
				unlocked = TRUE
				to_chat(user, "You unscrew the battery panel.")
		updateicon()
		return
	if(istype(W, /obj/item/crowbar))
		if(unlocked)
			if(open)
				open = FALSE
				overlays = null
				to_chat(user, "You crowbar the battery panel in place.")
			else
				if(unlocked)
					open = TRUE
					to_chat(user, "You remove the battery panel.")
		updateicon()
		return
	if(istype(W, /obj/item/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, "There is a power cell already installed.")
			else
				user.drop_item()
				W.loc = src
				cell = W
				to_chat(user, "You insert the power cell.")
		updateicon()
		return
	return ..()

/obj/machinery/floodlight/extinguish_light()
	on = 0
	set_light(0)
