/datum/unit_test/area_apcs
	// var/list/skip_areas = list(/area/station/engineering/solar)

/datum/unit_test/area_apcs/Run()
	for(var/area/station/A in SSmapping.existing_station_areas)
		if(A.there_can_be_many || A.apc_starts_off || !A.requires_power)
			continue
		// if(is_type_in_list(A.type, skip_areas))
		if(!(length(A.apc) == 1))
			Fail("Area [A] has [length(A.apc)] apcs, instead of 1.")
