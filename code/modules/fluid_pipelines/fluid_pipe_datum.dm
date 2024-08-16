/datum/fluid_pipe
	/// The fluid datum reference
	var/datum/fluid
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
	SSfluid.running_datums += src

	if(!fluid)
		fluid = new()

	if(pipe.just_a_pipe)
		connected_pipes += pipe
	else
		machinery += pipe

/datum/fluid_pipe/proc/add_pipe(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(pipe))
		return
	if(pipe.just_a_pipe)
		connected_pipes += pipe
	else
		machinery += pipe

	total_capacity += pipe.capacity

/datum/fluid_pipe/proc/remove_pipe(obj/machinery/fluid_pipe/pipe)
	if(QDELETED(pipe))
		return
	if(pipe.just_a_pipe)
		connected_pipes -= pipe
	else
		machinery -= pipe

	total_capacity -= pipe.capacity

/datum/fluid_pipe/proc/rebuild_pipenet()
	var/list/new_pipeline_datum = list()
	// As much as it pains me, we have to do this first so we start with a clean slate and can make new pipenets
	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.fluid_datum = null

	for(var/obj/machinery/fluid_pipe/pipe as anything in connected_pipes)
		pipe.blind_connect()
		new_pipeline_datum |= pipe.fluid_datum
	for(var/obj/machinery/fluid_pipe/pipe_machinery as anything in machinery)
		pipe_machinery.blind_connect()

	spread_fluids(new_pipeline_datum)

/datum/fluid_pipe/proc/spread_fluids(list/new_pipelines)
	message_admins("Length of new pipelines list: [length(new_pipelines)]") // DEBUG
	switch(length(new_pipelines))
		if(0)
			stack_trace("spread_fluids was called with no pipelines to spread over!")
			return
		if(1)
			var/datum/fluid_pipe/pipe_datum = new_pipelines[1]
			pipe_datum.fluid = fluid
			fluid = null
			return

	var/total_pipes = 0
	for(var/i in 1 to length(new_pipelines))
		total_pipes += length(new_pipelines[i])

	for(var/datum/fluid_pipe as anything in new_pipelines) // First I need to flesh out the fluid datums
		continue
