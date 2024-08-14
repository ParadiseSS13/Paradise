/obj/machinery/fluid_pipe
	name = "fluid pipe"
	desc = "Moves around fluids"
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pipe-j1" // If you see this iconstate something went wrong
	power_state = NO_POWER_USE
	flags_2 = NO_MALF_EFFECT_2
	/// The pipe datum connected to this pipe
	var/datum/fluid_pipe/fluid_pipe
	/// Is this fluid machinery or just a pipe
	var/just_a_pipe = TRUE

/obj/machinery/fluid_pipe/Initialize(mapload)
	. = ..()
	for(var/direction in GLOB.cardinal)
		var/obj/machinery/fluid_pipe/pipe = locate(/obj/machinery/fluid_pipe) in get_step(src, direction)
		if(!pipe)
			continue
		connect_pipes(pipe)
	update_icon_state()

/// Basic icon state handling for pipes, will automatically connect to adjacent pipes, no hassle needed
/obj/machinery/fluid_pipe/update_icon_state()
	var/temp_state = "pipe"
	for(var/direction in GLOB.cardinal)
		var/obj/machinery/fluid_pipe/pipe = locate(/obj/machinery/fluid_pipe) in get_step(src, direction)
		if(pipe)
			temp_state += "_[direction]"

	icon_state = temp_state

/obj/machinery/fluid_pipe/proc/connect_pipes(obj/machinery/fluid_pipe/pipe_to_connect_to)
	if(QDELETED(pipe_to_connect_to))
		return
	if(isnull(pipe_to_connect_to.fluid_pipe))
		fluid_pipe = new(src)
		fluid_pipe.add_pipe(pipe_to_connect_to)

	update_icon_state()
	pipe_to_connect_to.update_icon_state()
