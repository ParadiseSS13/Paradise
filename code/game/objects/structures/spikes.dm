/obj/structure/spikes
	name = "anti-hobo spikes"
	desc = "A pointy piece of metal, engineered to deter the laziest of employees."
	icon = 'icons/obj/structures.dmi'
	icon_state = "spikes"
	anchored = TRUE
	layer = BELOW_OPEN_DOOR_LAYER
	level = 3
	max_integrity = 500

/obj/structure/spikes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 2, _flags = CALTROP_BYPASS_SHOES|CALTROP_SAFE_VERTICAL)
