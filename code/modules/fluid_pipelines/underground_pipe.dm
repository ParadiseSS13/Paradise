/obj/machinery/fluid_pipe/underground_pipe
	name = "underground pipe"
	desc = "Connects automatically to other underground pipes up to 5 tiles away."
	icon_state = "underground"
	dir = EAST

/obj/machinery/fluid_pipe/underground_pipe/Initialize(mapload)
	. = ..()
	connect_dirs = list(REVERSE_DIR(dir))

/obj/machinery/fluid_pipe/underground_pipe/blind_connect()
	for(var/obj/machinery/fluid_pipe/pipe in get_adjacent_pipes())
		pipe.connect_pipes(src)
	var/turf/end_turf = get_step(src, dir)
	for(var/i in 1 to 4) // 5 tiles away
		end_turf = get_step(end_turf, dir)
	var/list/turflist = get_line(get_step(src, dir), end_turf)
	for(var/turf/turf as anything in turflist)
		for(var/obj/machinery/fluid_pipe/underground_pipe/underground in turf)
			underground.connect_pipes(src)
			return

/obj/machinery/fluid_pipe/underground_pipe/attack_hand(mob/user)
	if(..())
		return
	connect_dirs = list(REVERSE_DIR(dir)) // Only connect to the normal pipe behind us

/obj/machinery/fluid_pipe/underground_pipe/update_icon_state()
	return

/obj/machinery/fluid_pipe/underground_pipe/north
	dir = NORTH

/obj/machinery/fluid_pipe/underground_pipe/south
	dir = SOUTH

/obj/machinery/fluid_pipe/underground_pipe/west
	dir = WEST
