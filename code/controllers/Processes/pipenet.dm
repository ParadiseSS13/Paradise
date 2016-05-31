/datum/controller/process/pipenet/setup()
	name = "pipenet"
	schedule_interval = 20 // every 2 seconds
	start_delay = 18

/datum/controller/process/pipenet/statProcess()
	..()
	stat(null, "[pipe_networks.len] pipe nets, [deferred_pipenet_rebuilds.len] deferred")

/datum/controller/process/pipenet/doWork()
	for(last_object in deferred_pipenet_rebuilds)
		var/obj/machinery/atmospherics/M = last_object
		if(istype(M) && isnull(M.gcDestroyed))
			try
				M.build_network()
			catch(var/exception/e)
				catchException(e, M)
			SCHECK
		else
			catchBadType(M)
		deferred_pipenet_rebuilds -= M

	for(last_object in pipe_networks)
		var/datum/pipeline/pipeNetwork = last_object
		if(istype(pipeNetwork) && isnull(pipeNetwork.gcDestroyed))
			try
				pipeNetwork.process()
			catch(var/exception/e)
				catchException(e, pipeNetwork)
			SCHECK
		else
			catchBadType(pipeNetwork)
			pipe_networks -= pipeNetwork
