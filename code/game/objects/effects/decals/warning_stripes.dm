/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = 2

/obj/effect/decal/warning_stripes/north
	icon_state = "N"

/obj/effect/decal/warning_stripes/south
	icon_state = "S"

/obj/effect/decal/warning_stripes/east
	icon_state = "E"

/obj/effect/decal/warning_stripes/west
	icon_state = "W"

/obj/effect/decal/warning_stripes/southeast
	icon_state = "NW-in"

/obj/effect/decal/warning_stripes/northwestcorner
	icon_state = "NW-out"

/obj/effect/decal/warning_stripes/southwest
	icon_state = "NE-in"

/obj/effect/decal/warning_stripes/northeastcorner
	icon_state = "NE-out"

/obj/effect/decal/warning_stripes/northeast
	icon_state = "SW-in"

/obj/effect/decal/warning_stripes/southwestcorner
	icon_state = "SW-out"

/obj/effect/decal/warning_stripes/northwest
	icon_state = "SE-in"

/obj/effect/decal/warning_stripes/southeastcorner
	icon_state = "SE-out"

/obj/effect/decal/warning_stripes/eastsouthwest
	icon_state = "U-N"

/obj/effect/decal/warning_stripes/eastnorthwest
	icon_state = "U-S"

/obj/effect/decal/warning_stripes/northeastsouth
	icon_state = "U-W"

/obj/effect/decal/warning_stripes/northwestsouth
	icon_state = "U-E"

/obj/effect/decal/warning_stripes/New()
	. = ..()

	loc.overlays += src
	del src