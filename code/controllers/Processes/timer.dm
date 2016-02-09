var/global/datum/controller/process/timer/PStimer

/datum/controller/process/timer
	var/list/processing_timers = list()
	var/list/hashes = list()

/datum/controller/process/timer/setup()
	name = "timer"
	schedule_interval = 5 //every 0.5 seconds
	PStimer = src

/datum/controller/process/timer/statProcess()
	..()
	stat(null, "[processing_timers.len] timers")

/datum/controller/process/timer/doWork()
	if(!processing_timers.len)
		disabled = 1 //nothing to do, lets stop firing.
		return
	for(var/datum/timedevent/event in processing_timers)
		if(!event.thingToCall || qdeleted(event.thingToCall))
			qdel(event)
		if(event.timeToRun <= world.time)
			spawn(-1)
				call(event.thingToCall, event.procToCall)(arglist(event.argList))
			qdel(event)
		SCHECK

/datum/timedevent
	var/thingToCall
	var/procToCall
	var/timeToRun
	var/argList
	var/id
	var/hash
	var/static/nextid = 1

/datum/timedevent/New()
	id = nextid
	nextid++

/datum/timedevent/Destroy()
	PStimer.processing_timers -= src
	PStimer.hashes -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = FALSE, ...)
	if(!PStimer) //can't run timers before the mc has been created
		return
	if(!thingToCall || !procToCall || wait <= 0)
		return
	if(PStimer.disabled)
		PStimer.disabled = 0

	var/datum/timedevent/event = new()
	event.thingToCall = thingToCall
	event.procToCall = procToCall
	event.timeToRun = world.time + wait
	event.hash = list2text(args)
	if(args.len > 4)
		event.argList = args.Copy(5)

	// Check for dupes if unique = 1.
	if(unique)
		if(event.hash in PStimer.hashes)
			return
	// If we are unique (or we're not checking that), add the timer and return the id.
	PStimer.processing_timers += event
	PStimer.hashes += event.hash
	return event.id

/proc/deltimer(id)
	for(var/datum/timedevent/event in PStimer.processing_timers)
		if(event.id == id)
			qdel(event)
			return 1
	return 0