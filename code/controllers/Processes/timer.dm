var/global/datum/controller/process/timer/timer_master

/datum/controller/process/timer
	var/list/processing_timers = list()
	var/list/hashes = list()

/datum/controller/process/timer/setup()
	name = "timer"
	schedule_interval = 5 //every 0.5 seconds
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
	timer_master.processing_timers -= src
	timer_master.hashes -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = FALSE, ...)
	if(!timer_master) //can't run timers before the mc has been created
		return
	if(!thingToCall || !procToCall || wait <= 0)
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
		if(event.hash in timer_master.hashes)
			return
	// If we are unique (or we're not checking that), add the timer and return the id.
	timer_master.processing_timers += event
	timer_master.hashes += event.hash
	return event.id

/proc/deltimer(id)
	for(var/datum/timedevent/event in timer_master.processing_timers)
		if(event.id == id)
			qdel(event)
			return 1
	return 0
