/atom/movable/proc/nano_host()
	return src

/obj/nano_module/nano_host()
	return loc

/atom/movable/proc/nano_can_update()
	return 1

/obj/machinery/nano_can_update()
	return !(stat & (NOPOWER|BROKEN))
