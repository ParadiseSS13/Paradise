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
			to_chat(usr, "\blue You calibrate \the [src] to locate the Captain's Authentication Key.")
		if (1)
			mode = 2
			target = mutiny.secondary_key
			to_chat(usr, "\blue You calibrate \the [src] to locate the Emergency Secondary Authentication Key.")
		else
			mode = 0
			active = 0
			icon_state = "pinoff"
			to_chat(usr, "\blue You switch \the [src] off.")

/obj/item/weapon/pinpointer/advpinpointer/auth_key/examine(mob/user)
	switch(mode)
		if (1)
			to_chat(user, "Is is calibrated for the Captain's Authentication Key.")
		if (2)
			to_chat(user, "It is calibrated for the Emergency Secondary Authentication Key.")
		else
			to_chat(user, "It is switched off.")
