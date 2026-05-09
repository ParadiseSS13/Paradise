/obj/effect/temp_visual/flock // temporary flock visual feedback objects
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "blank"
	layer = ABOVE_NORMAL_TURF_LAYER
	duration = 4.5 SECONDS
	var/animation

/obj/effect/temp_visual/flock/Initialize(mapload)
	. = ..()
	flick(animation, src)

/obj/effect/temp_visual/flock/wall_convert
	icon_state = "spawn-wall-loop"
	animation = "spawn-wall"


/obj/effect/temp_visual/flock/floor_convert
	icon_state = "spawn-floor-loop"
	animation = "spawn-floor"
