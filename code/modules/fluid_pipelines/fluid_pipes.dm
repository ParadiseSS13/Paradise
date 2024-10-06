/obj/machinery/fluid_pipe
	name = "fluid pipe"
	desc = "Moves around fluids"
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pipe-j1" // If you see this iconstate something went wrong
	power_state = NO_POWER_USE
	flags_2 = NO_MALF_EFFECT_2
	anchored = TRUE
	/// The pipe datum connected to this pipe
	var/datum/fluid_pipe/fluid_datum
	/// Is this fluid machinery or just a pipe
	var/just_a_pipe = TRUE
	/// How many neighbours do we have? `DO NOT VAREDIT THIS`
	var/neighbours = 0
	/// How much fluid units can we fit in this pipe?
	var/capacity = 100

/obj/machinery/fluid_pipe/Initialize(mapload)
	. = ..()
	blind_connect()

/obj/machinery/fluid_pipe/Destroy()
	. = ..()
	fluid_datum?.remove_pipe(src)
	disconnect_pipe()

/// Basic icon state handling for pipes, will automatically connect to adjacent pipes, no hassle needed
/obj/machinery/fluid_pipe/update_icon_state()
	var/temp_state = "pipe"
	for(var/direction in GLOB.cardinal)
		for(var/obj/machinery/fluid_pipe/pipe in get_step(src, direction))
			temp_state += "_[direction]"

	icon_state = temp_state

/obj/machinery/fluid_pipe/proc/connect_pipes(obj/machinery/fluid_pipe/pipe_to_connect_to)
	if(QDELETED(pipe_to_connect_to))
		return

	message_admins(fluid_datum)
	message_admins("other pipe [pipe_to_connect_to.fluid_datum]")
	if(!pipe_to_connect_to.fluid_datum)
		if(!fluid_datum)
			fluid_datum = new(src)
		fluid_datum.add_pipe(pipe_to_connect_to)
	else
		pipe_to_connect_to.fluid_datum.add_pipe(src)

	neighbours++
	pipe_to_connect_to.neighbours++
	fluid_datum.icon_updates()

/obj/machinery/fluid_pipe/proc/disconnect_pipe()
	if(QDELETED(src))
		return
	if(neighbours <= 1) // Sad and alone
		fluid_datum = null
		return

	fluid_datum.connected_pipes -= src
	var/datum/fluid_pipe/temp_datum = fluid_datum
	fluid_datum = null
	qdel(src) // Forcefully delete ourselves so we don't reconnect to us again by accident
	temp_datum.rebuild_pipenet()

/// Want to connect a pipe to other pipes, but don't know where the other pipes are?
/obj/machinery/fluid_pipe/proc/blind_connect()
	for(var/direction in GLOB.cardinal)
		for(var/obj/machinery/fluid_pipe/pipe in get_step(src, direction))
			if(pipe && pipe.anchored)
				pipe.connect_pipes(src) // The reason for this is so we can override the behaviour on pumps
									// so we can make them reconsider all of their connections every time they are connected
				return

	update_icon_state()

/obj/machinery/fluid_pipe/attack_hand(mob/user)
	. = ..()
	if(anchored)
		return
	dir = turn(dir, -90)

/obj/machinery/fluid_pipe/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "You start [anchored ? "un" : ""]wrenching [src].")
	if(!do_after(user, 3 SECONDS, TRUE, src))
		to_chat(user, "You stop.") // TODO: add span classes + message
		return

	if(!anchored)
		blind_connect()
	else
		disconnect_pipe()

/obj/machinery/fluid_pipe/update_overlays()
	. = ..()
	. += mutable_appearance('icons/obj/pipes/fluid_pipes.dmi', fluid_datum.return_percentile_full())
