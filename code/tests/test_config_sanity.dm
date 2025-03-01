// This one test does multiple config things
/datum/game_test/config_sanity/Run()
	// First test the ruins. Space then lava.
	var/list/config_space_ruins = GLOB.configuration.ruins.active_space_ruins.Copy() // Copy so we dont remove
	var/list/datum/map_template/ruin/space/game_space_ruins = list()

	// Yes I know this is inefficient. Sue me.
	for(var/path in subtypesof(/datum/map_template/ruin/space))
		var/datum/map_template/ruin/space/S = new path()
		// istype() doesnt work here. Dont even try it.
		if(S.ci_exclude == S.type)
			continue
		game_space_ruins.Add(S)

	for(var/datum/map_template/ruin/space/S in game_space_ruins)
		if(S.mappath in config_space_ruins)
			// Remove both
			game_space_ruins -= S
			config_space_ruins -= S.mappath

	// Do not confuse this with the map_templates unit test. They do different things!!!!!
	if(length(game_space_ruins))
		TEST_FAIL("Space ruins exist in the game code that do not exist in the config file")
		for(var/datum/map_template/ruin/space/S in game_space_ruins)
			TEST_FAIL("Ruin [S.type] does not have a valid map path ([S.mappath])")

	if(length(config_space_ruins))
		TEST_FAIL("Space ruins exist in the game config that do not have associated datums")
		for(var/path in config_space_ruins)
			TEST_FAIL("- [path]")


	// Now for lava ruins
	var/list/config_lava_ruins = GLOB.configuration.ruins.active_lava_ruins.Copy() // Copy so we dont remove
	var/list/datum/map_template/ruin/space/game_lava_ruins = list()

	// Yes I know this is inefficient. Sue me.
	for(var/path in subtypesof(/datum/map_template/ruin/lavaland))
		var/datum/map_template/ruin/lavaland/L = new path()
		// istype() doesnt work here. Dont even try it.
		if(L.ci_exclude == L.type)
			continue
		game_lava_ruins.Add(L)

	for(var/datum/map_template/ruin/lavaland/L in game_lava_ruins)
		if(L.mappath in config_lava_ruins)
			// Remove both
			game_lava_ruins -= L
			config_lava_ruins -= L.mappath

	// Do not confuse this with the map_templates unit test. They do different things!!!!!
	if(length(game_lava_ruins))
		TEST_FAIL("Lava ruins exist in the game code that do not exist in the config file")
		for(var/datum/map_template/ruin/lavaland/L in game_lava_ruins)
			TEST_FAIL("Ruin [L.type] does not have a valid map path ([L.mappath])")

	if(length(config_lava_ruins))
		TEST_FAIL("Lava ruins exist in the game config that do not have associated datums")
		for(var/path in config_lava_ruins)
			TEST_FAIL("- [path]")
