/datum/world_topic_handler/manifest
	topic_key = "manifest"

/datum/world_topic_handler/manifest/execute(list/input, key_valid)
	var/list/positions = list()
	var/list/set_names = list(
		"heads" = GLOB.command_positions,
		"sec" = GLOB.active_security_positions,
		"eng" = GLOB.engineering_positions,
		"med" = GLOB.medical_positions,
		"sci" = GLOB.science_positions,
		"car" = GLOB.supply_positions,
		"srv" = GLOB.service_positions,
		"ast" = GLOB.assistant_positions,
		"bot" = GLOB.nonhuman_positions
	)

	for(var/datum/data/record/t in GLOB.data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]

		var/department = FALSE
		for(var/k in set_names)
			if(real_rank in set_names[k])
				if(!positions[k])
					positions[k] = list()
				positions[k][name] = rank
				department = TRUE
		if(!department)
			if(!positions["misc"])
				positions["misc"] = list()
			positions["misc"][name] = rank

	return json_encode(positions)
