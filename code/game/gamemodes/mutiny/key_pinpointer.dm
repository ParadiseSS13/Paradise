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
			point_at(target)
			usr << "<span class='notice'>You calibrate \the [src] to locate the Captain's Authentication Key.</span>"
		if (1)
			mode = 2
			target = mutiny.secondary_key
			usr << "<span class='notice'>You calibrate \the [src] to locate the Emergency Secondary Authentication Key.</span>"
		else
			mode = 0
			active = 0
			icon_state = "pinoff"
			usr << "<span class='notice'>You switch \the [src] off.</span>"

/obj/item/weapon/pinpointer/advpinpointer/auth_key/examine(mob/user)
	switch(mode)
		if (1)
			user << "Is is calibrated for the Captain's Authentication Key."
		if (2)
			user << "It is calibrated for the Emergency Secondary Authentication Key."
		else
			user << "It is switched off."
