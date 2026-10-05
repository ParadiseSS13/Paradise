/datum/weather/void_storm
	name = "void storm"
	desc = "A rare and highly anomalous event often accompanied by unknown entities shredding spacetime continouum. We'd advise you to start running."

	telegraph_duration = 2 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = SPAN_HIEROPHANT("You feel the air around you getting colder... and void's sweet embrace...")
	weather_overlay = "light_snow"
	weather_color = COLOR_BLACK
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 120 SECONDS


	end_duration = 10 SECONDS

	area_types = list(/area)
	target_trait = REACHABLE_SPACE_ONLY

	perpetual = TRUE
