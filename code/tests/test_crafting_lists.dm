/datum/game_test/crafting_lists/Run()
	for(var/I in subtypesof(/datum/crafting_recipe))
		var/datum/crafting_recipe/C = new I()
		TEST_ASSERT(islist(C.result), "Expected a list for the 'result' of [C.type].")
