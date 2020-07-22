/obj/machinery/bluespace_beacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = 2.5
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	var/syndicate = 0
	var/area_bypass = FALSE
	var/obj/item/radio/beacon/Beacon
	var/enabled = TRUE
	var/cc_beacon = FALSE //can be teleported to even if on zlevel2

/obj/machinery/bluespace_beacon/New()
	..()
	create_beacon()

/obj/machinery/bluespace_beacon/proc/create_beacon()
	var/turf/T = loc
	Beacon = new /obj/item/radio/beacon
	Beacon.invisibility = INVISIBILITY_MAXIMUM
	Beacon.loc = T
	Beacon.syndicate = syndicate
	Beacon.area_bypass = area_bypass
	Beacon.cc_beacon = cc_beacon
	hide(T.intact)

/obj/machinery/bluespace_beacon/proc/destroy_beacon()
	QDEL_NULL(Beacon)

/obj/machinery/bluespace_beacon/proc/toggle()
	enabled = !enabled
	return enabled

/obj/machinery/bluespace_beacon/Destroy()
	destroy_beacon()
	return ..()

/obj/machinery/bluespace_beacon/hide(var/intact)
	invisibility = intact ? 101 : 0
	update_icon()

// update the icon_state
/obj/machinery/bluespace_beacon/update_icon()
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
			update_icon()
	else
		if(Beacon)
			destroy_beacon()
			update_icon()


/obj/machinery/bluespace_beacon/syndicate
	syndicate = TRUE
	enabled = FALSE
	area_bypass = TRUE // This enables teleports to this beacon to bypass the tele_proof flag of /area/s. Intended for depot syndi teleport computer.
	var/obj/machinery/computer/syndicate_depot/teleporter/mycomputer

/obj/machinery/bluespace_beacon/syndicate/New()
	..()
	if(!GAMEMODE_IS_NUCLEAR && prob(50))
		enabled = TRUE

/obj/machinery/bluespace_beacon/syndicate/Destroy()
	if(mycomputer)
		mycomputer.mybeacon = null
	return ..()

/obj/machinery/bluespace_beacon/syndicate/infiltrator //beacon guaranteed offline at roundstart for infiltrator base
	cc_beacon = TRUE

/obj/machinery/bluespace_beacon/syndicate/infiltrator/New()
	..()
	enabled = FALSE