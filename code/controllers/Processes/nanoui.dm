/datum/controller/process/nanoui

/datum/controller/process/nanoui/setup()
	name = "nanoui"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/nanoui/statProcess()
	..()
	stat(null, "[nanomanager.processing_uis.len] UIs")

/datum/controller/process/nanoui/doWork()
	for(var/datum/nanoui/NUI in nanomanager.processing_uis)
		if(istype(NUI) && isnull(NUI.gcDestroyed))
			try
				NUI.process()
			catch(var/exception/e)
				catchException(e, NUI)
		else
			nanomanager.processing_uis -= NUI
