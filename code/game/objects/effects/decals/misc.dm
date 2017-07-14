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

/obj/structure/decal/stage_edge
	name = "stage"
	icon = 'icons/obj/curtainthing.dmi'
	icon_state = "curtainthing"
	density = 1
	anchored = 1
	dir = NORTH

/obj/structure/decal/stage_edge/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/item/projectile))
		return 1
	if (get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/decal/stage_edge/CheckExit(atom/movable/O as mob|obj, target as turf)
	if (!src.density)
		return 1
	if (istype(O, /obj/item/projectile))
		return 1
	if (get_dir(O.loc, target) == src.dir)
		return 0
	return 1

/obj/structure/decal/boxingrope
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = 1
	icon = 'icons/obj/box.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER

/obj/structure/decal/boxingrope/CanPass(atom/movable/mover, turf/target, height=0, air_group=0) // stolen from window.dm
	if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
		return 0
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/decal/boxingrope/CheckExit(atom/movable/O as mob|obj, target as turf)
	if (!src.density)
		return 1
	if (get_dir(O.loc, target) == src.dir)
		return 0
	return 1

/obj/structure/decal/boxingropeenter
	name = "Ring entrance"
	desc = "Do not exit the ring."
	density = 0
	anchored = 1
	icon = 'icons/obj/box.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER