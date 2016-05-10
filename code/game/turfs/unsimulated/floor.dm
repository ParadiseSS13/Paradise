/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"
	var/obj/effect/effect/ceiling/ceiling

/turf/unsimulated/floor/New()
	..()
	ceiling = new(src)

/turf/unsimulated/floor/Destroy()
	qdel(ceiling)
	return ..()

/turf/unsimulated/floor/grass
	icon_state = "grass1"

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/unsimulated/floor/chasm
	name = "sinkhole"
	desc = "It's difficult to see the bottom."
	density = 1
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "Fill"
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/turf/unsimulated/floor/chasm/New()
	spawn(1)
		smooth_icon(src)
		smooth_icon_neighbors(src)

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"