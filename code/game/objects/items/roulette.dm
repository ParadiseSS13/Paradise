#define SPINNING_COOLDOWN 3 SECONDS

/obj/item/roulette
	name = "roulette"
	desc = "Normally used for giving out rewards.. or torture methods. Interact to customize it and spin it by ALT-CLICK. Max of 6 options."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "roulette"
	/// Is it currently spinning?
	var/spinning = FALSE
	/// List of custom options the roulette has
	var/list/options = list("10 credits", "20 credits", "50 credits", "100 credits", "200 credits", "500 credits")

/obj/item/roulette/examine(mob/user)
	. = ..()
	. += "The options are: \n[options.Join(".\n")]"

/obj/item/roulette/AltClick()
	if(spinning)
		return
	playsound(src, 'sound/items/roulette_spin.ogg', 50, TRUE)
	icon_state = "roulette_on"
	spinning = TRUE
	addtimer(CALLBACK(src, PROC_REF(stop_spin)), SPINNING_COOLDOWN)

/obj/item/roulette/proc/stop_spin()
	atom_say(pick(options))
	icon_state = initial(icon_state)
	spinning = FALSE

/obj/item/roulette/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, delay = 3 SECONDS, volume = I.tool_volume))
		return
	deconstruct()

/obj/item/roulette/deconstruct()
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/wood(loc, 10)
	return ..()

/obj/item/roulette/attack_hand(mob/user)
	if(in_inventory && ishuman(user))
		if(!user.get_active_hand())
			user.put_in_hands(src)
			return TRUE

	var/list/radials = list("Option 1" = image(icon = 'icons/obj/chess.dmi', icon_state = "A1"),
							"Option 2" = image(icon = 'icons/obj/chess.dmi', icon_state = "2"),
							"Option 3" = image(icon = 'icons/obj/chess.dmi', icon_state = "3"),
							"Option 4" = image(icon = 'icons/obj/chess.dmi', icon_state = "4"),
							"Option 5" = image(icon = 'icons/obj/chess.dmi', icon_state = "5"),
							"Option 6" = image(icon = 'icons/obj/chess.dmi', icon_state = "6")
							)
	var/choice = show_radial_menu(user, src, radials, radius = 38,  custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
	switch(choice)
		if("Option 1")
			options[1] = input("Option 1:", name, options[1]) as text|null
		if("Option 2")
			options[2] = input("Option 2:", name, options[2]) as text|null
		if("Option 3")
			options[3] = input("Option 3:", name, options[3]) as text|null
		if("Option 4")
			options[4] = input("Option 4:", name, options[4]) as text|null
		if("Option 5")
			options[5] = input("Option 5:", name, options[5]) as text|null
		if("Option 6")
			options[6] = input("Option 6:", name, options[6]) as text|null

/obj/item/roulette/proc/check_menu(mob/living/user)
	return (istype(user) && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))

/obj/item/roulette/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) || !Adjacent(M))
		return
	if(!ishuman(M))
		return
	if(over_object == M)
		if(!remove_item_from_storage(M))
			M.unEquip(src)
		M.put_in_hands(src)
	add_fingerprint(M)

#undef SPINNING_COOLDOWN
