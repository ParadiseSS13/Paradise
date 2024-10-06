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

/obj/machinery/fluid_pipe/geyser_extractor
	name = "geyser pump"
	desc = "Extracts liquids from geysers. Consumes part of the fluid produced to keep itself running."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "pipe-j2"
	just_a_pipe = FALSE
	/// Reference to the geyser underneath the extractor
	var/obj/structure/geyser/extracting_geyser

/obj/machinery/fluid_pipe/geyser_extractor/Initialize(mapload)
	. = ..()
	for(var/obj/structure/geyser/geyser as anything in get_turf(src))
		if(istype(geyser))
			extracting_geyser = geyser

	if(QDELETED(extracting_geyser))
		deconstruct()
		return INITIALIZE_HINT_QDEL
	START_PROCESSING(SSfluid, src)

/obj/machinery/fluid_pipe/geyser_extractor/blind_connect()
	for(var/obj/machinery/fluid_pipe/pipe in get_step(dir))
		connect_pipes(pipe)

/obj/machinery/fluid_pipe/geyser_extractor/process()
	if(!fluid_datum) // This only happens if we aren't connected to a
		return
