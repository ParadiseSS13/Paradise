/datum/controller/process/obj/setup()
	name = "obj"
	schedule_interval = 20 // every 2 seconds
	start_delay = 8

/datum/controller/process/obj/started()
	..()
	if(!processing_objects)
		processing_objects = list()

/datum/controller/process/obj/statProcess()
	..()
	stat(null, "[processing_objects.len] objects")

/datum/controller/process/obj/doWork()
	for(last_object in processing_objects)
		var/datum/O = last_object
		if(istype(O) && !QDELETED(O))
			try
				// Reagent datums get shoved in here, but the process proc isn't on the
				//  base datum type, so we just call it blindly.
				O:process()
			catch(var/exception/e)
				catchException(e, O)
			SCHECK
		else
			catchBadType(O)
			processing_objects -= O
