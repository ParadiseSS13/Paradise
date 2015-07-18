var/global/list/object_profiling = list()
/datum/controller/process/obj

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
	for(var/obj/O in processing_objects)
		if(istype(O) && isnull(O.gcDestroyed))
			try
				O.process()
			catch(var/exception/e)
				catchException(e, O)
			// Use src explicitly after a try/catch, or BYOND messes src up. I have no idea why.
			src.scheck()
		else
			processing_objects -= O