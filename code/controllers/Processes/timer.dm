var/global/datum/controller/process/timer/timer_controller

/datum/controller/process/timer
	var/list/processing_timers = list()
	var/list/hashes = list()

/datum/controller/process/timer/setup()
	name = "timer"
	schedule_interval = 5 //every 0.5 seconds
	timer_controller = src

/datum/controller/process/timer/statProcess()
	..()
	stat(null, "[processing_timers.len] timers")

/datum/controller/process/timer/doWork()
	if(!processing_timers.len)
		disabled = 1 //nothing to do, lets stop firing.
		return
	for(last_object in processing_timers)
		var/datum/timedevent/event = last_object
		if(!event.thingToCall || qdeleted(event.thingToCall))
			qdel(event)
		if(event.timeToRun <= world.time)
			runevent(event)
			qdel(event)
		SCHECK

/datum/controller/process/timer/proc/runevent(datum/timedevent/event)
	set waitfor = 0
	call(event.thingToCall, event.procToCall)(arglist(event.argList))

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
	timer_controller.processing_timers -= src
	timer_controller.hashes -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = FALSE, ...)
	if(!timer_controller) //can't run timers before the mc has been created
		return
	if(!thingToCall || !procToCall || wait <= 0)
		return
	if(timer_controller.disabled)
		timer_controller.disabled = 0

	var/datum/timedevent/event = new()
	event.thingToCall = thingToCall
	event.procToCall = procToCall
	event.timeToRun = world.time + wait
	event.hash = list2text(args)
	if(args.len > 4)
		event.argList = args.Copy(5)

	// Check for dupes if unique = 1.
	if(unique)
		if(event.hash in timer_controller.hashes)
			return
	// If we are unique (or we're not checking that), add the timer and return the id.
	timer_controller.processing_timers += event
	timer_controller.hashes += event.hash
	return event.id

/proc/deltimer(id)
	for(var/datum/timedevent/event in timer_controller.processing_timers)
		if(event.id == id)
			qdel(event)
			return 1
	return 0