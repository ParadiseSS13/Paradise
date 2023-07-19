/obj/machinery/door/poddoor/shutters
	icon = 'modular_ss220/aesthetics/shutters/icons/shutters.dmi'
	var/door_open_sound = 'modular_ss220/aesthetics/shutters/sound/shutters_open.ogg'
	var/door_close_sound = 'modular_ss220/aesthetics/shutters/sound/shutters_close.ogg'

/obj/machinery/door/poddoor/shutters/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, door_open_sound, 30, TRUE)
		if("closing")
			flick("closing", src)
			playsound(src, door_close_sound, 30, TRUE)
