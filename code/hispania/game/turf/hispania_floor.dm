/turf/simulated/floor/plasteel/hispania
	icon_state = "L1"
	icon = 'icons/hispania/turf/floors.dmi'
	floor_tile = /obj/item/stack/tile/plasteel
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/simulated/floor/plating/asteroid/snow/naga
	oxygen = 10
	nitrogen = 82
	floor_variance = 15
	temperature = 120
	icon = 'icons/hispania/turf/snow.dmi'
	baseturf = /turf/simulated/floor/plating/asteroid/snow/naga

/turf/simulated/floor/plating/ice_naga
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/hispania/turf/ice_turfs.dmi'
	oxygen = 10
	nitrogen = 82
	temperature = 120
	baseturf = /turf/simulated/floor/plating/asteroid/snow/naga
	canSmoothWith = list(/turf/simulated/floor/plating/ice_naga/smooth, /turf/simulated/floor/plating/ice_naga)

/turf/simulated/floor/plating/ice_naga/smooth
	icon_state = "smooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/simulated/floor/plating/ice_naga/smooth, /turf/simulated/floor/plating/ice_naga)

