/obj/item/weapon/pinpointer/advpinpointer/auth_key
	name = "\improper Authentication Key Pinpointer"
	desc = "Tracks the positions of the emergency authentication keys."
	var/datum/game_mode/mutiny/mutiny

	New()
		mutiny = ticker.mode
		..()

/obj/item/weapon/pinpointer/advpinpointer/auth_key/attack_self()
	switch(mode)
		if (0)
			mode = 1
			active = 1
			target = mutiny.captains_key
			workobj()
			usr << "\blue You calibrate \the [src] to locate the Captain's Authentication Key."
		if (1)
			mode = 2
			target = mutiny.secondary_key
			usr << "\blue You calibrate \the [src] to locate the Emergency Secondary Authentication Key."
		else
			mode = 0
			active = 0
			icon_state = "pinoff"
			usr << "\blue You switch \the [src] off."

/obj/item/weapon/pinpointer/advpinpointer/auth_key/examine()
	switch(mode)
		if (1)
			usr << "Is is calibrated for the Captain's Authentication Key."
		if (2)
			usr << "It is calibrated for the Emergency Secondary Authentication Key."
		else
			usr << "It is switched off."

/datum/supply_packs/key_pinpointer
	name = "Authentication Key Pinpointer crate"
	contains = list(/obj/item/weapon/pinpointer/advpinpointer/auth_key)
	cost = 250
	containertype = /obj/structure/closet/crate
	containername = "Authentication Key Pinpointer crate"
	access = access_heads
	group = "Operations"

	New()
		// This crate is only accessible during mutiny rounds
		if (istype(ticker.mode,/datum/game_mode/mutiny))
			..()
