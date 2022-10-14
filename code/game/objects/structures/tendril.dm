/obj/structure/tendril
	name = "tendril"
	desc = "A tendril."
	max_integrity = 300
	climbable = FALSE
	anchored = TRUE
	icon = 'icons/obj/tendril.dmi'
	icon_state = "tendril"
	color = "#ffffff"

/obj/structure/tendril/Initialize(mapload)
	. = ..()

/obj/structure/tendril/Destroy()
	. = ..()

/obj/structure/tendril/small
	name = "small tendril"
	desc = "A small tendril."
	max_integrity = 200
	icon_state = "tendril_small"
