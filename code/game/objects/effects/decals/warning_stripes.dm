/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = TURF_LAYER

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

/obj/effect/decal/warning_stripes/Initialize()
	. = ..()
	loc.overlays += src
	qdel(src)

// Credit to Neinhaus for making these into individual decals.

/obj/effect/decal/warning_stripes/arrow
	icon_state = "4"

/obj/effect/decal/warning_stripes/yellow
	icon_state = "5"

/obj/effect/decal/warning_stripes/yellow/partial
	icon_state = "3"

/obj/effect/decal/warning_stripes/yellow/hollow
	icon_state = "6"


/obj/effect/decal/warning_stripes/red
	icon_state = "8"

/obj/effect/decal/warning_stripes/red/partial
	icon_state = "7"

/obj/effect/decal/warning_stripes/red/hollow
	icon_state = "9"


/obj/effect/decal/warning_stripes/green
	icon_state = "11"

/obj/effect/decal/warning_stripes/green/partial
	icon_state = "10"

/obj/effect/decal/warning_stripes/green/hollow
	icon_state = "12"


/obj/effect/decal/warning_stripes/white
	icon_state = "14"

/obj/effect/decal/warning_stripes/white/partial
	icon_state = "13"

/obj/effect/decal/warning_stripes/white/hollow
	icon_state = "15"


/obj/effect/decal/warning_stripes/blue
	icon_state = "17"

/obj/effect/decal/warning_stripes/blue/partial
	icon_state = "16"

/obj/effect/decal/warning_stripes/blue/hollow
	icon_state = "18"
