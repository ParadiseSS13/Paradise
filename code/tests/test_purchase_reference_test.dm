// tests if there are duplicate or null refs/lognames for uplink items and spellbook items respectively
/datum/game_test/uplink_refs/Run()
	var/list/uplink_refs = list()
	for(var/datum/uplink_item/I as anything in subtypesof(/datum/uplink_item))
		if(isnull(initial(I.item)))
			continue //don't test them if they don't have an item
		var/uplink_ref = initial(I.reference)
		if(isnull(uplink_ref))
			TEST_FAIL("uplink item [initial(I.name)] has no reference")
			continue
		TEST_ASSERT_NOT(uplink_ref in uplink_refs, "uplink reference [uplink_ref] is used multiple times")
		uplink_refs += uplink_ref

