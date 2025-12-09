/datum/fluid_pipe
	/// All the connected pipes in this pipeline
	var/list/connected_pipes = list()
	/// All connected machinery in this pipeline
	var/list/machinery = list()
	/// How much space do we have in this pipe network?
	var/total_capacity = 0
	/// List with all fluids currently in the pipe
	var/list/fluids = list()

/*
 * pipe: a pipe that has this fluid_pipe datum attached to it
 * machine: any fluid pipe machinery that aren't normal pipes
 * A /machinery/fluid_pipeline should **never** be in both lists
 */
/datum/fluid_pipe/New(obj/machinery/fluid_pipe/pipe, new_capacity)
	. = ..()
	START_PROCESSING(SSfluid, src)

	if(new_capacity)
		total_capacity = new_capacity
	if(istype(pipe, /obj/structure/barrel))
		// Barrels don't need the other stuff
		return

	if(pipe.just_a_pipe)
		connected_pipes += pipe
	else
		machinery += pipe

/datum/fluid_pipe/process()
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.update_icon()

/// Adds a pipe to the datum
/datum/fluid_pipe/proc/add_pipe(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(pipe))
		return
	if(pipe.just_a_pipe)
		connected_pipes |= pipe
	else
		machinery |= pipe

	pipe.fluid_datum = src
	total_capacity += pipe.capacity

/// Removes a pipe from the datum
/datum/fluid_pipe/proc/remove_pipe(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(pipe))
		return
	if(pipe.just_a_pipe)
		connected_pipes -= pipe
	else
		machinery -= pipe

	total_capacity -= pipe.capacity

/**
  * Rebuilds the entire pipenet
  * This is necessary in the case that a pipe with more than one neighbor was removed
  * The pipe should already be removed if this proc is called, otherwise you can end up with bluespace linked pipenets
  * It first nulls the fluid datums from every pipe. This is harmless because we still have a reference to the pipes with `connected_pipes`
  * After that, we start blindly connecting pipes first, and afer that machinery (because they use the datum from the pipes)
  * In the end we loop one last time through the pipes and store unique fluid datums

  * THIS IS HIGHLY INEFFICIENT AND I HATE IT. THIS SHOULD BE CHANGED SOMEHOW BUT I DON'T KNOW HOW ATM
  * Edit as of 5 November, still slightly inefficient, but could be worse. It now chains itself through all branches
  */
/datum/fluid_pipe/proc/rebuild_pipenet(list/broken_neighbours = list())
	message_admins("OH GOD OH FUCK REBUILD PIPENET IS CALLED")
	var/list/new_pipeline_datums = list()
	// As much as it pains me, we have to do this first so we start with a clean slate and can make new pipenets
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.fluid_datum = null
		pipe.neighbors = 0

	// This has to go after the previous loop because otherwise some datums aren't nulled
	for(var/obj/machinery/fluid_pipe/pipe as anything in broken_neighbours)
		pipe.connect_chain(connected_pipes.Copy())

	for(var/obj/machinery/fluid_pipe/pipe_machinery as anything in machinery)
		pipe_machinery.blind_connect()

	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes + broken_neighbours)
		new_pipeline_datums |= pipe.fluid_datum
		pipe.update_icon()

	spread_fluids(new_pipeline_datums)
	qdel(src)

/datum/fluid_pipe/proc/spread_fluids(list/new_pipelines = list())
	for(var/datum/thing as anything in new_pipelines)
		if(QDELETED(thing))
			// Was one of these already deleted in the meantime?
			new_pipelines -= thing

	var/pipelines_to_spread_to = length(new_pipelines)

	if(pipelines_to_spread_to == 0)
		stack_trace("spread_fluids was called with no pipelines to spread over!")
		return
	if(pipelines_to_spread_to == 1)
		var/datum/fluid_pipe/pipe_datum = new_pipelines[1]
		pipe_datum.fluids = fluids
		fluids = null
		return

	for(var/datum/fluid/liquid in fluids)
		for(var/datum/fluid_pipe/piping as anything in new_pipelines)
			piping.add_fluid(liquid.type, (liquid.fluid_amount / pipelines_to_spread_to))

/datum/fluid_pipe/proc/return_percentile_full()
	if(!total_capacity)
		return
	var/fullness = get_fluid_volumes()
	fullness = (fullness / total_capacity) * 100
	return "[clamp(round(fullness, 10), 0, 100)]"

/datum/fluid_pipe/proc/icon_updates()
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.update_icon()

/datum/fluid_pipe/proc/merge(datum/fluid_pipe/pipenet)
	if(QDELETED(pipenet))
		stack_trace("`merge` was called without a pipenet to merge with. UID of src: [UID()]")
		return

	if(pipenet == src)
		// This can and will happen. Do not remove.
		return

	// Change pipes
	for(var/obj/machinery/fluid_pipe/pipe as anything in pipenet.connected_pipes)
		pipe.fluid_datum = src
	connected_pipes += pipenet.connected_pipes

	// Reconnect machinery
	for(var/obj/machinery/fluid_pipe/machine as anything in pipenet.machinery)
		machine.clear_pipenet_refs()
		machine.blind_connect()
	machinery += pipenet.machinery

	total_capacity += pipenet.total_capacity
	merge_containers(pipenet)
	qdel(pipenet)

/datum/fluid_pipe/proc/get_fluid_volumes()
	. = 0
	for(var/datum/fluid/liquid as anything in fluids)
		if(QDELETED(liquid) || liquid.fluid_amount <= 0)
			continue
		. += liquid.fluid_amount

/datum/fluid_pipe/proc/get_empty_space()
	return total_capacity - get_fluid_volumes()

/datum/fluid_pipe/proc/merge_containers(datum/fluid_pipe/pipenet)
	if(!pipenet)
		return
	if(length(pipenet.fluids) <= 0)
		return

	for(var/datum/fluid/liquid as anything in fluids)
		for(var/datum/fluid/second_liquid as anything in pipenet.fluids)
			if(istype(liquid, second_liquid))
				liquid.fluid_amount += second_liquid.fluid_amount
				pipenet.fluids -= second_liquid
				qdel(second_liquid)
				break

	// Merge the remaining unique fluids with this container
	fluids += pipenet.fluids
	return

/// Adds a fluid to this datum. Will overfill so clamp the amount before calling this proc.
/datum/fluid_pipe/proc/add_fluid(type, amount)
	if(!ispath(type))
		stack_trace("add_fluid was called with a non-typepath fluid")
		return

	var/datum/fluid/potential = is_path_in_list(type, fluids, TRUE)
	if(!potential)
		fluids += new type(amount)
	else
		potential.fluid_amount += amount

/// Removes a specific amount from a specific fluid. Returns FALSE if not enough of the fluid can be removed
/datum/fluid_pipe/proc/remove_fluid(type, amount)
	if(!ispath(type) || amount <- 0)
		return FALSE
	var/datum/fluid/potential = is_path_in_list(type, fluids, TRUE)
	if(!potential || potential.fluid_amount < amount)
		return FALSE
	potential.fluid_amount -= amount
	if(potential.fluid_amount == 0)
		qdel(potential)
	return TRUE

/// Moves liquids from `src` to `to_move_to`. Accepts both IDs and a typepath, though a path is slightly faster
/datum/fluid_pipe/proc/move_fluid(type_or_id, datum/fluid_pipe/to_move_to, amount)
	if(QDELETED(to_move_to) || !type_or_id)
		return
	if(amount <= 0)
		stack_trace("`move_fluid` was called with an amount smaller than or equal to 0")
		return

	var/datum/fluid/liquid = type_or_id
	if(!ispath(type_or_id, /datum/fluid))
		liquid = GLOB.fluid_id_to_path[type_or_id]
		if(!ispath(liquid))
			return

	var/datum/fluid/temp_type = liquid

	liquid = is_path_in_list(liquid, fluids, TRUE)
	if(!liquid)
		return

	amount = clamp(amount, 0, liquid.fluid_amount)
	liquid.fluid_amount -= amount
	to_move_to.add_fluid(temp_type, amount)

	if(!liquid.fluid_amount)
		fluids -= liquid
		qdel(liquid)

/datum/fluid_pipe/proc/move_any_fluid(datum/fluid_pipe/to_move_to, amount)
	if(QDELETED(to_move_to))
		return
	if(amount <= 0)
		stack_trace("`move_any_fluid` was called with an amount smaller than or equal to 0")
		return

	var/datum/fluid/liquid = pick(fluids)
	if(!liquid)
		return

	amount = clamp(amount, liquid.fluid_amount, to_move_to.get_empty_space())
	liquid.fluid_amount -= amount
	to_move_to.add_fluid(liquid.type, amount)

/// Simple wrapper to quickly remove all fluids from the datum
/datum/fluid_pipe/proc/clear_fluids()
	QDEL_LIST_CONTENTS(fluids)

/datum/fluid_pipe/proc/fluid_explosion(obj/machinery/fluid_pipe/pipe, severity)
	var/explode_fluid_amount = 0
	var/explode_fluid_severity = 0
	// How much fluid is in this pipe?
	// This is the ratio of fluids that we remove from the total amounts so we simulate "realistical" thermodynamics
	var/ratio_removal = 1 - ((pipe.capacity / total_capacity) * 2)

	for(var/datum/fluid/liquid in fluids)
		if(!liquid.explosion_value)
			continue
		explode_fluid_severity += liquid.explosion_value
		explode_fluid_amount += liquid.fluid_amount
		liquid.fluid_amount = round(liquid.fluid_amount * ratio_removal, 1) // This will probably get off-by-1 errors but the entire pipeline will probably explode, who cares

	// Each unit of explosive counts for 1% (otherwise the numbers get quite silly)
	var/total_severity = explode_fluid_amount * 0.01 * ratio_removal * explode_fluid_severity
	message_admins(total_severity)
	total_severity = round(total_severity / 3, 1)
	explosion(get_turf(pipe), total_severity, total_severity, total_severity)
