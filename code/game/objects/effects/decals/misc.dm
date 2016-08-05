/obj/effect/decal/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1
	mouse_opacity = 0

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	anchored = 1
	layer = 50
	plane = HUD_PLANE

/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/decal/snow
	name="snow"
	density=0
	anchored=1
	layer=2
	icon='icons/turf/snow.dmi'

/obj/effect/decal/snow/clean/edge
	icon_state="snow_corner"

/obj/effect/decal/snow/sand/edge
	icon_state="gravsnow_corner"

/obj/effect/decal/snow/clean/surround
	icon_state="snow_surround"

/obj/effect/decal/snow/sand/surround
	icon_state="gravsnow_surround"

/obj/effect/decal/leaves
	name="fall leaves"
	density = 0
	anchored = 1
	layer = 2
	icon='icons/obj/flora/plants.dmi'
	icon_state = "fallleaves"

/obj/effect/decal/straw
	name="scattered straw"
	density = 0
	anchored = 1
	layer = 2
	icon='icons/obj/flora/plants.dmi'
	icon_state = "strawscattered"

/obj/effect/decal/straw/medium
	icon_state = "strawscattered3"

/obj/effect/decal/straw/light
	icon_state = "strawscattered2"

/obj/effect/decal/straw/edge
	icon_state = "strawscatterededge"