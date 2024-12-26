/obj/structure/table/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/proc/on_crossed(atom/crosser)
	AddComponent(/datum/component/clumsy_climb, 5)

/obj/structure/table/do_climb(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	AddComponent(/datum/component/clumsy_climb, 15)
	SEND_SIGNAL(src, COMSIG_CLIMBED_ON, user)
