/obj/machinery/big
	/// A list that represents a 5x5 grid. 1 for a filler, 0 for no filler.
	/// This explicitly uses 0 and 1 for booleans because it is more readable.
	var/list/filler_locations = list(
									list(0, 0, 		0,   	0, 0),
									list(0, 0, 		0,   	0, 0),
									list(0, 0, MACH_CENTER, 0, 0),
									list(0, 0, 		0,   	0, 0),
									list(0, 0, 		0,   	0, 0)
								)
	/// A list containing all filler structures. Cleared on `Destroy()`
	var/list/all_fillers = list()

/obj/machinery/big/Initialize(mapload)
	. = ..()
	var/iterator = 0
	var/numerator = 0

	for(var/turf/filler_turf as anything in RANGE_TURFS(2, src))
		iterator++

		if(iterator == 6)
			numerator++
			iterator = 1

		if(filler_locations[5 - numerator][6 - iterator])
			var/obj/structure/filler/filler = new(filler_turf)
			all_fillers += filler

/obj/machinery/big/Destroy()
	. = ..()
	QDEL_LIST_CONTENTS(all_fillers)
