/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	explosion_block = 2

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/unsimulated/wall/fakedoor
	name = "Centcom Access"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "closed"

/turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = 'config/title_screens/images/blank.png'
	icon_state = ""
	layer = FLY_LAYER

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/unsimulated/wall/metal
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	smooth = SMOOTH_TRUE

/turf/unsimulated/wall/abductor
	icon_state = "alien1"
	explosion_block = 50

/turf/unsimulated/wall/necropolis
	name = "necropolis wall"
	desc = "A seemingly impenetrable wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "necro"
	explosion_block = 50
	baseturf = /turf/unsimulated/wall/necropolis

/turf/unsimulated/wall/boss
	name = "necropolis wall"
	desc = "A thick, seemingly indestructible stone wall."
	icon = 'icons/turf/walls/boss_wall.dmi'
	icon_state = "wall"
	canSmoothWith = list(/turf/unsimulated/wall/boss, /turf/unsimulated/wall/boss/see_through)
	explosion_block = 50
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	smooth = SMOOTH_TRUE

/turf/unsimulated/wall/boss/see_through
	opacity = FALSE

/turf/unsimulated/wall/hierophant
	name = "wall"
	desc = "A wall made out of smooth, cold stone."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "hierophant"
	smooth = SMOOTH_TRUE
