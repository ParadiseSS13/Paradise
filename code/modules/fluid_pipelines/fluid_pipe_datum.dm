/datum/fluid_pipe
	/// The fluid datum reference
	var/datum/fluid
	/// All the connected pipes in this pipeline
	var/list/connected_pipes = list()
	/// All connected machinery in this pipeline
	var/list/machinery = list()

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
