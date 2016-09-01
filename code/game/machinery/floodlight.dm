//these are probably broken

/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = 0
	density = 1
	var/on = 0
	var/obj/item/weapon/stock_parts/cell/high/cell = null
	var/use = 5
	var/unlocked = 0
	var/open = 0
	var/brightness_on = 14
	light_power = 20
	//var/brightness_on = 999		//can't remember what the maxed out value is //Lighting overhaul: No max, stop TRYING TO ILLUMINATE MORE TILES THAN THE MAP CONSISTS OF.

/obj/machinery/floodlight/New()
	src.cell = new(src)
	..()

/obj/machinery/floodlight/Destroy()
	if(cell)
		qdel(cell)
		cell = null
	return ..()

/obj/machinery/floodlight/proc/updateicon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"

/obj/machinery/floodlight/process()
	if(on)
		cell.charge -= use
		if(cell.charge <= 0)
			on = 0
			updateicon()
			set_light(0)
			src.visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			return

/obj/machinery/floodlight/attack_ai(mob/user as mob)
	return

/obj/machinery/floodlight/attack_hand(mob/user as mob)
	if(open && cell)
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hands(cell)
		else
			cell.loc = loc

		cell.add_fingerprint(user)
		cell.updateicon()

		src.cell = null
		to_chat(user, "You remove the power cell")
		updateicon()
		return

	if(on)
		on = 0
		to_chat(user, "\blue You turn off the light")
		set_light(0)
	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		on = 1
		to_chat(user, "\blue You turn on the light")
		set_light(brightness_on)

	updateicon()


/obj/machinery/floodlight/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message( \
				"[user] tightens \the [src]'s casters.", \
				"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
				"You hear ratchet.")
			anchored = 1
		else if(anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message( \
				"[user] loosens \the [src]'s casters.", \
				"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
				"You hear ratchet.")
			anchored = 0
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!open)
			if(unlocked)
				unlocked = 0
				to_chat(user, "You screw the battery panel in place.")
			else
				unlocked = 1
				to_chat(user, "You unscrew the battery panel.")

	if(istype(W, /obj/item/weapon/crowbar))
		if(unlocked)
			if(open)
				open = 0
				overlays = null
				to_chat(user, "You crowbar the battery panel in place.")
			else
				if(unlocked)
					open = 1
					to_chat(user, "You remove the battery panel.")

	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, "There is a power cell already installed.")
			else
				user.drop_item()
				W.loc = src
				cell = W
				to_chat(user, "You insert the power cell.")
	updateicon()
