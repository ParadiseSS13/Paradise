/obj/effect/overlay
	name = "overlay"
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name = "beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "b_beam"
	var/tmp/atom/BeamSource

/obj/effect/overlay/beam/New()
	..()
	QDEL_IN(src, 10)

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/sparkles
	name = "sparkles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"

/obj/effect/overlay/adminoverlay
	name = "adminoverlay"
	icon = 'icons/effects/effects.dmi'
	icon_state = "admin"
	layer = 4.1

/obj/effect/overlay/wall_rot
	name = "Wallrot"
	desc = "Ick..."
	icon = 'icons/effects/wallrot.dmi'
	anchored = 1
	density = 1
	layer = 5
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/overlay/wall_rot/New()
	..()
	pixel_x += rand(-10, 10)
	pixel_y += rand(-10, 10)

/obj/effect/overlay/light_visible
	name = ""
	icon = 'icons/effects/light_overlays/light_32.dmi'
	icon_state = "light"
	layer = O_LIGHTING_VISUAL_LAYER
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	vis_flags = NONE
