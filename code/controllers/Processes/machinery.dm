/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 20 // every 2 seconds
	start_delay = 12

/datum/controller/process/machinery/statProcess()
	..()
	stat(null, "[machines.len] machines")
	stat(null, "[powernets.len] powernets")

/datum/controller/process/machinery/doWork()
	process_power()
	process_machines()

/datum/controller/process/machinery/proc/process_machines()
	for(var/obj/machinery/M in machines)
		if(M && isnull(M.gcDestroyed))
			#ifdef PROFILE_MACHINES
			var/time_start = world.timeofday
			#endif

			try
				if(M.process() == PROCESS_KILL)
					//M.inMachineList = 0 We don't use this debugging function
					machines.Remove(M)
					continue

				if(M && M.use_power)
					M.auto_use_power()
			catch(var/exception/e)
				catchException(e, M)

			#ifdef PROFILE_MACHINES
			var/time_end = world.timeofday

			if(!(M.type in machine_profiling))
				machine_profiling[M.type] = 0

			machine_profiling[M.type] += (time_end - time_start)
			#endif
		else
			machines -= M

		scheck()

/datum/controller/process/machinery/proc/process_power()
	for(var/datum/powernet/powerNetwork in powernets)
		if(istype(powerNetwork) && isnull(powerNetwork.gcDestroyed))
			try
				powerNetwork.reset()
			catch(var/exception/e)
				catchException(e, powerNetwork)
			// Use src explicitly after a try/catch, or BYOND messes src up. I have no idea why.
			src.scheck()
			continue
		else
			powernets -= powerNetwork
