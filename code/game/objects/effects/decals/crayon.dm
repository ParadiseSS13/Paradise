/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = MID_TURF_LAYER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	anchored = TRUE
	mergeable_decal = FALSE // Allows crayon drawings to overlap one another.


/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = "#FFFFFF", var/type = "rune1", var/e_name = "rune")
	. = ..()

	name = e_name
	desc = "A [name] drawn in crayon."

	icon_state = type
	color = main
