/datum/game_test/bespoke_element/Run()
	for(var/datum/element/element_type as anything in subtypesof(/datum/element))
		if(initial(element_type.element_flags) & ELEMENT_BESPOKE && initial(element_type.argument_hash_start_idx) == INFINITY)
			TEST_FAIL("Element type [element_type] has ELEMENT_BESPOKE and a default argument_hash_start_idx.")
