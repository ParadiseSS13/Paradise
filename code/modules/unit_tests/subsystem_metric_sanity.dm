// Unit test to ensure SS metrics are valid
/datum/unit_test/subsystem_metric_sanity/Run()
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		var/list/data = SS.get_metrics()
		if(length(data) != 3)
			Fail("SS[SS.ss_id] has invalid metrics data!")
			continue
		if(isnull(data["cost"]))
			Fail("SS[SS.ss_id] has invalid metrics data! No 'cost' found in [json_encode(data)]")
			continue
		if(isnull(data["tick_usage"]))
			Fail("SS[SS.ss_id] has invalid metrics data! No 'tick_usage' found in [json_encode(data)]")
			continue
		if(isnull(data["custom"]))
			Fail("SS[SS.ss_id] has invalid metrics data! No 'custom' found in [json_encode(data)]")
			continue
		if(!islist(data["custom"]))
			Fail("SS[SS.ss_id] has invalid metrics data! 'custom' is not a list in [json_encode(data)]")
			continue
