/turf/simulated/floor/plasteel
	icon_state = "tile_standard"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/plasteel/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_regular_floor
	if(icon_regular_floor != icon_states(icon))
		icon_state = "tile_standard"

/turf/simulated/floor/plasteel/get_broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/simulated/floor/plasteel/pressure_debug

/turf/simulated/floor/plasteel/pressure_debug/airless
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plasteel/pressure_debug/Initialize(mapload)
	..()
	addtimer(CALLBACK(src, PROC_REF(update_color)), 1, TIMER_LOOP)

/turf/simulated/floor/plasteel/pressure_debug/proc/update_color()
	var/datum/gas_mixture/air = get_readonly_air()
	var/ratio = min(1, air.return_pressure() / ONE_ATMOSPHERE)
	color = rgb(255 * (1 - ratio), 0, 255 * ratio)

/turf/simulated/floor/plasteel/airless
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_LATTICE)

/turf/simulated/floor/plasteel/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/plasteel/airless/Initialize(mapload)
	. = ..()
	name = "floor"

/// For bomb testing range
/turf/simulated/floor/plasteel/airless/indestructible

/turf/simulated/floor/plasteel/airless/indestructible/ex_act(severity)
	return

/turf/simulated/floor/plasteel/fakestairs
	icon_state = "stairs"

/turf/simulated/floor/plasteel/fakestairs/left
	icon_state = "stairs-l"

/turf/simulated/floor/plasteel/fakestairs/center
	icon_state = "stairs-m"

/turf/simulated/floor/plasteel/fakestairs/right
	icon_state = "stairs-r"

/turf/simulated/floor/plasteel/dark/telecomms
	nitrogen = 100
	oxygen = 0
	temperature = 80

/turf/simulated/floor/plasteel/dark/nitrogen
	nitrogen = 100
	oxygen = 0

/turf/simulated/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/simulated/floor/plasteel/stairs
	// icon = 'icons/turf/floors/materials/floors_stairs.dmi'
	icon_state = "stairs"

/turf/simulated/floor/plasteel/stairs/left
	icon_state = "stairs-l"

/turf/simulated/floor/plasteel/stairs/medium
	icon_state = "stairs-m"

/turf/simulated/floor/plasteel/stairs/right
	icon_state = "stairs-r"

/turf/simulated/floor/plasteel/stairs/old
	icon_state = "stairs-old"

/turf/simulated/floor/plasteel/grimy
	icon_state = "grimy"
