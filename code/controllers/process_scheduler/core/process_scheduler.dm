// Singleton instance of game_controller_new, setup in world.New()
var/global/datum/controller/processScheduler/processScheduler

/datum/controller/processScheduler
	// Processes known by the scheduler
	var/tmp/datum/controller/process/list/processes = new

	// Processes that are currently running
	var/tmp/datum/controller/process/list/running = new

	// Processes that are idle
	var/tmp/datum/controller/process/list/idle = new

	// Processes that are queued to run
	var/tmp/datum/controller/process/list/queued = new

	// Process name -> process object map
	var/tmp/datum/controller/process/list/nameToProcessMap = new

	// Process last queued times (world time)
	var/tmp/datum/controller/process/list/last_queued = new

	// How long to sleep between runs (set to tick_lag in New)
	var/tmp/scheduler_sleep_interval

	// Controls whether the scheduler is running or not
	var/tmp/isRunning = 0

	// Setup for these processes will be deferred until all the other processes are set up.
	var/tmp/list/deferredSetupList = new

/datum/controller/processScheduler/New()
	..()
	// When the process scheduler is first new'd, tick_lag may be wrong, so these
	//  get re-initialized when the process scheduler is started.
	// (These are kept here for any processes that decide to process before round start)
	scheduler_sleep_interval = world.tick_lag

/datum/controller/processScheduler/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/**
 * deferSetupFor
 * @param path processPath
 * If a process needs to be initialized after everything else, add it to
 * the deferred setup list. On goonstation, only the ticker needs to have
 * this treatment.
 */
/datum/controller/processScheduler/proc/deferSetupFor(var/processPath)
	if(!(processPath in deferredSetupList))
		deferredSetupList += processPath

/datum/controller/processScheduler/proc/setup()
	// There can be only one
	if(processScheduler && (processScheduler != src))
		qdel(src)
		return 0

	var/process
	// Add all the processes we can find, except for the ticker
	for(process in subtypesof(/datum/controller/process))
		if(!(process in deferredSetupList))
			addProcess(new process(src))

	for(process in deferredSetupList)
		addProcess(new process(src))

/datum/controller/processScheduler/proc/start()
	isRunning = 1
	// tick_lag will have been set by now, so re-initialize these
	scheduler_sleep_interval = world.tick_lag
	updateStartDelays()
	spawn(0)
		process()

/datum/controller/processScheduler/proc/process()
	while(isRunning)
		checkRunningProcesses()
		queueProcesses()
		runQueuedProcesses()
		sleep(scheduler_sleep_interval)

/datum/controller/processScheduler/proc/stop()
	isRunning = 0

/datum/controller/processScheduler/proc/checkRunningProcesses()
	for(var/datum/controller/process/p in running)
		p.update()

		if(isnull(p)) // Process was killed
			continue

		var/status = p.getStatus()
		var/previousStatus = p.getPreviousStatus()

		// Check status changes
		if(status != previousStatus)
			//Status changed.
			switch(status)
				if(PROCESS_STATUS_PROBABLY_HUNG)
					message_admins("Process '[p.name]' may be hung.")
				if(PROCESS_STATUS_HUNG)
					message_admins("Process '[p.name]' is hung and will be restarted.")

/datum/controller/processScheduler/proc/queueProcesses()
	for(var/datum/controller/process/p in processes)
		// Don't double-queue, don't queue running processes
		if(p.disabled || p.running || p.queued || !p.idle)
			continue

		// If the process should be running by now, go ahead and queue it
		if(world.time >= last_queued[p] + p.schedule_interval)
			setQueuedProcessState(p)

/datum/controller/processScheduler/proc/runQueuedProcesses()
	for(var/datum/controller/process/p in queued)
		runProcess(p)

/datum/controller/processScheduler/proc/addProcess(var/datum/controller/process/process)
	processes.Add(process)
	process.idle()
	idle.Add(process)

	process.assertGlobality()
	// Set up process
	process.setup()

	// Save process in the name -> process map
	nameToProcessMap[process.name] = process

/datum/controller/processScheduler/proc/replaceProcess(var/datum/controller/process/oldProcess, var/datum/controller/process/newProcess)
	processes.Remove(oldProcess)
	processes.Add(newProcess)

	oldProcess.releaseGlobality()
	newProcess.assertGlobality()
	newProcess.idle()
	idle.Remove(oldProcess)
	running.Remove(oldProcess)
	queued.Remove(oldProcess)
	idle.Add(newProcess)

	newProcess.last_run_time = oldProcess.last_run_time
	newProcess.last_twenty_run_times = oldProcess.last_twenty_run_times
	newProcess.highest_run_time = oldProcess.highest_run_time

	nameToProcessMap[newProcess.name] = newProcess

/datum/controller/processScheduler/proc/updateStartDelays()
	for(var/datum/controller/process/p in processes)
		if(p.start_delay)
			last_queued[p] = world.time - p.start_delay

/datum/controller/processScheduler/proc/runProcess(var/datum/controller/process/process)
	spawn(0)
		process.process()

/datum/controller/processScheduler/proc/processStarted(var/datum/controller/process/process)
	setRunningProcessState(process)
	last_queued[process] = world.time

/datum/controller/processScheduler/proc/processFinished(var/datum/controller/process/process)
	setIdleProcessState(process)

/datum/controller/processScheduler/proc/setIdleProcessState(var/datum/controller/process/process)
	if(process in running)
		running -= process
	if(process in queued)
		queued -= process
	if(!(process in idle))
		idle += process

/datum/controller/processScheduler/proc/setQueuedProcessState(var/datum/controller/process/process)
	if(process in running)
		running -= process
	if(process in idle)
		idle -= process
	if(!(process in queued))
		queued += process

	// The other state transitions are handled internally by the process.
	process.queued()

/datum/controller/processScheduler/proc/setRunningProcessState(var/datum/controller/process/process)
	if(process in queued)
		queued -= process
	if(process in idle)
		idle -= process
	if(!(process in running))
		running += process

/datum/controller/processScheduler/proc/getStatusData()
	var/list/data = new

	for(var/datum/controller/process/p in processes)
		data.len++
		data[data.len] = p.getContextData()

	return data

/datum/controller/processScheduler/proc/getProcessCount()
	return processes.len

/datum/controller/processScheduler/proc/hasProcess(var/processName as text)
	if(nameToProcessMap[processName])
		return 1

/datum/controller/processScheduler/proc/killProcess(var/processName as text)
	restartProcess(processName)

/datum/controller/processScheduler/proc/restartProcess(var/processName as text)
	if(hasProcess(processName))
		var/datum/controller/process/oldInstance = nameToProcessMap[processName]
		var/datum/controller/process/newInstance = new oldInstance.type(src)
		newInstance._copyStateFrom(oldInstance)
		replaceProcess(oldInstance, newInstance)
		oldInstance.kill()

/datum/controller/processScheduler/proc/enableProcess(var/processName as text)
	if(hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		process.enable()

/datum/controller/processScheduler/proc/disableProcess(var/processName as text)
	if(hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		process.disable()

/datum/controller/processScheduler/proc/statProcesses()
	if(!isRunning)
		stat("Processes", "Scheduler not running")
		return
	if(!statclick)
		statclick = new /obj/effect/statclick/debug(src)
	stat("Processes", statclick.update("[processes.len] (R [running.len] / Q [queued.len] / I [idle.len])"))
	for(var/datum/controller/process/p in processes)
		p.statProcess()
