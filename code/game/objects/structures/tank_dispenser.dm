/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1.0
	var/starting_oxygen_tanks = 10 // The starting amount of oxygen tanks the dispenser gets when it's spawned
	var/starting_plasma_tanks = 10 // Starting amount of plasma tanks
	var/list/stored_oxygen_tanks = list() // List of currently stored oxygen tanks
	var/list/stored_plasma_tanks = list() // And plasma tanks

/obj/structure/dispenser/oxygen
	starting_plasma_tanks = 0

/obj/structure/dispenser/plasma
	starting_oxygen_tanks = 0

/obj/structure/dispenser/New()
	..()
	initialize_tanks()
	update_icon()

/obj/structure/dispenser/proc/initialize_tanks()
	for(var/I in 1 to starting_plasma_tanks)
		var/obj/item/tank/plasma/P = new(src)
		stored_plasma_tanks.Add(P)

	for(var/I in 1 to starting_oxygen_tanks)
		var/obj/item/tank/oxygen/O = new(src)
		stored_oxygen_tanks.Add(O)

/obj/structure/dispenser/update_icon()
	overlays.Cut()
	var/oxy_tank_amount = stored_oxygen_tanks.len
	switch(oxy_tank_amount)
		if(1 to 3)	overlays += "oxygen-[oxy_tank_amount]"
		if(4 to INFINITY) overlays += "oxygen-4"
	var/pla_tank_amount = stored_plasma_tanks.len
	switch(pla_tank_amount)
		if(1 to 4)	overlays += "plasma-[pla_tank_amount]"
		if(5 to INFINITY) overlays += "plasma-5"

/obj/structure/dispenser/attack_hand(mob/user)
	if(..())
		return 1
	add_fingerprint(user)
	ui_interact(user)

/obj/structure/dispenser/attack_ghost(mob/user)
	ui_interact(user)

/obj/structure/dispenser/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, var/master_ui = null, var/datum/topic_state/state = default_state)
	user.set_machine(src)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "tank_dispenser.tmpl", name, 275, 100, state = state)
		ui.open()

/obj/structure/dispenser/ui_data(user)
	var/list/data = list()
	data["o_tanks"] = stored_oxygen_tanks.len
	data["p_tanks"] = stored_plasma_tanks.len
	return data

/obj/structure/dispenser/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/oxygen) || istype(I, /obj/item/tank/air) || istype(I, /obj/item/tank/anesthetic))
		if(stored_oxygen_tanks.len < 10)
			user.drop_item()
			I.forceMove(src)
			stored_oxygen_tanks.Add(I)
			update_icon()
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		SSnanoui.update_uis(src)
		return
	if(istype(I, /obj/item/tank/plasma))
		if(stored_plasma_tanks.len < 10)
			user.drop_item()
			I.forceMove(src)
			stored_plasma_tanks.Add(I)
			update_icon()
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		SSnanoui.update_uis(src)
		return
	if(istype(I, /obj/item/wrench))
		if(anchored)
			to_chat(user, "<span class='notice'>You lean down and unwrench [src].</span>")
			anchored = 0
		else
			to_chat(user, "<span class='notice'>You wrench [src] into place.</span>")
			anchored = 1
		return
	return ..()

/obj/structure/dispenser/Topic(href, href_list)
	if(..())
		return TRUE

	if(Adjacent(usr))
		usr.set_machine(src)

		// The oxygen tank button
		if(href_list["oxygen"])
			if(!stored_oxygen_tanks.len) // No more tanks in the machine
				return

			var/obj/item/tank/O = stored_oxygen_tanks[1] // Get the first tank in the list
			stored_oxygen_tanks.Remove(O) // remove it from the list since we are ejecting the tank

			if(!usr.put_in_hands(O)) // Try to place it in the user's hands first
				O.forceMove(loc) // If hands are full, place it at the location of the tank dispenser
			to_chat(usr, "<span class='notice'>You take [O] out of [src].</span>")
			update_icon()

		// The plasma tank button
		if(href_list["plasma"])
			if(!stored_plasma_tanks.len)
				return

			var/obj/item/tank/P = stored_plasma_tanks[1]
			stored_plasma_tanks.Remove(P)

			if(!usr.put_in_hands(P))
				P.forceMove(loc)
			to_chat(usr, "<span class='notice'>You take [P] out of [src].</span>")
			update_icon()

		add_fingerprint(usr)
		updateUsrDialog()
		SSnanoui.update_uis(src)
	else
		SSnanoui.close_user_uis(usr,src)
	return TRUE

/obj/structure/tank_dispenser/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		for(var/X in src)
			var/obj/item/I = X
			I.forceMove(loc)
		new /obj/item/stack/sheet/metal(loc, 2)
	qdel(src)
