//temporary visual effects(/obj/effect/temp_visual) used by cult stuff
/obj/effect/temp_visual/cult
	icon = 'icons/effects/cult_effects.dmi'
	randomdir = FALSE
	duration = 10

/obj/effect/temp_visual/cult/sparks
	randomdir = TRUE
	name = "blood sparks"
	icon_state = "bloodsparkles"

/obj/effect/temp_visual/dir_setting/cult/phase
	name = "phase glow"
	duration = 7
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultin"

/obj/effect/temp_visual/dir_setting/cult/phase/out
	icon_state = "cultout"

/obj/effect/temp_visual/cult/sac
	name = "maw of Nar-Sie"
	icon_state = "sacconsume"

/obj/effect/temp_visual/cult/door
	name = "unholy glow"
	icon_state = "doorglow"
	layer = 3.17 //above closed doors

/obj/effect/temp_visual/cult/door/unruned
	icon_state = "unruneddoorglow"

/obj/effect/temp_visual/cult/turf
	name = "unholy glow"
	icon_state = "wallglow"
	layer = TURF_LAYER + 0.07

/obj/effect/temp_visual/cult/turf/open/floor
	icon_state = "floorglow"
	duration = 5
	plane = FLOOR_PLANE