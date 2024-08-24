#define SPINNING_DURATION 3 SECONDS

/obj/structure/roulette
	name = "roulette"
	desc = "Normally used for giving out rewards.. or choosing torture methods."
	icon = 'icons/obj/roulette.dmi'
	icon_state = "blue"
	density = TRUE
	/// Is it currently spinning?
	var/spinning = FALSE
	/// List of options the roulette currently has
	var/list/options = list("Blue", "Orange", "Green", "Yellow", "Red", "Purple")
	/// Colors available on the roulette
	var/list/colors = list("blue", "orange", "green", "yellow", "red", "purple")

/obj/structure/roulette/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Interact to customise it and spin with <b>Alt-Click</b>.</span>"
	. += "The options are: \n[options.Join(".\n")]"

/obj/structure/roulette/AltClick()
	if(spinning)
		return
	playsound(src, 'sound/items/roulette_spin.ogg', 50, TRUE)
	icon_state = "roulette_on"
	spinning = TRUE
	addtimer(CALLBACK(src, PROC_REF(stop_spin)), SPINNING_DURATION)

/obj/structure/roulette/proc/stop_spin()
	var/chosen_number = rand(1, 6)
	atom_say(options[chosen_number])
	icon_state = colors[chosen_number]
	spinning = FALSE

/obj/structure/roulette/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, delay = 3 SECONDS, volume = I.tool_volume))
		return
	deconstruct()

/obj/structure/roulette/deconstruct()
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/wood(loc, 10)
	return ..()

/obj/structure/roulette/attack_hand(mob/user)
	var/list/radials = list("Blue" = image(icon = 'icons/obj/roulette.dmi', icon_state = colors[1]),
							"Orange" = image(icon = 'icons/obj/roulette.dmi', icon_state = colors[2]),
							"Green" = image(icon = 'icons/obj/roulette.dmi', icon_state = colors[3]),
							"Yellow" = image(icon = 'icons/obj/roulette.dmi', icon_state = colors[4]),
							"Red" = image(icon = 'icons/obj/roulette.dmi', icon_state = colors[5]),
							"Purple" = image(icon = 'icons/obj/roulette.dmi', icon_state = colors[6])
							)
	var/choice = show_radial_menu(user, src, radials, radius = 38,  custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
	switch(choice)
		if("Blue")
			options[1] = input("Customise the blue option:", name, options[1]) as text
		if("Orange")
			options[2] = input("Customise the orange option:", name, options[2]) as text
		if("Green")
			options[3] = input("Customise the green option:", name, options[3]) as text
		if("Yellow")
			options[4] = input("Customise the yellow option:", name, options[4]) as text
		if("Red")
			options[5] = input("Customise the red option:", name, options[5]) as text
		if("Purple")
			options[6] = input("Customise the purple option:", name, options[6]) as text

/obj/structure/roulette/proc/check_menu(mob/living/user)
	return (istype(user) && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))

#undef SPINNING_DURATION
