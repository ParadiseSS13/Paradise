/obj/machinery/fluid_pipe/tank
	name = "tank"
	desc = "Stores liquids. Good for a total storage of 1000."
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "tank"
	just_a_pipe = FALSE
	capacity = 1000

/obj/machinery/fluid_pipe/tank/update_icon_state()
	return

/obj/machinery/fluid_pipe/tank/update_overlays()
	. = ..()
	for(var/obj/machinery/fluid_pipe/pipe as anything in get_adjacent_pipes())
		. += "conn_[get_dir(src, pipe)]"
