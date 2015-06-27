var/global/list/power_machinery_profiling = list()

/datum/controller/process/power_machinery
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/power_machinery/setup()
	name = "pow_machine"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/power_machinery/doWork()
	for(var/obj/machinery/M in power_machines)
		if(istype(M) && isnull(M.gcDestroyed))
			#ifdef PROFILE_MACHINES
			var/time_start = world.timeofday
			#endif

			if(M.process() == PROCESS_KILL)
				M.inMachineList = 0
				power_machines -= M
				continue

			if(M && M.use_power)
				M.auto_use_power()
			if(istype(M))
				#ifdef PROFILE_MACHINES
				var/time_end = world.timeofday

				if(!(M.type in power_machinery_profiling))
					power_machinery_profiling[M.type] = 0

				power_machinery_profiling[M.type] += (time_end - time_start)
				#endif
			else
				power_machines -= M
		else
			if(istype(M))
				M.inMachineList = 0
			power_machines -= M

		scheck()
