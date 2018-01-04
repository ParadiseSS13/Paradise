/obj/effect/overload
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	var/cycles = 0
	var/beepsound = 'sound/items/timer.ogg'
	light_power = 0
	light_range = 0
	var/deliberate = FALSE
	var/max_cycles = 20

/obj/effect/overload/New()
	..()
	processing_objects.Add(src)

/obj/effect/overload/process()
	if(cycles < max_cycles)
		if(!deliberate)
			playsound(loc, beepsound, 50, 0)
		cycles++
		light_power = cycles
		light_range = cycles
		return

	if(areaMaster.fire)
		areaMaster.fire_reset()
	explosion(get_turf(src), 20, 30, 40, 50, 1, 1, 40, 0, 1)
	processing_objects.Remove(src)
	qdel(src)