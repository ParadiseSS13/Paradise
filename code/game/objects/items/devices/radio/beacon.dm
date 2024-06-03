/obj/item/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=1"
	var/syndicate = FALSE
	var/area_bypass = FALSE
	var/cc_beacon = FALSE //set if allowed to teleport to even if on zlevel2

/obj/item/radio/beacon/New()
	..()
	GLOB.beacons += src

/obj/item/radio/beacon/Destroy()
	GLOB.beacons -= src
	return ..()

/obj/item/radio/beacon/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		syndicate = TRUE
		to_chat(user, "<span class='notice'>The This beacon now only be locked on to by emagged teleporters!</span>")
		return TRUE

/obj/item/radio/beacon/hear_talk()
	return

/// Probably a better way of doing this, I'm lazy.
/obj/item/radio/beacon/bacon

/obj/item/radio/beacon/bacon/proc/digest_delay()
	QDEL_IN(src, 600)

/obj/item/radio/beacon/emagged
	syndicate = TRUE
	emagged = TRUE

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
		user.drop_item()
		qdel(src)

/obj/item/radio/beacon/syndicate/bundle
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to select a bundle</i>."
	var/list/static/bundles = list(
		"Spy" = /obj/item/storage/box/syndie_kit/bundle/spy,
		"Agent 13" = /obj/item/storage/box/syndie_kit/bundle/agent13,
		"Thief" = /obj/item/storage/box/syndie_kit/bundle/thief,
		"Agent 007" = /obj/item/storage/box/syndie_kit/bundle/bond,
		"Infiltrator" = /obj/item/storage/box/syndie_kit/bundle/infiltrator,
		"Bank Robber" = /obj/item/storage/box/syndie_kit/bundle/payday,
		"Implanter" = /obj/item/storage/box/syndie_kit/bundle/implant,
		"Hacker" = /obj/item/storage/box/syndie_kit/bundle/hacker,
		"Dark Lord" = /obj/item/storage/box/syndie_kit/bundle/darklord,
		"Sniper" = /obj/item/storage/box/syndie_kit/bundle/professional,
		"Grenadier" = /obj/item/storage/box/syndie_kit/bundle/grenadier,
		"Augmented" = /obj/item/storage/box/syndie_kit/bundle/metroid,
		"Ocelot" = /obj/item/storage/box/syndie_kit/bundle/ocelot,
		"Nuclear Wannabe" = /obj/item/storage/box/syndie_kit/bundle/operative,
		"Big Spender" = /obj/item/storage/box/syndie_kit/bundle/rich,
		"Maintenance Collector" = /obj/item/storage/box/syndie_kit/bundle/maint_loot)
	var/list/selected = list()
	var/list/unselected = list()

/obj/item/radio/beacon/syndicate/bundle/attack_self(mob/user)
	if(!user)
		return

	if(!length(selected))
		unselected = bundles.Copy()
		for(var/i in 1 to 3)
			selected += pick_n_take(unselected)
		selected += "Random"

	var/bundle_name = tgui_input_list(user, "Available Bundles", "Bundle Selection", selected)
	if(!bundle_name || QDELETED(src))
		return

	if(bundle_name == "Random")
		bundle_name = pick(unselected)
	var/bundle = bundles[bundle_name]
	bundle = new bundle(user.loc)
	to_chat(user, "<span class='notice'>Welcome to [station_name()], [bundle_name]!</span>")
	user.drop_item()
	SSblackbox.record_feedback("tally", "syndicate_bundle_pick", 1, "[bundle]")
	qdel(src)
	user.put_in_hands(bundle)

/obj/item/radio/beacon/syndicate/power_sink
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a power sink to your location</i>."

/obj/item/radio/beacon/syndicate/power_sink/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/item/powersink(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
		user.drop_item()
		qdel(src)

/obj/item/radio/beacon/syndicate/bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=5;syndicate=5"
	var/bomb = /obj/machinery/syndicatebomb

/obj/item/radio/beacon/syndicate/bomb/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new bomb(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		user.drop_item()
		qdel(src)

/obj/item/radio/beacon/syndicate/bomb/emp
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance EMP explosive to your location</i>."
	bomb = /obj/machinery/syndicatebomb/emp

/obj/item/radio/beacon/syndicate/bomb/grey_autocloner
	desc = "A label on it reads: <i>Warning: Activating this device will send an expensive cloner to your location</i>."
	origin_tech = "bluespace=2;syndicate=2"
	bomb = /obj/machinery/grey_autocloner

/obj/item/radio/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = TRUE		//Let's not move these around. Some folk might get the idea to use these for assassinations
	var/list/enginetype = list()

/obj/item/radio/beacon/engine/Initialize(mapload)
	LAZYADD(GLOB.engine_beacon_list, src)
	return ..()

/obj/item/radio/beacon/engine/Destroy()
	GLOB.engine_beacon_list -= src
	return ..()

/obj/item/radio/beacon/engine/tesling
	name = "Engine Beacon for Tesla and Singularity"
	enginetype = list(ENGTYPE_TESLA, ENGTYPE_SING)

/obj/item/radio/beacon/engine/tesla
	name = "Engine Beacon for Tesla"
	enginetype = list(ENGTYPE_TESLA)

/obj/item/radio/beacon/engine/sing
	name = "Engine Beacon for Singularity"
	enginetype = list(ENGTYPE_SING)
