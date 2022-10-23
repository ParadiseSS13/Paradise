/obj/effect/temp_visual/ripple
	name = "hyperspace ripple"
	desc = "Something is coming through hyperspace, you can see the \
		visual disturbances. It's probably best not to be on top of these \
		when whatever is tunneling comes through."
	icon = 'icons/turf/floors/ripple.dmi'
	icon_state = "ripple"
	anchored = TRUE
	density = FALSE
	smooth = SMOOTH_TRUE
	layer = RIPPLE_LAYER
	alpha = 0
	duration = 3 * SHUTTLE_RIPPLE_TIME
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/temp_visual/ripple/New()
	. = ..()
	queue_smooth(src)
	animate(src, alpha=255, time=SHUTTLE_RIPPLE_TIME)
