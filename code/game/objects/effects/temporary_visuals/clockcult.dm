//temporary visual effects(/obj/effect/temp_visual) used by clockcult stuff
/obj/effect/temp_visual/ratvar
	name = "ratvar's light"
	icon = 'icons/effects/clockwork_effects.dmi'
	duration = 8
	randomdir = 0
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/temp_visual/ratvar/door
	icon_state = "ratvardoorglow"
	layer = CLOSED_DOOR_LAYER //above closed doors

/obj/effect/temp_visual/ratvar/door/window
	icon_state = "ratvarwindoorglow"
	layer = ABOVE_WINDOW_LAYER

/obj/effect/temp_visual/ratvar/beam
	icon_state = "ratvarbeamglow"

/obj/effect/temp_visual/ratvar/beam/grille
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/itemconsume
	layer = HIGH_OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/falsewall
	layer = OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/catwalk
	layer = LATTICE_LAYER

/obj/effect/temp_visual/ratvar/wall
	icon_state = "ratvarwallglow"

/obj/effect/temp_visual/ratvar/wall/false
	layer = OBJ_LAYER

/obj/effect/temp_visual/ratvar/floor
	icon_state = "ratvarfloorglow"

/obj/effect/temp_visual/ratvar/floor/catwalk
	layer = LATTICE_LAYER

/obj/effect/temp_visual/ratvar/window
	icon_state = "ratvarwindowglow"
	layer = ABOVE_OBJ_LAYER

/obj/effect/temp_visual/ratvar/window/single
	icon_state = "ratvarwindowglow_s"

/obj/effect/temp_visual/ratvar/gear
	icon_state = "ratvargearglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/grille
	icon_state = "ratvargrilleglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/grille/broken
	icon_state = "ratvarbrokengrilleglow"
