// Unit test to ensure SS metrics are valid
/datum/game_test/subsystem_metric_sanity/Run()
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		var/list/data = SS.get_metrics()
		if(length(data) != 4)
			TEST_FAIL("SS[SS.ss_id] has invalid metrics data!")
			continue
		if(isnull(data["cost"]))
			TEST_FAIL("SS[SS.ss_id] has invalid metrics data! No 'cost' found in [json_encode(data)]")
			continue
		if(isnull(data["tick_usage"]))
			TEST_FAIL("SS[SS.ss_id] has invalid metrics data! No 'tick_usage' found in [json_encode(data)]")
			continue
		if(isnull(data["custom"]))
			TEST_FAIL("SS[SS.ss_id] has invalid metrics data! No 'custom' found in [json_encode(data)]")
			continue
		if(!islist(data["custom"]))
			TEST_FAIL("SS[SS.ss_id] has invalid metrics data! 'custom' is not a list in [json_encode(data)]")
			continue
		if(isnull(data["sleep_count"]))
			TEST_FAIL("SS[SS.ss_id] has invalid metrics data! No 'sleep_count' found in [json_encode(data)]")
			continue
