/obj/machinery/door/airlock/abductor/secure
	security_level = 6
	autoclose = FALSE
	flags = INDESTRUCTIBLE
	locked = TRUE
	req_access = list()

/obj/machinery/door/airlock/abductor/secure/Initialize(mapload)
	. = ..()
	// Randomize the wires so they aren't the same as the station
	wires.randomize()

/// Always returns false since you aren't supposed to open it normally
/obj/machinery/door/airlock/abductor/secure/check_access(obj/item/I)
	return FALSE
