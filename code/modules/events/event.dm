/datum/event_meta
	var/name 		= ""
	/// Whether or not the event is available for random selection at all.
	var/enabled 	= TRUE
	/// The base weight of this event. A zero means it may never fire, but see get_weight()
	var/weight
	/// The minimum weight that this event will have. Only used if non-zero.
	var/min_weight
	/// The maximum weight that this event will have.
	var/max_weight
	/// the current severity of this event
	var/severity
	/// If true, then the event will not be re-added to the list of available events
	var/one_shot
	/// A modifier applied to all event weights (role and base), respects min and max
	var/weight_mod	= 1
	/// A list of roles that add weight to the event
	var/list/role_weights = list()
	var/datum/event/event_type

/datum/event_meta/New(event_severity, event_name, datum/event/type, event_weight, list/job_weights, is_one_shot = FALSE, min_event_weight = 0, max_event_weight = INFINITY)
	name = event_name
	severity = event_severity
	event_type = type
	one_shot = is_one_shot
	weight = event_weight
	min_weight = min_event_weight
	max_weight = max_event_weight
	if(job_weights)
		role_weights = job_weights

/datum/event_meta/proc/get_weight(list/active_with_role)
	if(!enabled)
		return 0

	var/job_weight = 0
	for(var/role in role_weights)
		if(role in active_with_role)
			job_weight += active_with_role[role] * role_weights[role]

	return clamp((weight + job_weight) * weight_mod, min_weight, max_weight)

/datum/event_meta/alien/get_weight(list/active_with_role)
	if(GLOB.aliens_allowed)
		return ..(active_with_role)
	return 0

/*/datum/event_meta/ninja/get_weight(var/list/active_with_role)
	if(toggle_space_ninja)
		return ..(active_with_role)
	return 0*/

/datum/event	//NOTE: Times are measured in master controller ticks!
	/// The human-readable name of the event
	var/name
	var/processing = 1
	/// When in the lifetime to call start().
	var/startWhen		= 0
	/// When in the lifetime to call announce().
	var/announceWhen	= 0
	/// When in the lifetime the event should end.
	var/endWhen			= 0
	/// Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/severity		= 0
	/// How long the event has existed. You don't need to change this.
	var/activeFor		= 0
	/// If this event is currently running. You should not change this.
	var/isRunning		= TRUE
	/// When this event started.
	var/startedAt		= 0
	/// When this event ended.
	var/endedAt			= 0
	/// Does the event end automatically after endWhen passes?
	var/noAutoEnd       = FALSE
	/// The area the event will hit
	var/area/impact_area
	var/datum/event_meta/event_meta = null

/datum/event/nothing

/**
  * Called first before processing.
  *
  * Allows you to setup your event, such as randomly
  * setting the startWhen and or announceWhen variables.
  * Only called once.
  */
/datum/event/proc/setup()
	return

/**
  * Called when the tick is equal to the startWhen variable.
  *
  * Allows you to start before announcing or vice versa.
  * Only called once.
  */
/datum/event/proc/start()
	return

/**
  * Called when the tick is equal to the announceWhen variable.
  *
  * Allows you to announce before starting or vice versa.
  * Only called once.
  */
/datum/event/proc/announce()
	return

/**
  * Called on or after the tick counter is equal to startWhen.
  *
  * You can include code related to your event or add your own
  * time stamped events.
  * Called more than once.
  */
/datum/event/proc/tick()
	return

/**
  * Called on or after the tick is equal or more than endWhen
  *
  * You can include code related to the event ending.
  * Do not place spawn() in here, instead use tick() to check for
  * the activeFor variable.
  * For example: if(activeFor == myOwnVariable + 30) doStuff()
  * Only called once.
  */
/datum/event/proc/end()
	return

/**
  * Returns the latest point of event processing.
  */
/datum/event/proc/lastProcessAt()
	return max(startWhen, max(announceWhen, endWhen))

/**
  * Do not override this proc, instead use the appropiate procs.
  *
  * This proc will handle the calls to the appropiate procs.
  */
/datum/event/process()
	if(!processing)
		return

	if(activeFor > startWhen && activeFor < endWhen || noAutoEnd)
		tick()

	if(activeFor == startWhen)
		isRunning = TRUE
		start()

	if(activeFor == announceWhen)
		announce()

	if(activeFor == endWhen && !noAutoEnd)
		isRunning = FALSE
		end()

	// Everything is done, let's clean up.
	if(activeFor >= lastProcessAt() && !noAutoEnd)
		kill()

	activeFor++

/**
  * Called when start(), announce() and end() has all been called.
  */
/datum/event/proc/kill()
	// If this event was forcefully killed run end() for individual cleanup
	if(isRunning)
		isRunning = FALSE
		end()

	endedAt = world.time
	SSevents.active_events -= src
	SSevents.event_complete(src)

/datum/event/New(var/datum/event_meta/EM)
	// event needs to be responsible for this, as stuff like APLUs currently make their own events for curious reasons
	SSevents.active_events += src

	if(!EM)
		EM = new /datum/event_meta(EVENT_LEVEL_MAJOR, "Unknown, Most likely admin called", src.type)

	event_meta = EM
	severity = event_meta.severity
	if(severity < EVENT_LEVEL_MUNDANE) severity = EVENT_LEVEL_MUNDANE
	if(severity > EVENT_LEVEL_MAJOR) severity = EVENT_LEVEL_MAJOR

	startedAt = world.time

	setup()
	..()

//Called after something followable has been spawned by an event
//Provides ghosts a follow link to an atom if possible
//Only called once.
/datum/event/proc/announce_to_ghosts(atom/atom_of_interest)
	if(atom_of_interest)
		notify_ghosts("[name] has an object of interest: [atom_of_interest]!", title = "Something's Interesting!", source = atom_of_interest, action = NOTIFY_FOLLOW)
