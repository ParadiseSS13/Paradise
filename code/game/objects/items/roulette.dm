#define SPINNING_COOLDOWN 3 SECONDS

/obj/item/roulette
	name = "roulette"
	desc = "Normally used for giving out rewards.. or toturte methods. Use your pen to customize it and spin it by ALT-CLICK."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "roulette"
	/// Is it currently spinning?
	var/spinning = FALSE

/obj/item/roulette/AltClick()
	if(spinning)
		return
	playsound(src, 'sound/items/roulette_spin.ogg', 50, TRUE)
	icon_state = "roulette_on"
	spinning = TRUE
	addtimer(CALLBACK(src, PROC_REF(stop_spin)), SPINNING_COOLDOWN)

/obj/item/roulette/proc/stop_spin()
	atom_say("YOU WON NOTHING!")
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

#undef SPINNING_COOLDOWN
