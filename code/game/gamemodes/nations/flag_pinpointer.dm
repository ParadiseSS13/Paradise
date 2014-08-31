/obj/item/weapon/pinpointer/advpinpointer/flag
	name = "\improper Flag Pinpointer"
	desc = "Tracks the position of every nation's flag."

/obj/item/weapon/pinpointer/advpinpointer/flag/attack_self()
	switch(mode)
		if (0)
			mode = 1
			active = 1
			target = locate(/obj/item/flag/nation/atmos)
			workobj()
			usr << "\blue You calibrate \the [src] to locate the [target.name]"
		if (1)
			mode = 2
			target = locate(/obj/item/flag/nation/sec)
			usr << "\blue You calibrate \the [src] to locate the [target.name]"
		if (2)
			mode = 3
			target = locate(/obj/item/flag/nation/cargo)
			usr << "\blue You calibrate \the [src] to locate the [target.name]"
		if (3)
			mode = 4
			target = locate(/obj/item/flag/nation/command)
			usr << "\blue You calibrate \the [src] to locate the [target.name]"
		if (4)
			mode = 5
			target = locate(/obj/item/flag/nation/med)
			usr << "\blue You calibrate \the [src] to locate the [target.name]"
		if (5)
			mode = 6
			target = locate(/obj/item/flag/nation/rnd)
			usr << "\blue You calibrate \the [src] to locate the [target.name]"
		else
			mode = 0
			active = 0
			icon_state = "pinoff"
			usr << "\blue You switch \the [src] off."

/obj/item/weapon/pinpointer/advpinpointer/flag/examine()
	switch(mode)
		if (1)
			usr << "Is is calibrated for the [target.name]"
		if (2)
			usr << "Is is calibrated for the [target.name]"
		if (3)
			usr << "Is is calibrated for the [target.name]"
		if (4)
			usr << "Is is calibrated for the [target.name]"
		if (5)
			usr << "Is is calibrated for the [target.name]"
		else
			usr << "It is switched off."

/datum/supply_packs/key_pinpointer_nations
	name = "Nations Flag Pinpointer crate"
	contains = list(/obj/item/weapon/pinpointer/advpinpointer/flag)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Nations Flag Pinpointer crate"
	access = access_heads
	group = "Operations"

	New()
		if (istype(ticker.mode,/datum/game_mode/nations))
			..()
