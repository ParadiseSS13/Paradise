/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that open mechanically."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	dir = EAST

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/shutters/rusted
	name = "Rusted Shutter"
	desc = "Heavy duty shutters that has been warped and corroded by the elements. It does not seem it will take much to break it down by force."
	armor = list("melee" = 10, "bullet" = 5, "laser" = 15, "energy" = 15, "bomb" = 0, "bio" = 50, "rad" = 100, "fire" = 50, "acid" = 25)
	damage_deflection = 0
	max_integrity = 300
	icon_state = "rusted_closed"
	anim_opening = "rusted_opening"
	anim_closing = "rusted_closing"
	icon_opened = "rusted_open"
	icon_closed = "rusted_closed"
