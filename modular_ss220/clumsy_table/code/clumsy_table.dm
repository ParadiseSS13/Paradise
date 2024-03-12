/obj/structure/table/Crossed(atom/movable/AM, oldloc)
	AddComponent(/datum/component/clumsy_climb, 5)
	. = ..()

/obj/structure/table/do_climb(mob/living/user)
	if(!..())
		return FALSE
	AddComponent(/datum/component/clumsy_climb, 15)
	SEND_SIGNAL(src, COMSIG_CLIMBED_ON, user)
