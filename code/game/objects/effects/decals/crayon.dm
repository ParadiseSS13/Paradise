/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = MID_TURF_LAYER
	anchored = TRUE


/obj/effect/decal/cleanable/crayon/New(location, main = "#FFFFFF", var/type = "rune1", var/e_name = "rune")
	..()
	loc = location

	name = e_name
	desc = "A [name] drawn in crayon."

	icon_state = type
	color = main
