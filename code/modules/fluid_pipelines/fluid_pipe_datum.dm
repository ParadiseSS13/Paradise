/datum/fluid_pipe
	/// The fluid container datum reference
	var/datum/fluid_container/fluid_container
	/// All the connected pipes in this pipeline
	var/list/connected_pipes = list()
	/// All connected machinery in this pipeline
	var/list/machinery = list()
	/// How much space do we have in this pipe network?
	var/total_capacity = 0

/*
 * pipe: a pipe that has this fluid_pipe datum attached to it
 * machine: any fluid pipe machinery that aren't normal pipes
 * A /machinery/fluid_pipeline should **never** be in both lists
 */

/datum/fluid_pipe/New(obj/machinery/fluid_pipe/pipe)
	. = ..()
	START_PROCESSING(SSfluid, src)

	if(!fluid_container)
		fluid_container = new()

	if(pipe.just_a_pipe)
		connected_pipes += pipe
	else
		machinery += pipe

/datum/fluid_pipe/process()
	for(var/obj/machinery/machine as anything in machinery)
		machine.process()

	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.process()
		pipe.update_icon()

/// Adds a pipe to the datum
/datum/fluid_pipe/proc/add_pipe(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(pipe))
		return
	if(pipe.just_a_pipe)
		connected_pipes += pipe
	else
		machinery += pipe

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
  */
/datum/fluid_pipe/proc/rebuild_pipenet()
	var/list/new_pipeline_datums = list()
	// As much as it pains me, we have to do this first so we start with a clean slate and can make new pipenets
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.fluid_datum = null
		pipe.neighbours = 0

	// This has to go after the previous loop because otherwise some datums aren't nulled
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.blind_connect()

	for(var/obj/machinery/fluid_pipe/pipe_machinery as anything in machinery)
		pipe_machinery.blind_connect()

	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		new_pipeline_datums |= pipe.fluid_datum

	spread_fluids(new_pipeline_datums)
	qdel(src)

/datum/fluid_pipe/proc/spread_fluids(list/new_pipelines = list())
	var/pipelines_to_spread_to = length(new_pipelines)
	message_admins("Length of new pipelines list: [pipelines_to_spread_to]") // DEBUG
	switch(pipelines_to_spread_to)
		if(0)
			stack_trace("spread_fluids was called with no pipelines to spread over!")
			return
		if(1)
			var/datum/fluid_pipe/pipe_datum = new_pipelines[1]
			pipe_datum.fluid_container = fluid_container
			fluid_container = null
			return

	for(var/datum/fluid/liquid in fluid_container.fluids)
		for(var/datum/fluid_pipe/piping as anything in new_pipelines)
			piping.fluid_container.add_fluid(liquid.type, (liquid.fluid_amount / pipelines_to_spread_to))

/datum/fluid_pipe/proc/return_percentile_full()
	var/fullness = fluid_container.get_fluid_volumes()
	fullness = (fullness / total_capacity) * 100
	return "[clamp(round(fullness, 10), 0, 100)]"

/datum/fluid_pipe/proc/icon_updates()
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.update_icon()

/datum/fluid_pipe/proc/merge(datum/fluid_pipe/pipenet)
	if(QDELETED(pipenet))
		stack_trace("`merge` was called without a pipenet to merge with. UID of src: [UID()]")
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
	fluid_container.merge_containers(pipenet.fluid_container)
