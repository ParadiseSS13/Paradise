TYPEINFO_DEF(/obj/structure/window/flock)
	default_materials = list(
		/datum/material/gnesis_glass = 4000
	)

/obj/structure/window/flock
	icon = 'goon/icons/mob/featherzone.dmi'
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	heat_resistance = /obj/structure/window/plasma::heat_resistance
	melting_point = /obj/structure/window/plasma::melting_point

/obj/structure/window/flock/Initialize(mapload, direct)
	. = ..()
	AddComponent(/datum/component/flock_object)
	AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)

/obj/structure/window/flock/fulltile
	dir = SOUTHWEST
	fulltile = TRUE
