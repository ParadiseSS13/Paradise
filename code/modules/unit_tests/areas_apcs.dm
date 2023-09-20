/datum/unit_test/area_apcs/Run()
	for(var/area/station/A in SSmapping.existing_station_areas)
		if(A.there_can_be_many || A.apc_starts_off || !A.requires_power)
			continue
		if(!(length(A.apc) == 1))
			Fail("Area [A] has [length(A.apc)] apcs, instead of 1.")
