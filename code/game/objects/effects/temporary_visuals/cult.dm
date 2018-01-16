//temporary visual effects(/obj/effect/overlay/temp) used by cult stuff
/obj/effect/overlay/temp/cult
	icon = 'icons/effects/cult_effects.dmi'
	randomdir = FALSE
	duration = 10

/obj/effect/overlay/temp/cult/sparks
	randomdir = TRUE
	name = "blood sparks"
	icon_state = "bloodsparkles"

/obj/effect/overlay/temp/dir_setting/cult/phase
	name = "phase glow"
	duration = 7
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultin"

/obj/effect/overlay/temp/dir_setting/cult/phase/out
	icon_state = "cultout"

/obj/effect/overlay/temp/cult/sac
	name = "maw of Nar-Sie"
	icon_state = "sacconsume"

/obj/effect/overlay/temp/cult/door
	name = "unholy glow"
	icon_state = "doorglow"
	layer = 3.17 //above closed doors

/obj/effect/overlay/temp/cult/door/unruned
	icon_state = "unruneddoorglow"

/obj/effect/overlay/temp/cult/turf
	name = "unholy glow"
	icon_state = "wallglow"
	layer = TURF_LAYER + 0.07

/obj/effect/overlay/temp/cult/turf/open/floor
	icon_state = "floorglow"
	duration = 5