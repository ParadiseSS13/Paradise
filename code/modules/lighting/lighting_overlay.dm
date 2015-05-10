/atom/movable/lighting_overlay
	name = ""
	mouse_opacity = 0
	simulated = 0
	anchored = 1

	icon = LIGHTING_ICON
	layer = LIGHTING_LAYER
	invisibility = INVISIBILITY_LIGHTING
	blend_mode = BLEND_MULTIPLY
	color = "#000000"

	var/lum_r
	var/lum_g
	var/lum_b

	#if LIGHTING_RESOLUTION != 1
	var/xoffset
	var/yoffset
	#endif

	var/needs_update

/atom/movable/lighting_overlay/New()
	. = ..()
	verbs.Cut()

/atom/movable/lighting_overlay/proc/update_lumcount(delta_r, delta_g, delta_b)
	lum_r += delta_r
	lum_g += delta_g
	lum_b += delta_b

	needs_update = 1
	lighting_update_overlays += src

/atom/movable/lighting_overlay/proc/update_overlay()
	var/mx = max(lum_r, lum_g, lum_b)
	. = 1 // factor
	if(mx > 1)
		. = 1/mx
	#if LIGHTING_TRANSITIONS == 1
	animate(src,
		color = rgb(lum_r * 255 * ., lum_g * 255 * ., lum_b * 255 * .),
		LIGHTING_INTERVAL - 1
	)
	#else
	color = rgb(lum_r * 255 * ., lum_g * 255 * ., lum_b * 255 * .)
	#endif