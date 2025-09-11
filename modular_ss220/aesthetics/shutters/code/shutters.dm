/obj/machinery/door/poddoor/shutters
	icon = 'modular_ss220/aesthetics/shutters/icons/shutters.dmi'
	layer = CLOSED_BLASTDOOR_LAYER
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

/obj/machinery/door/poddoor/shutters/window
	name = "windowed shutters"
	desc = "A shutter with a thick see-through polycarbonate window."
	icon = 'modular_ss220/aesthetics/shutters/icons/shutters_glass.dmi'
	icon_state = "closed"
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/poddoor/shutters/window/preopen
	icon_state = "open"
	density = FALSE
