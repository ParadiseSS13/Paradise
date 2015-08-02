/var/global/machinery_sort_required = 0

/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 20 // every 2 seconds

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
	for(var/obj/machinery/M in machines)
		if(M && isnull(M.gcDestroyed))
			#ifdef PROFILE_MACHINES
			var/time_start = world.timeofday
			#endif

			if(M.process() == PROCESS_KILL)
				//M.inMachineList = 0 We don't use this debugging function
				machines.Remove(M)
				continue

			if(M && M.use_power)
				M.auto_use_power()

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
			powerNetwork.reset()
			scheck()
			continue
			
		powernets.Remove(powerNetwork)
		
/datum/controller/process/machinery/proc/process_power_drain()
	// Currently only used by powersinks. These items get priority processed before machinery
	for(var/obj/item/I in processing_power_items)
		if(!I.pwr_drain()) // 0 = Process Kill, remove from processing list.
			processing_power_items.Remove(I)
		scheck()
