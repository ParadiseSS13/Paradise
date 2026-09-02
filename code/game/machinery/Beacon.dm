/obj/machinery/bluespace_beacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = WIRE_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	var/syndicate = FALSE
	var/area_bypass = FALSE
	var/obj/item/beacon/Beacon
	var/enabled = TRUE
	var/cc_beacon = FALSE //can be teleported to even if on zlevel2
	var/broadcast_to_teleport_hubs = TRUE

/obj/machinery/bluespace_beacon/Initialize(mapload)
	. = ..()
	create_beacon()

/obj/machinery/bluespace_beacon/proc/create_beacon()
	var/turf/T = loc
	Beacon = new /obj/item/beacon
	Beacon.invisibility = INVISIBILITY_MAXIMUM
	Beacon.loc = T
	Beacon.syndicate = syndicate
	Beacon.area_bypass = area_bypass
	Beacon.cc_beacon = cc_beacon
	Beacon.broadcast_to_teleport_hubs = broadcast_to_teleport_hubs
	if(!T.transparent_floor)
		hide(T.intact)

/obj/machinery/bluespace_beacon/proc/destroy_beacon()
	QDEL_NULL(Beacon)

/obj/machinery/bluespace_beacon/proc/toggle()
	enabled = !enabled
	return enabled

/obj/machinery/bluespace_beacon/Destroy()
	destroy_beacon()
	return ..()

/obj/machinery/bluespace_beacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)

// update the icon_state
/obj/machinery/bluespace_beacon/update_icon_state()
	var/state="floor_beacon"
	if(invisibility)
		icon_state = "[state]f"
	else
		icon_state = "[state]"

/obj/machinery/bluespace_beacon/process()
	if(enabled)
		if(Beacon)
			if(Beacon.loc != loc)
				Beacon.loc = loc
		else
			create_beacon()
			update_icon(UPDATE_ICON_STATE)
	else
		if(Beacon)
			destroy_beacon()
			update_icon(UPDATE_ICON_STATE)


/obj/machinery/bluespace_beacon/syndicate
	syndicate = TRUE
	enabled = FALSE
	area_bypass = TRUE // This enables teleports to this beacon to bypass the tele_proof flag of /area/s. Intended for depot syndi teleport computer.
	var/obj/machinery/computer/syndicate_depot/teleporter/mycomputer

/obj/machinery/bluespace_beacon/syndicate/Initialize(mapload)
	. = ..()
	if(!GAMEMODE_IS_NUCLEAR && prob(50))
		enabled = TRUE

/obj/machinery/bluespace_beacon/syndicate/Destroy()
	if(mycomputer)
		mycomputer.mybeacon = null
	return ..()

/// beacon guaranteed offline at roundstart for infiltrator base
/obj/machinery/bluespace_beacon/syndicate/infiltrator
	cc_beacon = TRUE

/obj/machinery/bluespace_beacon/syndicate/infiltrator/Initialize(mapload)
	. = ..()
	enabled = FALSE


/obj/structure/broken_bluespace_beacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon_broken"
	name = "Broken Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon. Seems this has broken down."
	level = 1		// underfloor
	layer = WIRE_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
