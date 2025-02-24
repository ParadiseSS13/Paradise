/datum/game_test/area_fire_alarms
	/// Sometimes, areas may have air, or not. We dont really care about these areas.
	var/list/optional_areas = list(/area/station/science/toxins/test, /area/station/maintenance/electrical_shop)

/datum/game_test/area_fire_alarms/Run()
	for(var/area/station/A as anything in SSmapping.existing_station_areas)
		if(A.there_can_be_many || !A.outdoors)
			continue
		if(is_type_in_list(A, optional_areas))
			continue
		if(length(A.firealarms) == 0)
			TEST_FAIL("Area [A.type] has [length(A.firealarms)] air alarms, instead of at least 1.")
