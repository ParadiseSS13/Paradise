/obj/machinery/door/poddoor
	icon = 'modular_ss220/aesthetics/blastdoor/icons/blastdoor.dmi'

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'modular_ss220/aesthetics/blastdoor/sound/blastdoor.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'modular_ss220/aesthetics/blastdoor/sound/blastdoor.ogg', 30, 1)
