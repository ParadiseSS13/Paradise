// MARK: Floor painter
/datum/painter/floor
	floor_icon = 'modular_ss220/aesthetics/floors/icons/floors.dmi'

/datum/painter/floor/New()
	. = ..()
	allowed_states |= list("darkneutralcorner", "darkneutral", "darkneutralfull", "navybluecorners", "navyblue", "navybluefull",
		"navybluealt", "navybluealtstrip", "navybluecornersalt", "darkbluealt", "darkbluealtstrip", "darkbluecornersalt",
		"darkredalt", "darkredaltstrip", "darkredcornersalt", "darkyellowalt", "darkyellowaltstrip", "darkyellowcornersalt",
		"whitebrowncorner", "whitebrown"
		)

/turf/simulated/floor
	icon = 'modular_ss220/aesthetics/floors/icons/floors.dmi'

/turf/simulated/floor/plasteel/dark
	icon_state = "dark"

/turf/simulated/floor/mech_bay_recharge_floor
	icon = 'modular_ss220/aesthetics/floors/icons/floors.dmi'

/turf/simulated/floor/plasteel/smooth
	icon_state = "smooth"

// MARK: LIGHT FLOORS
/turf/simulated/floor/light/red
	color = "#f23030"
	light_color = "#f23030"

/turf/simulated/floor/light/green
	color = "#30f230"
	light_color = "#30f230"

/turf/simulated/floor/light/blue
	color = "#3030f2"
	light_color = "#3030f2"

/turf/simulated/floor/light/purple
	color = "#d493ff"
	light_color = "#d493ff"
