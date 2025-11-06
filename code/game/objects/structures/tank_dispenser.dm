#define MAX_TANK_STORAGE	10

/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	var/starting_oxygen_tanks = MAX_TANK_STORAGE // The starting amount of oxygen tanks the dispenser gets when it's spawned
	var/starting_plasma_tanks = MAX_TANK_STORAGE // Starting amount of plasma tanks
	var/list/stored_oxygen_tanks = list() // List of currently stored oxygen tanks
	var/list/stored_plasma_tanks = list() // And plasma tanks

/obj/structure/dispenser/oxygen
	starting_plasma_tanks = 0

/obj/structure/dispenser/plasma
	starting_oxygen_tanks = 0

/obj/structure/dispenser/Initialize(mapload)
	. = ..()
	initialize_tanks()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/dispenser/Destroy()
	QDEL_LIST_CONTENTS(stored_plasma_tanks)
	QDEL_LIST_CONTENTS(stored_oxygen_tanks)
	return ..()

/obj/structure/dispenser/proc/initialize_tanks()
	for(var/I in 1 to starting_plasma_tanks)
		var/obj/item/tank/internals/plasma/P = new(src)
		stored_plasma_tanks.Add(P)

	for(var/I in 1 to starting_oxygen_tanks)
		var/obj/item/tank/internals/oxygen/O = new(src)
		stored_oxygen_tanks.Add(O)

/obj/structure/dispenser/update_overlays()
	. = ..()
	var/oxy_tank_amount = LAZYLEN(stored_oxygen_tanks)
	switch(oxy_tank_amount)
		if(1 to 3)
			. += "oxygen-[oxy_tank_amount]"
		if(4 to INFINITY)
			. += "oxygen-4"

	var/pla_tank_amount = LAZYLEN(stored_plasma_tanks)
	switch(pla_tank_amount)
		if(1 to 4)
			. += "plasma-[pla_tank_amount]"
		if(5 to INFINITY)
			. += "plasma-5"

/obj/structure/dispenser/attack_hand(mob/user)
	if(..())
		return 1
	add_fingerprint(user)
	ui_interact(user)

/obj/structure/dispenser/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can use it, but not the AI
		attack_hand(user)

/obj/structure/dispenser/attack_ghost(mob/user)
	ui_interact(user)

/obj/structure/dispenser/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/dispenser/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TankDispenser", name)
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

/obj/structure/dispenser/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/tank/internals/oxygen) || istype(I, /obj/item/tank/internals/air) || istype(I, /obj/item/tank/internals/anesthetic))
		try_insert_tank(user, stored_oxygen_tanks, I)
		return ITEM_INTERACT_COMPLETE

	if(istype(I, /obj/item/tank/internals/plasma))
		try_insert_tank(user, stored_plasma_tanks, I)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/structure/dispenser/wrench_act(mob/living/user, obj/item/I)
	I.play_tool_sound(src, 50)
	if(anchored)
		to_chat(user, "<span class='notice'>You lean down and unwrench [src].</span>")
		anchored = FALSE
	else
		to_chat(user, "<span class='notice'>You wrench [src] into place.</span>")
		anchored = TRUE
	return TRUE


/// Called when the user clicks on the oxygen or plasma tank UI buttons, and tries to withdraw a tank.
/obj/structure/dispenser/proc/try_remove_tank(mob/living/user, list/tank_list)
	if(!LAZYLEN(tank_list))
		return // There are no tanks left to withdraw.

	var/obj/item/tank/internals/T = tank_list[1]
	tank_list.Remove(T)

	if(!user.put_in_hands(T))
		T.forceMove(loc) // If the user's hands are full, place it on the tile of the dispenser.

	to_chat(user, "<span class='notice'>You take [T] out of [src].</span>")
	update_icon(UPDATE_OVERLAYS)

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
	update_icon(UPDATE_OVERLAYS)
	to_chat(user, "<span class='notice'>You put [T] in [src].</span>")
	SStgui.update_uis(src)

/obj/structure/dispenser/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		for(var/X in src)
			var/obj/item/I = X
			I.forceMove(loc)
		new /obj/item/stack/sheet/metal(loc, 2)
	qdel(src)

#undef MAX_TANK_STORAGE
