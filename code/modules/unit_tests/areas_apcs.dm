/datum/unit_test/area_apcs
	/// Sometimes, areas may have power, or not. We dont really care about these areas.
	var/list/optional_areas = list(/area/station/science/toxins/test, /area/station/maintenance/electrical_shop)

/datum/unit_test/area_apcs/Run()
	for(var/area/station/A in SSmapping.existing_station_areas)
		if(A.there_can_be_many || A.apc_starts_off || !A.requires_power)
			continue
		if(is_type_in_list(A, optional_areas))
			continue
		if(length(A.apc) == 0)
			Fail("Area [A.type] has [length(A.apc)] apcs, instead of 1.")
		else if(length(A.apc) > 1)
			var/list/locations = list()
			for(var/atom/probably_an_apc as anything in A.apc)
				locations += "([probably_an_apc.x], [probably_an_apc.y], [probably_an_apc.z])"
			Fail("Area [A.type] has [length(A.apc)] apcs, instead of 1. APCs are located at [english_list(locations)]")
