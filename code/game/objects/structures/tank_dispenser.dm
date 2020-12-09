#define MAX_TANK_STORAGE	10

/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1.0
	var/starting_oxygen_tanks = MAX_TANK_STORAGE // The starting amount of oxygen tanks the dispenser gets when it's spawned
	var/starting_plasma_tanks = MAX_TANK_STORAGE // Starting amount of plasma tanks
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

/obj/structure/dispenser/Destroy()
	QDEL_LIST(stored_plasma_tanks)
	QDEL_LIST(stored_oxygen_tanks)
	return ..()

/obj/structure/dispenser/proc/initialize_tanks()
	for(var/I in 1 to starting_plasma_tanks)
		var/obj/item/tank/plasma/P = new(src)
		stored_plasma_tanks.Add(P)

	for(var/I in 1 to starting_oxygen_tanks)
		var/obj/item/tank/oxygen/O = new(src)
		stored_oxygen_tanks.Add(O)

/obj/structure/dispenser/update_icon()
	cut_overlays()
	var/oxy_tank_amount = LAZYLEN(stored_oxygen_tanks)
	switch(oxy_tank_amount)
		if(1 to 3)
			overlays += "oxygen-[oxy_tank_amount]"
		if(4 to INFINITY)
			overlays += "oxygen-4"

	var/pla_tank_amount = LAZYLEN(stored_plasma_tanks)
	switch(pla_tank_amount)
		if(1 to 4)
			overlays += "plasma-[pla_tank_amount]"
		if(5 to INFINITY)
			overlays += "plasma-5"

/obj/structure/dispenser/attack_hand(mob/user)
	if(..())
		return 1
	add_fingerprint(user)
	ui_interact(user)

/obj/structure/dispenser/attack_ghost(mob/user)
	ui_interact(user)

/obj/structure/dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "TankDispenser", name, 275, 100, master_ui, state)
		ui.open()

/obj/structure/dispenser/ui_data(user)
	var/list/data = list()
	data["o_tanks"] = LAZYLEN(stored_oxygen_tanks)
	data["p_tanks"] = LAZYLEN(stored_plasma_tanks)
	return data

/obj/structure/dispenser/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("oxygen")
			try_remove_tank(usr, stored_oxygen_tanks)

		if("plasma")
			try_remove_tank(usr, stored_plasma_tanks)

	add_fingerprint(usr)
	return TRUE

/obj/structure/dispenser/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/oxygen) || istype(I, /obj/item/tank/air) || istype(I, /obj/item/tank/anesthetic))
		try_insert_tank(user, stored_oxygen_tanks, I)
		return

	if(istype(I, /obj/item/tank/plasma))
		try_insert_tank(user, stored_plasma_tanks, I)
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

/// Called when the user clicks on the oxygen or plasma tank UI buttons, and tries to withdraw a tank.
/obj/structure/dispenser/proc/try_remove_tank(mob/living/user, list/tank_list)
	if(!LAZYLEN(tank_list))
		return // There are no tanks left to withdraw.

	var/obj/item/tank/T = tank_list[1]
	tank_list.Remove(T)

	if(!user.put_in_hands(T))
		T.forceMove(loc) // If the user's hands are full, place it on the tile of the dispenser.

	to_chat(user, "<span class='notice'>You take [T] out of [src].</span>")
	update_icon()

/// Called when the user clicks on the dispenser with a tank. Tries to insert the tank into the dispenser, and updates the UI if successful.
/obj/structure/dispenser/proc/try_insert_tank(mob/living/user, list/tank_list, obj/item/tank/T)
	if(LAZYLEN(tank_list) >= MAX_TANK_STORAGE)
		to_chat(user, "<span class='warning'>[src] is full.</span>")
		return

	if(!user.drop_item()) // Antidrop check
		to_chat(user, "<span class='warning'>[T] is stuck to your hand!</span>")
		return

	T.forceMove(src)
	tank_list.Add(T)
	update_icon()
	to_chat(user, "<span class='notice'>You put [T] in [src].</span>")
	SStgui.update_uis(src)

/obj/structure/tank_dispenser/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		for(var/X in src)
			var/obj/item/I = X
			I.forceMove(loc)
		new /obj/item/stack/sheet/metal(loc, 2)
	qdel(src)

#undef MAX_TANK_STORAGE
