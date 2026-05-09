/obj/structure/window/flock
	icon = 'icons/goonstation/mob/featherzone.dmi'
	pass_flags = PASSFLOCK
	heat_resistance = 32000
	glass_type = /obj/item/stack/sheet/gnesis_glass

/obj/structure/window/flock/Initialize(mapload, direct)
	. = ..()
	AddComponent(/datum/component/flock_object)
	AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/window/flock/proc/on_crossed(atom/source, atom/movable/crosser)
	SIGNAL_HANDLER

	if(!isflockdrone(crosser))
		return

	if(!HAS_TRAIT(crosser, TRAIT_FLOCKPHASE))
		animate_flockpass(crosser)

/obj/structure/window/flock/fulltile
	dir = SOUTHWEST
	fulltile = TRUE
