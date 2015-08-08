/var/global/machinery_sort_required = 0

/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 20 // every 2 seconds
	start_delay = 12

/datum/controller/process/machinery/statProcess()
	..()
	stat(null, "[machines.len] machines")
	stat(null, "[powernets.len] powernets")

/datum/controller/process/machinery/doWork()
	process_sort()
	process_power()
	process_power_drain()
	process_machines()

/datum/controller/process/machinery/proc/process_sort()
	if(machinery_sort_required)
		machinery_sort_required = 0
		machines = dd_sortedObjectList(machines)
	
/datum/controller/process/machinery/proc/process_machines()
	for(last_object in machines)
		var/obj/machinery/M = last_object
		if(istype(M) && isnull(M.gcDestroyed))
			#ifdef PROFILE_MACHINES
			var/time_start = world.timeofday
			#endif

			try
				if(M.process() == PROCESS_KILL)
					machines.Remove(M)
					continue

				if(M.use_power)
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
			catchBadType(M)
			machines -= M

		SCHECK_EVERY(100)

/datum/controller/process/machinery/proc/process_power()
	for(last_object in powernets)
		var/datum/powernet/powerNetwork = last_object
		if(istype(powerNetwork) && isnull(powerNetwork.gcDestroyed))
			try
				powerNetwork.reset()
			catch(var/exception/e)
				catchException(e, powerNetwork)
			SCHECK
			continue
			
		powernets.Remove(powerNetwork)
		
/datum/controller/process/machinery/proc/process_power_drain()
	// Currently only used by powersinks. These items get priority processed before machinery
	for(var/obj/item/I in processing_power_items)
		if(!I.pwr_drain()) // 0 = Process Kill, remove from processing list.
			processing_power_items.Remove(I)
		SCHECK
