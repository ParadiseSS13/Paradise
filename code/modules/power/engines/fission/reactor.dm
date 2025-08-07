#define REACTOR_NEEDS_
#define REACTOR_NEEDS
#define REACTOR_NEEDS
#define REACTOR_NEEDS
#define REACTOR_NEEDS
#define REACTOR_NEEDS
#define REACTOR_NEEDS

/obj/machinery/power/fission_reactor
	name = "Nuclear Fission Reactor"
	desc = "An ancient yet reliable form of power generation utilising fissile materials to generate heat."
	icon = 'icons/goonstation/objects/reactor.dmi'
	icon_state = "reactor_off"
	anchored = TRUE
	density = TRUE
	armor = list(MELEE = 80, BULLET = 10, LASER = 50, ENERGY = 50, BOMB = 20, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	pixel_x = -16

	/// Holds the list for the connected reactor chambers to take data from
	var/list/connected_chambers = list()

/obj/machinery/power/fission_reactor/examine(mob/user)
	. = ..()
	if(!(stat & BROKEN))
		return
	. += "A burning hole where the NGCR Reactor housed its core. Its inoperable in this state. The acrid smell permeates through even the thickest of suits."
	. += ""


/obj/machinery/power/fission_reactor/examine_more(mob/user)
	. = ..()
	. += "The NGCR-5600 Nuclear Reactor was first actualized as a replacement for older, static nuclear or coal models before the discovery of supermatter harvesting techniques. \
	This reactor became widespread due to the modularity and ease of use of existing station materials, allowing it to be inserted into most stations that posessed basic engineering infrastructure."
	. += ""
	. += "However, despite the popularity of the engine, the need for frequent upkeep and higher energy demands led to innovations in newer, more advanced energy sources. \
	This engine soon became a relic of the past, but still remains a staple in many stations due to its long term reliability. According to Nanotrasen, that is."

/obj/machinery/power/fission_reactor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/multitile, list(
		list(1, MACH_CENTER, 1),
	))
	build_reactor_network()

// This shouldnt happen normally
/obj/machinery/power/fission_reactor/Destroy()
	investigate_log("was destroyed!", INVESTIGATE_REACTOR)
	clear_reactor_network()
	on = FALSE
	return ..()

/obj/machinery/power/fission_reactor/proc/build_reactor_network()
	for(var/turf/T in RECT_TURFS(1, 2, src))
		for(var/obj/machinery/reactor_chamber/chamber in T)
			if(!chamber.linked_reactor)
				chamber.form_link(src)


/obj/machinery/power/fission_reactor/proc/clear_reactor_network()
	for(var/obj/machinery/reactor_chamber/linked in connected_chambers)
		linked.linked_reactor = null
		connected_chambers -= linked
	if(length(connected_chambers))
		log_debug("clear_reactor_network ran successfully, however connected_chambers still contains items!")

/obj/machinery/power/fission_reactor/set_broken()
	overlay_state = null
	INVOKE_ASYNC(src, PROF_REF(meltdown),)
	stat |= BROKEN

/obj/machinery/power/fission_reactor/proc/meltdown()
	icon_state = "meltdown"
	sleep(1.7 SECONDS)
	icon_state = "broken"

/obj/machinery/power/fission_reactor/set_fixed
	stat &= ~BROKEN

/obj/machinery/power/fission_reactor/process()
	if(stat & BROKEN)
		return

/obj/machinery/reactor_chamber
	name = "Rod Housing Chamber"
	desc = "A chamber used to house nuclear rods of various types to facilitate a fission reaction."
	icon = 'icons/obj/fission/reactor_parts.dmi'
	icon_state = "injector"
	anchored = TRUE
	density = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	/// Each reactor chamber can only be linked to a single reactor, if somehow theres two.
	var/linked_reactor
	/// holds the specific rod inserted into the chamber
	var/held_rod

/obj/machinery/reactor_chamber/Initialize(mapload)
	. = ..()
	var/chambers_found = 0
	for(var/obj/machinery/reactor_chamber/chamber in range(0, src))
		chambers_found++
		if(chambers_found > 1)
			chamber.deconstruct()

// we only want it searching for a link when it is constructed, otherwise the reactor starts this.
/obj/machinery/reactor_chamber/on_construction()
	. = ..()
	find_link()

/// Forms the two-way link between the reactor and the chamber, then spreads it
/obj/machinery/reactor_chamber/proc/form_link(var/obj/machinery/power/fission_reactor/reactor)
	if(linked_reactor) // A check to prevent duplicates
		return
	linked_reactor = reactor
	reactor.connected_chambers += src
	spread_link(reactor)

/// Will spread the linked reactor to other nearby chambers
/obj/machinery/reactor_chamber/proc/spread_link(var/obj/machinery/power/fission_reactor/reactor)
	var/turf/nearby_turf
	var/direction = 0
	while(direction <= 8)
		direction++
		if(IS_DIR_CARDINAL(direction))
			nearby_turf = get_step(src, direction)
			for(var/obj/machinery/reactor_chamber/chamber in nearby_turf.contents)
				if(!chamber.linked_reactor)
					chamber.form_link(reactor)


/// Proc called when a chamber is first built
/obj/machinery/reactor_chamber/proc/find_link()
	var/turf/nearby_turf
	var/direction = 0
	while(direction <= 8)
		direction++
		if(IS_DIR_CARDINAL(direction))
			nearby_turf = get_step(src, direction)
			for(var/obj/machinery/power/fission_reactor/reactor in nearby_turf.contents)
				form_link(reactor)
				return
			for(var/obj/machinery/reactor_chamber/chamber in nearby_turf.contents)
				if(chamber.linked_reactor)
					linked_reactor = chamber.linked_reactor
					spread_link(linked_reactor)
					return

/obj/item/circuitboard/machine/reactor_chamber
	board_name = "Reactor Chamber"
	icon_state = "engineering"
	build_path = /obj/machinery/reactor_chamber
	board_type = "machine"
	origin_tech = "engineering=2"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/metal = 10,
		/obj/item/stack/sheet/plastitanium = 10,
	)

