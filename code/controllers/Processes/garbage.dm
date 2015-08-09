/datum/controller/process/garbage_collector/setup()
	name = "garbage"
	schedule_interval = 10
	start_delay = 3

	garbageCollector = src

/datum/controller/process/garbage_collector/doWork()
	// Garbage collection code can be found in code\modules\garbage collection\garbage_collector.dm
	processGarbage()

/datum/controller/process/garbage_collector/statProcess()
	..()
	stat(null, "[del_everything ? "Off" : "On"], [queue.len] queued")
	stat(null, "Dels: [dels_count], [soft_dels] soft, [hard_dels] hard")
