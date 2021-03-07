// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = FALSE
	anchored = TRUE
	layer = 50
	plane = HUD_PLANE

/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/decal/chempuff/blob_act(obj/structure/blob/B)
	return

/obj/effect/decal/snow
	name = "snow"
	density = FALSE
	anchored = TRUE
	layer = TURF_DECAL_LAYER
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/obj/effect/decal/snow/clean/edge
	icon_state = "snow_corner"

/obj/effect/decal/snow/sand/edge
	icon_state = "gravsnow_corner"

/obj/effect/decal/snow/clean/surround
	icon_state = "snow_surround"

/obj/effect/decal/snow/sand/surround
	icon_state = "gravsnow_surround"

/obj/effect/decal/leaves
	name = "fall leaves"
	density = FALSE
	anchored = TRUE
	layer = HIGH_TURF_LAYER
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "fallleaves"

/obj/effect/decal/straw
	name = "scattered straw"
	density = FALSE
	anchored = TRUE
	layer = HIGH_TURF_LAYER
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "strawscattered"

/obj/effect/decal/straw/medium
	icon_state = "strawscattered3"

/obj/effect/decal/straw/light
	icon_state = "strawscattered2"

/obj/effect/decal/straw/edge
	icon_state = "strawscatterededge"

/obj/effect/decal/ants
	name = "space ants"
	desc = "A bunch of space ants."
	icon = 'icons/goonstation/effects/effects.dmi'
	icon_state = "spaceants"
	scoop_reagents = list("ants" = 20)

/obj/effect/decal/ants/Initialize(mapload)
	. = ..()
	var/scale = (rand(2, 10) / 10) + (rand(0, 5) / 100)
	transform = matrix(transform, scale, scale, MATRIX_SCALE)
	setDir(pick(NORTH, SOUTH, EAST, WEST))
