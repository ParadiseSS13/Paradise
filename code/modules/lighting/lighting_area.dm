/area
	luminosity           = TRUE
	var/dynamic_lighting = TRUE

/area/New()
	. = ..()

	if(dynamic_lighting)
		luminosity = FALSE