/obj/item/device/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "Beacon"
	origin_tech = "bluespace=1"
	var/emagged = 0
	var/syndicate = 0

/obj/item/device/radio/beacon/New()
	..()
	code = "[code] ([beacons.len + 1])"
	beacons += src

/obj/item/device/radio/beacon/Destroy()
	beacons -= src
	return ..()

/obj/item/device/radio/beacon/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		syndicate = 1
		to_chat(user, "\blue The This beacon now only be locked on to by emagged teleporters!")

/obj/item/device/radio/beacon/hear_talk()
	return


/obj/item/device/radio/beacon/send_hear()
	return null

/obj/item/device/radio/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	code = t
	if(isnull(code))
		code = initial(code)
	src.add_fingerprint(usr)
	return

/obj/item/device/radio/beacon/bacon //Probably a better way of doing this, I'm lazy.
	proc/digest_delay()
		spawn(600)
			qdel(src)

// SINGULO BEACON SPAWNER
/obj/item/device/radio/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"
	syndicate = 1

/obj/item/device/radio/beacon/syndicate/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "\blue Locked In")
		new /obj/machinery/power/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/device/radio/beacon/syndicate/bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/device/radio/beacon/syndicate/bomb/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "\blue Locked In")
		new /obj/machinery/syndicatebomb( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return