/area/ruin/drakehound_mine/arrivals
	name = "Drakehound Asteroid Mine Arrivals"
	icon_state = "entry"

/area/ruin/drakehound_mine/bar
	name = "Drakehound Asteroid Mine Bar"
	icon_state = "bar"

/area/ruin/drakehound_mine/bridge
	name = "Drakehound Asteroid Mine Bridge"
	icon_state = "bridge"

/area/ruin/drakehound_mine/hallway_south
	name = "Drakehound Asteroid Mine Aft Hallway"
	icon_state = "hall_space"

/area/ruin/drakehound_mine/hallway_north
	name = "Drakehound Asteroid Mine Fore Hallway"
	icon_state = "hall_space"

/area/ruin/drakehound_mine/mechbay
	name = "Drakehound Asteroid Mine Mechbay"
	icon_state = "mechbay"

/area/ruin/drakehound_mine/ship
	name = "Drakehound Asteroid Mine Ship"
	requires_power = FALSE

/area/ruin/drakehound_mine/solars
	name = "Drakehound Asteroid Mine Solars"
	icon_state = "general_solars"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

// MARK: LORE CONSOLES

/obj/machinery/computer/loreconsole/drakehound_mine
	entries = list(
		new/datum/lore_console_entry(
			"Foreman's Log",
			{"I can't believe we were able to snag these rocks at the price they were. They're just filled with minerals!
Spike says the rocks are pretty strong too. This little outpost will be our first foray into riches! We're gonna make it big, I tell you!"}))
