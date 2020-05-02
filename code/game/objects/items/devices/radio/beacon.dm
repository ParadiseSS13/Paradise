/obj/item/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "Beacon"
	origin_tech = "bluespace=1"
	var/emagged = 0
	var/syndicate = 0
	var/area_bypass = FALSE
	var/cc_beacon = FALSE //set if allowed to teleport to even if on zlevel2

/obj/item/radio/beacon/New()
	..()
	code = "[code] ([GLOB.beacons.len + 1])"
	GLOB.beacons += src

/obj/item/radio/beacon/Destroy()
	GLOB.beacons -= src
	return ..()

/obj/item/radio/beacon/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		syndicate = 1
		to_chat(user, "<span class='notice'>The This beacon now only be locked on to by emagged teleporters!</span>")

/obj/item/radio/beacon/hear_talk()
	return


/obj/item/radio/beacon/send_hear()
	return null

/obj/item/radio/beacon/verb/alter_signal(t as text)
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

/obj/item/radio/beacon/bacon //Probably a better way of doing this, I'm lazy.

/obj/item/radio/beacon/bacon/proc/digest_delay()
	QDEL_IN(src, 600)

// SINGULO BEACON SPAWNER
/obj/item/radio/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=6;syndicate=5"
	syndicate = TRUE
	var/obj/machinery/computer/syndicate_depot/teleporter/mycomputer

/obj/item/radio/beacon/syndicate/Destroy()
	if(mycomputer)
		mycomputer.mybeacon = null
	return ..()

/obj/item/radio/beacon/syndicate/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/power/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/radio/beacon/syndicate/bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=5;syndicate=5"

/obj/item/radio/beacon/syndicate/bomb/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/syndicatebomb( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/radio/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = 1		//Let's not move these around. Some folk might get the idea to use these for assassinations
	var/list/enginetype = list()

/obj/item/radio/beacon/engine/Initialize()
	LAZYADD(GLOB.engine_beacon_list, src)

/obj/item/radio/beacon/engine/tesling
	name = "Engine Beacon for Tesla and Singularity"
	enginetype = list(ENGTYPE_TESLA, ENGTYPE_SING)

/obj/item/radio/beacon/engine/tesla
	name = "Engine Beacon for Tesla"
	enginetype = list(ENGTYPE_TESLA)

/obj/item/radio/beacon/engine/sing
	name = "Engine Beacon for Singularity"
	enginetype = list(ENGTYPE_SING)
