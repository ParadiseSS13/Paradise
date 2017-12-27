/obj/machinery/door/unpowered
	autoclose = 0
	explosion_block = 1
	var/locked = 0

/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(locked)
		return
	..()

/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/emag) || istype(I, /obj/item/weapon/melee/energy/blade))
		return
	if(locked)
		return
	return ..()

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "door1"
