/var/global/machinery_sort_required = 0

/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 20 // every 2 seconds
	start_delay = 12

/datum/controller/process/machinery/statProcess()
	..()
	stat(null, "[machine_processing.len] machines")
	stat(null, "[powernets.len] powernets, [deferred_powernet_rebuilds.len] deferred")

/datum/controller/process/machinery/doWork()
	process_sort()
	process_power()
	process_power_drain()
	process_machines()

/datum/controller/process/machinery/proc/process_sort()
	if(machinery_sort_required)
		machinery_sort_required = 0
		machine_processing = dd_sortedObjectList(machine_processing)

/datum/controller/process/machinery/proc/process_machines()
	for(last_object in machine_processing)
		var/obj/machinery/M = last_object
		if(istype(M) && isnull(M.gcDestroyed))
			try
				if(M.process() == PROCESS_KILL)
					machine_processing.Remove(M)
					continue

				if(M.use_power)
					M.auto_use_power()
			catch(var/exception/e)
				catchException(e, M)
		else
			catchBadType(M)
			machine_processing -= M

		SCHECK_EVERY(100)

/datum/controller/process/machinery/proc/process_power()
	for(last_object in deferred_powernet_rebuilds)
		var/obj/O = last_object
		if(istype(O) && isnull(O.gcDestroyed))
			try
				var/datum/powernet/newPN = new()// creates a new powernet...
				propagate_network(O, newPN)//... and propagates it to the other side of the cable
			catch(var/exception/e)
				catchException(e, O)
			SCHECK
		else
			catchBadType(O)
		deferred_powernet_rebuilds -= O

	for(last_object in powernets)
		var/datum/powernet/powerNetwork = last_object
		if(istype(powerNetwork) && isnull(powerNetwork.gcDestroyed))
			try
				powerNetwork.reset()
			catch(var/exception/e)
				catchException(e, powerNetwork)
			SCHECK
		else
			catchBadType(powerNetwork)
			powernets -= powerNetwork

/datum/controller/process/machinery/proc/process_power_drain()
	// Currently only used by powersinks. These items get priority processed before machinery
	for(var/obj/item/I in processing_power_items)
		if(!I.pwr_drain()) // 0 = Process Kill, remove from processing list.
			processing_power_items.Remove(I)
		SCHECK
