/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	desc = "Used to call and send the labor camp shuttle."
	circuit = /obj/item/circuitboard/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	req_access = list(ACCESS_BRIG)

/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = "A one-way shuttle console, used to summon the shuttle to the labor camp."
	possible_destinations = "laborcamp_away"
	circuit = /obj/item/circuitboard/labor_shuttle/one_way

/obj/machinery/computer/shuttle/labor/one_way/allowed(mob/M)
	. = ..()
	if(.)
		return TRUE

	for(var/obj/item/card/id/prisoner/prisoner_id in M)
		if(!prisoner_id.goal)
			continue //no goal? no shuttle

		if(prisoner_id.points >= prisoner_id.goal)
			return TRUE //completed goal? call it

	return FALSE //if we didn't match above, no shuttle call
