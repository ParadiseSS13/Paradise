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
