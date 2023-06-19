/obj/machinery/door/unpowered
	explosion_block = 1

/obj/machinery/door/unpowered/Bumped(atom/movable/moving_atom)
	if(locked)
		SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, moving_atom)
		return
	..()

/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user, params)
	if(locked)
		return
	else
		return ..()

/obj/machinery/door/unpowered/emag_act()
	return
