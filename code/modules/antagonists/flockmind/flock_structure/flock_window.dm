/obj/structure/window/flock
	icon = 'icons/goonstation/mob/featherzone.dmi'
	heat_resistance = 32000
	glass_type = /obj/item/stack/sheet/gnesis_glass

/obj/structure/window/flock/Initialize(mapload, direct)
	. = ..()
	AddComponent(/datum/component/flock_object)
	AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)

/obj/structure/window/flock/fulltile
	dir = SOUTHWEST
	fulltile = TRUE
