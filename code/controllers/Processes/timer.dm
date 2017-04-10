var/global/datum/controller/process/timer/timer_master

/datum/controller/process/timer
	var/list/processing_timers = list()
	var/list/hashes = list()

/datum/controller/process/timer/setup()
	name = "timer"
	schedule_interval = 1 //every 0.1 seconds--2 server ticks
	timer_master = src
	log_startup_progress("Timer process starting up.")

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
	if(event.thingToCall)
		if(event.thingToCall == GLOBAL_PROC && istext(event.procToCall))
			call("/proc/[event.procToCall]")(arglist(event.argList))
		else
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
	id = nextid++

/datum/timedevent/Destroy()
	timer_master.processing_timers -= src
	timer_master.hashes -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = FALSE, ...)
	if(!timer_master) //can't run timers before the mc has been created
		return
	if(!thingToCall || !procToCall)
		return
	if(timer_master.disabled)
		timer_master.disabled = 0

	var/datum/timedevent/event = new()
	event.thingToCall = thingToCall
	event.procToCall = procToCall
	event.timeToRun = world.time + wait
	var/hashlist = args.Copy()

	hashlist[1] = "[thingToCall](\ref[thingToCall])"
	event.hash = jointext(hashlist, null)
	if(args.len > 4)
		event.argList = args.Copy(5)

	// Check for dupes if unique = 1.
	if(unique)
		var/datum/timedevent/hash_event = timer_master.hashes[event.hash]
		if(hash_event)
			return hash_event.id
	timer_master.hashes[event.hash] = event
	if(wait <= 0)
		timer_master.runevent(event)
		timer_master.hashes -= event.hash
		return
	// If we are unique (or we're not checking that), add the timer and return the id.
	timer_master.processing_timers += event

	return event.id

/proc/deltimer(id)
	if(id == 0)
		// No event will correspond to an id of 0 - the timer does not exist
		// Save us a possibly expensive iteration through the timer list
		// This would probably be more efficient in general if we used an associative list instead
		return 0
	for(var/datum/timedevent/event in timer_master.processing_timers)
		if(event.id == id)
			qdel(event)
			return 1
	return 0
