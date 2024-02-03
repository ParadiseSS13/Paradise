/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = MID_TURF_LAYER
	mergeable_decal = FALSE // Allows crayon drawings to overlap one another.
	beauty = -25


/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = "#FFFFFF", type = "rune1", e_name = "rune")
	. = ..()

	name = e_name
	desc = "A [name] drawn in crayon."

	icon_state = type
	color = main
