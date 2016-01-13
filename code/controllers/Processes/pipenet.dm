/datum/controller/process/pipenet/setup()
	name = "pipenet"
	schedule_interval = 20 // every 2 seconds
	start_delay = 18

/datum/controller/process/pipenet/statProcess()
	..()
	stat(null, "[pipe_networks.len] pipe nets")

/datum/controller/process/pipenet/doWork()
	for(last_object in pipe_networks)
		var/datum/pipeline/pipeNetwork = last_object
		if(istype(pipeNetwork) && isnull(pipeNetwork.gcDestroyed))
			try
				pipeNetwork.process()
			catch(var/exception/e)
				catchException(e, pipeNetwork)
			SCHECK
			continue
		else
			catchBadType(pipeNetwork)
			pipe_networks -= pipeNetwork
