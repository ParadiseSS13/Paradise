// Process

/datum/controller/process
	/**
	 * State vars
	 */
	// Main controller ref
	var/tmp/datum/controller/processScheduler/main

	// 1 if process is not running or queued
	var/tmp/idle = 1

	// 1 if process is queued
	var/tmp/queued = 0

	// 1 if process is running
	var/tmp/running = 0

	// 1 if process is blocked up
	var/tmp/hung = 0

	// 1 if process was killed
	var/tmp/killed = 0

	// Status text var
	var/tmp/status

	// Previous status text var
	var/tmp/previousStatus

	// 1 if process is disabled
	var/tmp/disabled = 0

	/**
	 * Config vars
	 */
	// Process name
	var/name

	// Process schedule interval
	// This controls how often the process would run under ideal conditions.
	// If the process scheduler sees that the process has finished, it will wait until
	// this amount of time has elapsed from the start of the previous run to start the
	// process running again.
	var/tmp/schedule_interval = PROCESS_DEFAULT_SCHEDULE_INTERVAL // run every 50 ticks

	// Process sleep interval
	// This controls how often the process will yield (call sleep(0)) while it is running.
	// Every concurrent process should sleep periodically while running in order to allow other
	// processes to execute concurrently.
	var/tmp/sleep_interval = PROCESS_DEFAULT_SLEEP_INTERVAL

	// Defer usage; the tick usage at which this process will defer until the next tick
	var/tmp/defer_usage = PROCESS_DEFAULT_DEFER_USAGE

	// hang_warning_time - this is the time (in 1/10 seconds) after which the server will begin to show "maybe hung" in the context window
	var/tmp/hang_warning_time = PROCESS_DEFAULT_HANG_WARNING_TIME

	// hang_alert_time - After this much time(in 1/10 seconds), the server will send an admin debug message saying the process may be hung
	var/tmp/hang_alert_time = PROCESS_DEFAULT_HANG_ALERT_TIME

	// hang_restart_time - After this much time(in 1/10 seconds), the server will automatically kill and restart the process.
	var/tmp/hang_restart_time = PROCESS_DEFAULT_HANG_RESTART_TIME

	// Number of deciseconds to delay before starting the process
	var/start_delay = 0

	/**
	 * recordkeeping vars
	 */

	// Records the time (1/10s timeofgame) at which the process last began running
	var/tmp/run_start = 0

	// Records the number of times this process has been killed and restarted
	var/tmp/times_killed

	// Tick count
	var/tmp/ticks = 0

	var/tmp/last_task = ""

	var/tmp/last_object

	// How many times in the current run has the process deferred work till the next tick?
	var/tmp/cpu_defer_count = 0

	// Counts the number of times an exception has occurred; gets reset after 10
	var/tmp/list/exceptions = list()

	// The next tick_usage the process will sleep at
	var/tmp/next_sleep_usage

	// Last run duration, in seconds
	var/tmp/last_run_time = 0

	// Last 20 run durations
	var/tmp/list/last_twenty_run_times = list()

	// Highest run duration, in seconds
	var/tmp/highest_run_time = 0

	// Tick usage at start of current run (updates upon deferring)
	var/tmp/tick_usage_start

	// Accumulated tick usage from before each deferral
	var/tmp/tick_usage_accumulated = 0

/datum/controller/process/New(var/datum/controller/processScheduler/scheduler)
	..()
	main = scheduler
	previousStatus = "idle"
	idle()
	name = "process"
	run_start = 0
	ticks = 0
	last_task = 0
	last_object = null

/datum/controller/process/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/process/proc/started()
	// Initialize run_start so we can detect hung processes.
	run_start = TimeOfGame

	// Initialize defer count
	cpu_defer_count = 0

	// Prepare usage tracking (defer() updates these)
	tick_usage_start = world.tick_usage
	tick_usage_accumulated = 0

	running()
	main.processStarted(src)

	onStart()

/datum/controller/process/proc/finished()
	ticks++
	recordRunTime()
	idle()
	main.processFinished(src)

	onFinish()

/datum/controller/process/proc/recordRunTime()
	// Convert from tick usage (100/tick) to seconds of CPU time used
	var/total_usage = (tick_usage_accumulated + (world.tick_usage - tick_usage_start)) / 1000 * world.tick_lag

	last_run_time = total_usage
	if(total_usage > highest_run_time)
		highest_run_time = total_usage
	if(last_twenty_run_times.len == 20)
		last_twenty_run_times.Cut(1, 2)
	last_twenty_run_times += total_usage

/datum/controller/process/proc/doWork()

/datum/controller/process/proc/setup()

/datum/controller/process/proc/process()
	started()
	doWork()
	finished()

/datum/controller/process/proc/running()
	idle = 0
	queued = 0
	running = 1
	hung = 0
	setStatus(PROCESS_STATUS_RUNNING)

/datum/controller/process/proc/idle()
	queued = 0
	running = 0
	idle = 1
	hung = 0
	setStatus(PROCESS_STATUS_IDLE)

/datum/controller/process/proc/queued()
	idle = 0
	running = 0
	queued = 1
	hung = 0
	setStatus(PROCESS_STATUS_QUEUED)

/datum/controller/process/proc/hung()
	hung = 1
	setStatus(PROCESS_STATUS_HUNG)

/datum/controller/process/proc/handleHung()
	var/datum/lastObj = last_object
	var/lastObjType = "null"
	if(istype(lastObj))
		lastObjType = lastObj.type

	var/msg = "[name] process hung at tick #[ticks]. Process was unresponsive for [(TimeOfGame - run_start) / 10] seconds and was restarted. Last task: [last_task]. Last Object Type: [lastObjType]"
	log_debug(msg)
	message_admins(msg)
	log_runtime(EXCEPTION(msg), src)

	main.restartProcess(src.name)

/datum/controller/process/proc/kill()
	if(!killed)
		var/msg = "[name] process was killed at tick #[ticks]."
		log_debug(msg)
		message_admins(msg)
		log_runtime(EXCEPTION(msg), src)
		//finished()

		// Allow inheritors to clean up if needed
		onKill()

		qdel(src)

// Do not call this directly - use SHECK
/datum/controller/process/proc/defer()
	if(killed)
		// The kill proc is the only place where killed is set.
		// The kill proc should have deleted this datum, and all sleeping procs that are
		// owned by it.
		CRASH("A killed process is still running somehow...")
	if(hung)
		// This will only really help if the doWork proc ends up in an infinite loop.
		handleHung()
		CRASH("Process [name] hung and was restarted.")

	tick_usage_accumulated += (world.tick_usage - tick_usage_start)
	if(world.tick_usage < defer_usage)
		sleep(0)
	else
		sleep(world.tick_lag)
		cpu_defer_count++
	tick_usage_start = world.tick_usage
	next_sleep_usage = min(world.tick_usage + sleep_interval, defer_usage)

/datum/controller/process/proc/update()
	// Clear delta
	if(previousStatus != status)
		setStatus(status)

	var/elapsedTime = getElapsedTime()

	if(hung)
		handleHung()
		return
	else if(elapsedTime > hang_restart_time)
		hung()
	else if(elapsedTime > hang_alert_time)
		setStatus(PROCESS_STATUS_PROBABLY_HUNG)
	else if(elapsedTime > hang_warning_time)
		setStatus(PROCESS_STATUS_MAYBE_HUNG)


/datum/controller/process/proc/getElapsedTime()
	return TimeOfGame - run_start

/datum/controller/process/proc/tickDetail()
	return

/datum/controller/process/proc/getContext()
	return "<tr><td>[name]</td><td>[getAverageRunTime()]</td><td>[last_run_time]</td><td>[highest_run_time]</td><td>[ticks]</td></tr>\n"

/datum/controller/process/proc/getContextData()
	return list(
	"name" = name,
	"averageRunTime" = getAverageRunTime(),
	"lastRunTime" = last_run_time,
	"highestRunTime" = highest_run_time,
	"ticks" = ticks,
	"schedule" = schedule_interval,
	"status" = getStatusText(),
	"disabled" = disabled
	)

/datum/controller/process/proc/getStatus()
	return status

/datum/controller/process/proc/getStatusText(var/s = 0)
	if(!s)
		s = status
	switch(s)
		if(PROCESS_STATUS_IDLE)
			return "idle"
		if(PROCESS_STATUS_QUEUED)
			return "queued"
		if(PROCESS_STATUS_RUNNING)
			return "running"
		if(PROCESS_STATUS_MAYBE_HUNG)
			return "maybe hung"
		if(PROCESS_STATUS_PROBABLY_HUNG)
			return "probably hung"
		if(PROCESS_STATUS_HUNG)
			return "HUNG"
		else
			return "UNKNOWN"

/datum/controller/process/proc/getPreviousStatus()
	return previousStatus

/datum/controller/process/proc/getPreviousStatusText()
	return getStatusText(previousStatus)

/datum/controller/process/proc/setStatus(var/newStatus)
	previousStatus = status
	status = newStatus

/datum/controller/process/proc/setLastTask(var/task, var/object)
	last_task = task
	last_object = object

/datum/controller/process/proc/_copyStateFrom(var/datum/controller/process/target)
	main = target.main
	name = target.name
	schedule_interval = target.schedule_interval
	sleep_interval = target.sleep_interval
	run_start = 0
	times_killed = target.times_killed
	ticks = target.ticks
	last_task = target.last_task
	last_object = target.last_object
	copyStateFrom(target)

/datum/controller/process/proc/copyStateFrom(var/datum/controller/process/target)

/datum/controller/process/proc/onKill()

/datum/controller/process/proc/onStart()

/datum/controller/process/proc/onFinish()

/datum/controller/process/proc/disable()
	disabled = 1

/datum/controller/process/proc/enable()
	disabled = 0

/datum/controller/process/proc/getAverageRunTime()
	var/t = 0
	var/c = 0
	for(var/time in last_twenty_run_times)
		t += time
		c++

	if(c > 0)
		return t / c
	return c

/datum/controller/process/proc/getLastRunTime()
	return last_run_time

/datum/controller/process/proc/getHighestRunTime()
	return highest_run_time

/datum/controller/process/proc/getTicks()
	return ticks

/datum/controller/process/proc/statProcess()
	var/averageRunTime = round(getAverageRunTime(), 0.001)
	var/lastRunTime = round(last_run_time, 0.001)
	var/highestRunTime = round(highest_run_time, 0.001)
	var/deferTime = round(cpu_defer_count / 10 * world.tick_lag, 0.01)
	if(!statclick)
		statclick = new (src)
	stat("[name]", statclick.update("T#[getTicks()] | AR [averageRunTime] | LR [lastRunTime] | HR [highestRunTime] | D [deferTime]"))

/datum/controller/process/proc/catchException(var/exception/e, var/thrower)
	if(istype(e)) // Real runtimes go to the real error handler
		log_runtime(e, thrower, "Caught by process: [name]")
		return
	var/etext = "[e]"
	var/eid = "[e]" // Exception ID, for tracking repeated exceptions
	var/ptext = "" // "processing..." text, for what was being processed (if known)
	if(istype(e))
		etext += " in [e.file], line [e.line]"
		eid = "[e.file]:[e.line]"
	if(eid in exceptions)
		if(exceptions[eid]++ >= 10)
			return
	else
		exceptions[eid] = 1
	if(istype(thrower, /datum))
		var/datum/D = thrower
		ptext = " processing [D.type]"
		if(istype(thrower, /atom))
			var/atom/A = thrower
			ptext += " ([A]) ([A.x],[A.y],[A.z])"
	log_to_dd("\[[time_stamp()]\] Process [name] caught exception[ptext]: [etext]")
	if(exceptions[eid] >= 10)
		log_to_dd("This exception will now be ignored for ten minutes.")
		spawn(6000)
			exceptions[eid] = 0

/datum/controller/process/proc/catchBadType(var/datum/caught)
	if(isnull(caught) || !istype(caught) || !isnull(caught.gcDestroyed))
		return // Only bother with types we can identify and that don't belong
	catchException("Type [caught.type] does not belong in process' queue")
