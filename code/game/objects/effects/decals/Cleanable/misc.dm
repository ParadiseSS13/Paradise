/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = TRUE
	scoop_reagents = list("ash" = 10)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/dirt.dmi'
	icon_state = "dirt"
	canSmoothWith = list(/obj/effect/decal/cleanable/dirt, /turf/simulated/wall, /obj/structure/falsewall)
	smooth = SMOOTH_MORE
	mouse_opacity = FALSE

/obj/effect/decal/cleanable/dirt/Initialize()
	..()
	icon_state = ""

/obj/effect/decal/cleanable/dirt/blackpowder
	name = "black powder"
	mouse_opacity = TRUE
	no_scoop = TRUE
	scoop_reagents = list("blackpowder" = 40) // size 2 explosion when activated

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/flour/foam
	name = "Fire fighting foam"
	desc = "It's foam."
	color = "#EBEBEB"

/obj/effect/decal/cleanable/flour/foam/Initialize()
	. = ..()
	QDEL_IN(src, 15 SECONDS)

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	light_range = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/greenglow/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 2 MINUTES)

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"
	burntime = 1

/obj/effect/decal/cleanable/cobweb/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	qdel(src)

/obj/effect/decal/cleanable/molten_object
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER
	gender = NEUTER
	icon = 'icons/effects/effects.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/molten_object/large
	name = "big gooey grey mass"
	icon_state = "big_molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	no_clear = TRUE
	scoop_reagents = list("vomit" = 5)

/obj/effect/decal/cleanable/vomit/green
	name = "green vomit"
	desc = "It's all gummy. Ew."
	icon_state = "gvomit_1"
	random_icon_states = list("gvomit_1", "gvomit_2", "gvomit_3", "gvomit_4")
	scoop_reagents = list("green_vomit" = 5)

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/plant_smudge
	name = "plant smudge"
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	gender = NEUTER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_plant")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/fungus
	name = "space fungus"
	desc = "A fungal growth. Looks pretty nasty."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"
	color = "#D5820B"
	scoop_reagents = list("fungus" = 10)

/obj/effect/decal/cleanable/confetti //PARTY TIME!
	name = "confetti"
	desc = "Party time!"
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "confetti1"
	random_icon_states = list("confetti1", "confetti2", "confetti3")
	anchored = TRUE
