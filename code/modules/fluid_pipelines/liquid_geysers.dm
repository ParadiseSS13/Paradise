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

/obj/machinery/fluid_pipe/geyser_extractor
	name = "geyser pump"
	desc = "Extracts liquids from geysers. Consumes part of the fluid produced to keep itself running."
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "pumpjack"
	dir = EAST
	just_a_pipe = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	density = TRUE
	/// Reference to the geyser underneath the extractor
	var/obj/structure/geyser/extracting_geyser

/obj/machinery/fluid_pipe/geyser_extractor/update_icon_state()
	return

/obj/machinery/fluid_pipe/geyser_extractor/Initialize(mapload)
	. = ..()
	for(var/obj/structure/geyser/geyser in get_turf(src))
		extracting_geyser = geyser
		break

	if(QDELETED(extracting_geyser))
		deconstruct()
		return INITIALIZE_HINT_QDEL
	START_PROCESSING(SSfluid, src)

/obj/machinery/fluid_pipe/geyser_extractor/blind_connect()
	for(var/obj/structure/geyser/fluid_hole in get_turf(src))
		extracting_geyser = fluid_hole
		break
	if(QDELETED(extracting_geyser))
		return
	for(var/obj/machinery/fluid_pipe/pipe in get_step(src, dir))
		connect_pipes(pipe)
		return

/obj/machinery/fluid_pipe/geyser_extractor/special_connect_check(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(extracting_geyser))
		return TRUE

/obj/machinery/fluid_pipe/geyser_extractor/process()
	if(!fluid_datum) // This only happens if we aren't connected to a pipe
		return

	if(QDELETED(extracting_geyser))
		return

	var/amount = min(50, fluid_datum.get_empty_space())
	fluid_datum.add_fluid(extracting_geyser.liquid_to_output, amount)

/obj/machinery/fluid_pipe/geyser_extractor/attack_hand(mob/user)
	if(..())
		return
	if(dir == EAST)
		dir = WEST
	else
		dir = EAST
