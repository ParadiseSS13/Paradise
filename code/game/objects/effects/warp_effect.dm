/obj/effect/warp_effect
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	icon = 'icons/effects/seismic_stomp_effect.dmi'
	icon_state = "stomp_effect"
	pixel_y = -16
	pixel_x = -16

/obj/effect/warp_effect/ex_act(severity)
	return

/obj/effect/warp_effect/singularity_act()
	return FALSE
