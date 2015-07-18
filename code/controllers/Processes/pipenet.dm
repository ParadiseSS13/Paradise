/datum/controller/process/pipenet/setup()
	name = "pipenet"
	schedule_interval = 20 // every 2 seconds
	start_delay = 18

/datum/controller/process/pipenet/statProcess()
	..()
	stat(null, "[pipe_networks.len] pipe nets")

/datum/controller/process/pipenet/doWork()
	for(var/datum/pipe_network/pipeNetwork in pipe_networks)
		if(istype(pipeNetwork) && isnull(pipeNetwork.gcDestroyed))
			try
				pipeNetwork.process()
			catch(var/exception/e)
				catchException(e, pipeNetwork)
			// Use src explicitly after a try/catch, or BYOND messes src up. I have no idea why.
			src.scheck()
			continue
		else
			pipe_networks -= pipeNetwork
