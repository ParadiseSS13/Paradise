/obj/structure/geyser
	name = "geyser"
	desc = "An opening for liquids to come up to the surface."
	icon = 'icons/obj/lavaland/geyser.dmi'
	icon_state = "geyser_acid"
	/// The typepath of the liquid that this geyser outputs
	var/liquid_to_output

/obj/structure/geyser/examine(mob/user)
	. = ..()
	if(!liquid_to_output)
		. += "This one seems inactive."

/obj/structure/geyser/plasma
	name = "raw plasma geyser"
	liquid_to_output = /datum/fluid/raw_plasma

/obj/structure/geyser/water
	name = "water geyser"
	liquid_to_output = /datum/fluid/water

/obj/structure/geyser/brine
	name = "brine geyser"
	liquid_to_output = /datum/fluid/brine

/obj/structure/geyser/oil
	name = "oil geyser"
	liquid_to_output = /datum/fluid/oil

/obj/machinery/fluid_pipe/pumpjack
	name = "pumpjack"
	desc = "Extracts liquids from geysers. Consumes part of the fluid produced to keep itself running."
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "pumpjack"
	dir = EAST
	just_a_pipe = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	/// Reference to the geyser underneath the extractor
	var/obj/structure/geyser/extracting_geyser

/obj/machinery/fluid_pipe/pumpjack/update_icon_state()
	return

/obj/machinery/fluid_pipe/pumpjack/Initialize(mapload)
	. = ..()
	connect_dirs = list(dir)
	for(var/obj/structure/geyser/geyser in get_turf(src))
		extracting_geyser = geyser
		break

	if(QDELETED(extracting_geyser))
		deconstruct()
		return INITIALIZE_HINT_QDEL
	START_PROCESSING(SSfluid, src)

/obj/machinery/fluid_pipe/pumpjack/blind_connect()
	for(var/obj/structure/geyser/fluid_hole in get_turf(src))
		extracting_geyser = fluid_hole
		break
	if(QDELETED(extracting_geyser))
		return
	for(var/obj/machinery/fluid_pipe/pipe in get_step(src, dir))
		connect_pipes(pipe)
		return

/obj/machinery/fluid_pipe/pumpjack/special_connect_check(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(extracting_geyser))
		return TRUE

/obj/machinery/fluid_pipe/pumpjack/process()
	if(!fluid_datum) // This only happens if we aren't connected to a pipe
		return

	if(QDELETED(extracting_geyser))
		return

	var/amount = min(50, fluid_datum.get_empty_space())
	fluid_datum.add_fluid(extracting_geyser.liquid_to_output, amount)

/obj/machinery/fluid_pipe/pumpjack/attack_hand(mob/user)
	if(..())
		return
	if(dir == EAST)
		dir = WEST
	else
		dir = EAST
