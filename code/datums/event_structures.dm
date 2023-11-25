/datum/map_template/event
	var/event_id //remember of putting "|Event|" at beginning of event_id.
	var/description

/datum/map_template/event/splashscreen_empty
	name = "Splashscreen Empty"
	event_id = "|Event| Splashscreen Empty"
	description = "Empty starting area, good for custom admin game-join screen or admin foolery."
	mappath = "_maps/map_files/EventStructures/splashscreen_empty.dmm"

/datum/map_template/event/splashscreen_sandbox
	name = "Splashscreen Sandbox"
	event_id = "|Event| Splashscreen Sandbox"
	description = "Pre-made starting area that contains a respawner, make sure to use the ghost beacon. It has all the basic sandbox tools necessary for your ants to create colony."
	mappath = "_maps/map_files/EventStructures/splashscreen_sandbox.dmm"

/datum/map_template/event/thunderdome_default
	name = "Thunderdome - Default"
	event_id = "|Event| Thunderdome Default"
	description = "Default template of thunderdome."
	mappath = "_maps/map_files/EventStructures/thunderdome_default.dmm"

/datum/map_template/event/thunderdome_empty
	name = "Thunderdome - Empty"
	event_id = "|Event| Thunderdome Empty"
	description = "Only floor for thunderdome, no structures, good for advanced turf editing."
	mappath = "_maps/map_files/EventStructures/thunderdome_empty.dmm"

/datum/map_template/event/thunderdome_reset
	name = "Thunderdome - Reset"
	event_id = "|Event| Thunderdome Reset"
	description = "It will create chasm, which will absorb nearly everything, good for quick cleanup."
	mappath = "_maps/map_files/EventStructures/thunderdome_reset.dmm"

/datum/map_template/event/thunderdome_empty_reinforced
	name = "Thunderdome - Empty, Reinforced"
	event_id = "|Event| Thunderdome Empty Reinforced"
	description = "Only reinforced floor for thunderdome, no structures, good for advanced turf editing."
	mappath = "_maps/map_files/EventStructures/thunderdome_empty_reinforced.dmm"

/datum/map_template/event/thunderdome_catwalk_chasm
	name = "Thunderdome - Catwalk, Chasm"
	event_id = "|Event| Thunderdome Catwalk Chasm"
	description = "MORE CATWALK! It contains a big chasm in the middle."
	mappath = "_maps/map_files/EventStructures/thunderdome_catwalk_chasm.dmm"

/datum/map_template/event/thunderdome_catwalk_chasm_fake
	name = "Thunderdome - Catwalk, Fake Chasm"
	event_id = "|Event| Thunderdome Catwalk Chasm Fake"
	description = "MORE CATWALK! It contains a big fake chasm in the middle."
	mappath = "_maps/map_files/EventStructures/thunderdome_catwalk_chasm_fake.dmm"

/datum/map_template/event/thunderdome_hiero_default
	name = "Thunderdome - Hiero, Default"
	event_id = "|Event| Thunderdome Hiero Default"
	description = "Inspired by Hiero Area."
	mappath = "_maps/map_files/EventStructures/thunderdome_hiero_default.dmm"

/datum/map_template/event/thunderdome_hiero_pandora
	name = "Thunderdome - Hiero, Pandora"
	event_id = "|Event| Thunderdome Hiero Pandora"
	description = "Hiero inspired arena, contains a hostile pandora"
	mappath = "_maps/map_files/EventStructures/thunderdome_hiero_pandora.dmm"

/datum/map_template/event/thunderdome_lavaland_holes
	name = "Thunderdome - Lavaland, Holes"
	event_id = "|Event| Thunderdome Lavaland Holes"
	description = "Inspired by lavaland environment, holes have a 50% chance of being good or bad when stepped on."
	mappath = "_maps/map_files/EventStructures/thunderdome_lavaland_holes.dmm"

/datum/map_template/event/thunderdome_lavaland_maze
	name = "Thunderdome - Lavaland, Maze"
	event_id = "|Event| Thunderdome Lavaland Maze"
	description = "Inspired by lavaland environment, it contain walls and shrooms."
	mappath = "_maps/map_files/EventStructures/thunderdome_lavaland_maze.dmm"

/datum/map_template/event/thunderdome_snow_forest
	name = "Thunderdome - Snow, Forest"
	event_id = "|Event| Thunderdome Snow Forest"
	description = "Inspired by lavaland snow biodome, it contains trees, grass and snow!"
	mappath = "_maps/map_files/EventStructures/thunderdome_snow_forest.dmm"

/datum/map_template/event/thunderdome_touchgrass
	name = "Thunderdome - Touch Grass"
	event_id = "|Event| Thunderdome Touch Grass"
	description = "Go outside the confined rooms and touch grass."
	mappath = "_maps/map_files/EventStructures/thunderdome_touchgrass.dmm"
