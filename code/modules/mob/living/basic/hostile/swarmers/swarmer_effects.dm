/obj/effect/temp_visual/swarmer // temporary swarmer visual feedback objects
	icon = 'icons/mob/swarmer.dmi'
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/swarmer/disintegration
	icon_state = "disintegrate"

/obj/effect/temp_visual/swarmer/disintegration/Initialize(mapload)
	. = ..()
	playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/effect/temp_visual/swarmer/dismantle
	icon_state = "dismantle"
	duration = 2.5 SECONDS

/obj/effect/temp_visual/swarmer/integrate
	icon_state = "integrate"
	duration = 5 SECONDS
