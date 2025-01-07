/datum/game_test/status_effect_ids/Run()
	var/list/bad_statuses = list()
	for(var/datum/status_effect/effect as anything in subtypesof(/datum/status_effect))
		if(initial(effect.id) == null)
			bad_statuses += effect

	if(length(bad_statuses))
		TEST_FAIL("Status effects found without an unique ID: [bad_statuses.Join(", ")]")
