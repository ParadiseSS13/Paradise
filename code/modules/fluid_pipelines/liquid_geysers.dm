/obj/structure/geyser
	name = "geyser"
	desc = "An opening for liquids to come up to the surface."
	/// The typepath of the liquid that this geyser outputs
	var/liquid_to_output

/obj/structure/geyser/examine(mob/user)
	. = ..()
	if(!liquid_to_output)
		. += "This one seems inactive."

/obj/machinery/fluid_pipe/geyser_extractor
	name = "geyser pump"
	desc = "Extracts liquids from geysers. Consumes part of the fluid produced to keep itself running."
	just_a_pipe = FALSE
