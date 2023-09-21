/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	opacity = FALSE
	density = TRUE
	var/lifetime = 30 SECONDS

/obj/effect/forcefield/New()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/forcefield/CanAtmosPass(turf/T)
	return !density

/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	return FALSE

///////////Mimewalls///////////

/obj/structure/forcefield
	name = "ain't supposed to see this"
	desc = "file a github report if you do!"
	icon = 'icons/effects/effects.dmi'
	density = TRUE
	anchored = TRUE
	var/blocks_atmos = TRUE

/obj/structure/forcefield/Initialize(mapload)
	. = ..()
	if(blocks_atmos)
		air_update_turf(TRUE)

/obj/structure/forcefield/Destroy()
	if(blocks_atmos)
		blocks_atmos = FALSE
		air_update_turf(TRUE)
	return ..()

/obj/structure/forcefield/CanAtmosPass(turf/T)
	return !blocks_atmos

/obj/structure/forcefield/mime
	icon = 'icons/effects/effects.dmi'
	icon_state = "5"
	name = "invisible wall"
	alpha = 1
	desc = "You have a bad feeling about this."
	max_integrity = 80

/obj/effect/forcefield/mime/advanced
	icon_state = "empty"
	name = "invisible blockade"
	desc = "You might be here a while."
	lifetime = 60 SECONDS

// Not quite a forcefield, but close enough that I'm including it in this file
/obj/effect/holo_forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "hierophant_wall_temp-0"
	base_icon_state = "hierophant_wall_temp"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	opacity = FALSE
	density = TRUE
	color = LIGHT_COLOR_BLUE
	light_range = 3 // They're energy walls, those give off a lot of light
	light_color = LIGHT_COLOR_BLUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/holo_forcefield/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

/obj/effect/holo_forcefield/Destroy()
	air_update_turf(TRUE)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/holo_forcefield/CanAtmosPass(turf/T)
	return FALSE

/obj/effect/holo_forcefield/CanPass(atom/movable/mover, turf/target)
	return TRUE
