/obj/item/beacon
	name = "tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	inhand_icon_state = "signaler"
	origin_tech = "bluespace=1"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL

	materials = list(MAT_METAL = 200, MAT_GLASS = 100)
	var/syndicate = FALSE
	var/area_bypass = FALSE
	var/cc_beacon = FALSE //set if allowed to teleport to even if on zlevel2
	var/wormhole_weaver = FALSE // special beacons for wormwhole weaver
	var/broadcast_to_teleport_hubs = TRUE

/obj/item/beacon/Initialize(mapload)
	. = ..()
	GLOB.beacons |= src

/obj/item/beacon/Destroy()
	GLOB.beacons -= src
	return ..()

/obj/item/beacon/emag_act(user)
	if(!emagged)
		emagged = TRUE
		syndicate = TRUE
		to_chat(user, "<span class='notice'>The This beacon now only be locked on to by emagged teleporters!</span>")
		return TRUE


/// Probably a better way of doing this, I'm lazy.
/obj/item/beacon/bacon

/obj/item/beacon/bacon/proc/digest_delay()
	QDEL_IN(src, 60 SECONDS)

/obj/item/beacon/emagged
	syndicate = TRUE
	emagged = TRUE

// SINGULO BEACON SPAWNER
/obj/item/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=6;syndicate=5"
	syndicate = TRUE
	var/obj/machinery/computer/syndicate_depot/teleporter/mycomputer

/obj/item/beacon/syndicate/Destroy()
	if(mycomputer)
		mycomputer.mybeacon = null
	return ..()

/obj/item/beacon/syndicate/attack_self__legacy__attackchain(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/power/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
		user.drop_item()
		qdel(src)

/obj/item/beacon/syndicate/bundle
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

/obj/item/beacon/syndicate/bundle/attack_self__legacy__attackchain(mob/user)
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

/obj/item/beacon/syndicate/power_sink
	desc = "A label on it reads: <i>Warning: Activating this device will send a power sink to your location</i>."

/obj/item/beacon/syndicate/power_sink/attack_self__legacy__attackchain(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/item/powersink(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
		user.drop_item()
		qdel(src)

/obj/item/beacon/syndicate/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=5;syndicate=5"
	var/bomb = /obj/machinery/syndicatebomb

/obj/item/beacon/syndicate/bomb/attack_self__legacy__attackchain(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new bomb(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
		user.drop_item()
		qdel(src)

/obj/item/beacon/syndicate/bomb/emp
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance EMP explosive to your location</i>."
	bomb = /obj/machinery/syndicatebomb/emp

/obj/item/beacon/syndicate/bomb/grey_autocloner
	desc = "A label on it reads: <i>Warning: Activating this device will send an expensive cloner to your location</i>."
	origin_tech = "bluespace=2;syndicate=2"
	bomb = /obj/machinery/grey_autocloner

/obj/item/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = TRUE		//Let's not move these around. Some folk might get the idea to use these for assassinations
	var/list/enginetype = list()

/obj/item/beacon/engine/Initialize(mapload)
	LAZYADD(GLOB.engine_beacon_list, src)
	return ..()

/obj/item/beacon/engine/Destroy()
	GLOB.engine_beacon_list -= src
	return ..()

/obj/item/beacon/engine/tesling
	name = "Engine Beacon for Tesla and Singularity"
	enginetype = list(ENGTYPE_TESLA, ENGTYPE_SING)

/obj/item/beacon/engine/tesla
	name = "Engine Beacon for Tesla"
	enginetype = list(ENGTYPE_TESLA)

/obj/item/beacon/engine/sing
	name = "Engine Beacon for Singularity"
	enginetype = list(ENGTYPE_SING)

/obj/item/beacon/wormhole_weaver
	name = "prototype beacon"
	desc = "A beacon used by a prototype wormhole device."
	wormhole_weaver = TRUE
	icon_state = "beacon_wormhole_weaver"
