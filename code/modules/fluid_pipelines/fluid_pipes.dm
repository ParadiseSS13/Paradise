/obj/machinery/fluid_pipe
	name = "fluid pipe"
	desc = "Moves around fluids"
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pipe_2_4"
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
	START_PROCESSING(SSfluid, src)

/obj/machinery/fluid_pipe/Destroy()
	disconnect_pipe()
	return ..()

/obj/machinery/fluid_pipe/process()
	return PROCESS_KILL

/// Basic icon state handling for pipes, will automatically connect to adjacent pipes, no hassle needed
/obj/machinery/fluid_pipe/update_icon_state()
	var/temp_state = "pipe"
	for(var/direction in GLOB.cardinal)
		for(var/obj/machinery/fluid_pipe/pipe in get_step(src, direction))
			temp_state += "_[direction]"

	icon_state = temp_state

// This is currently as clean as I could make it
/obj/machinery/fluid_pipe/proc/connect_pipes(obj/machinery/fluid_pipe/pipe_to_connect_to)
	if(QDELETED(pipe_to_connect_to))
		return

	if(isnull(fluid_datum) && pipe_to_connect_to.fluid_datum)
		pipe_to_connect_to.fluid_datum.add_pipe(src)

	else if(fluid_datum && pipe_to_connect_to.fluid_datum)
		if(fluid_datum != pipe_to_connect_to.fluid_datum)
			fluid_datum.merge(pipe_to_connect_to.fluid_datum)

	else if(isnull(pipe_to_connect_to.fluid_datum))
		if(!fluid_datum)
			fluid_datum = new(src)
		fluid_datum.add_pipe(pipe_to_connect_to)

	update_neighbours()
	pipe_to_connect_to.update_neighbours()

	update_icon()
	pipe_to_connect_to.update_icon()

/obj/machinery/fluid_pipe/proc/connect_chain(list/all_pipes = list())
	all_pipes -= src
	if(!length(all_pipes))
		return

	var/list/nearby_pipes = all_pipes & orange(1, src)
	for(var/obj/machinery/fluid_pipe/pipe as anything in nearby_pipes)
		if(!(get_dir(src, pipe) in GLOB.cardinal))
			continue
		if(pipe.fluid_datum) // Already connected, don't connect again
			if(fluid_datum != pipe.fluid_datum)
				fluid_datum.merge(pipe.fluid_datum)
			if(QDELETED(fluid_datum)) // Should theoretically only be called on the first pipe this proc is called on
				pipe.fluid_datum.add_pipe(src)

			update_neighbours()
			pipe.update_neighbours()
			continue

		if(QDELETED(fluid_datum)) // Should theoretically only be called on the first pipe this proc is called on
			fluid_datum = new()

		fluid_datum.add_pipe(pipe)
		update_neighbours()
		pipe.update_neighbours()

		// Normally you'd update icons here, however we do that at the end otherwise lag may happen
		pipe.connect_chain(all_pipes)

/obj/machinery/fluid_pipe/proc/disconnect_pipe()
	if(neighbours <= 1) // Sad and alone
		fluid_datum = null
		return

	message_admins("WE ARE HERE AAAAA")
	SSfluid.datums_to_rebuild += list(list(fluid_datum, get_adjacent_pipes()))
	fluid_datum.remove_pipe(src)
	fluid_datum = null

/// Want to connect a pipe to other pipes, but don't know where the other pipes are?
/obj/machinery/fluid_pipe/proc/blind_connect()
	for(var/obj/machinery/fluid_pipe/pipe as anything in get_adjacent_pipes())
		pipe.connect_pipes(src) // The reason for this is so we can override the behaviour on pumps
								// so we can make them reconsider all of their connections every time they are connected

	update_icon()

/obj/machinery/fluid_pipe/proc/update_neighbours()
	neighbours = length(get_adjacent_pipes())

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
		// TODO: add item pipe here and make a new one
		qdel(src)

/obj/machinery/fluid_pipe/update_overlays()
	. = ..()
	. += fluid_datum.return_percentile_full()

/// Clears out the pipenet datum references. Override if your machinery holds more references
/obj/machinery/fluid_pipe/proc/clear_pipenet_refs()
	SHOULD_CALL_PARENT(TRUE)
	fluid_datum = null

/obj/machinery/fluid_pipe/proc/get_adjacent_pipes()
	. = list()
	for(var/direction in GLOB.cardinal)
		for(var/obj/machinery/fluid_pipe/pipe in get_step(src, direction))
			if(pipe.anchored && !QDELING(pipe))
				. += pipe

// Abstract fluid pipes, useful for machinery that can have multiple intake slots
/obj/machinery/fluid_pipe/abstract
	name = "You should not see this"
	desc = "Please report where you saw this on the github"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = null
	icon_state = null

/obj/machinery/fluid_pipe/abstract/update_icon_state()
	return
