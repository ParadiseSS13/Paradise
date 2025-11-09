/datum/event_meta
	var/name = ""
	/// Whether or not the event is available for random selection at all.
	var/enabled = TRUE
	/// The base weight of this event. A zero means it may never fire, but see get_weight()
	var/weight
	/// The minimum weight that this event will have. Only used if non-zero.
	var/min_weight
	/// The maximum weight that this event will have.
	var/max_weight
	/// If true, then the event will not be re-added to the list of available events
	var/one_shot
	/// A modifier applied to all event weights (role and base), respects min and max
	var/weight_mod	= 1
	/// Event held by this meta event. Used to do things like calculate weight.
	var/datum/event/skeleton
	/// How early this specific event can run
	var/first_run_time = 0

/datum/event_meta/New(event_severity, type, event_weight, is_one_shot = FALSE, min_event_weight = 0, max_event_weight = INFINITY, _first_run_time)
	if(type)
		skeleton = new type(EM = src, skeleton = TRUE, _severity = event_severity)
		name = skeleton.name
	one_shot = is_one_shot
	weight = event_weight
	min_weight = min_event_weight
	max_weight = max_event_weight
	first_run_time = _first_run_time

/datum/event_meta/proc/change_event(type)
	var/event_severity = 0
	if(skeleton)
		event_severity = skeleton.severity
		skeleton.event_meta = null
		qdel(skeleton)
	skeleton = new type(EM = src, skeleton = TRUE, _severity = event_severity)

/datum/event_meta/proc/get_weight(list/total_resources)
	if(!enabled || !skeleton)
		return 0
	var/resource_effect = skeleton.get_weight(total_resources)
	var/new_weight = weight
	if(resource_effect > 0)
		new_weight *= (1.003 ** resource_effect)
	if(resource_effect < 0)
		new_weight *= 0.95 ** -resource_effect
	return clamp((new_weight) * weight_mod, min_weight, max_weight)

/*/datum/event_meta/ninja/get_weight(var/list/active_with_role)
	if(toggle_space_ninja)
		return ..(active_with_role)
	return 0*/

/// NOTE: Times are measured in master controller ticks!
/datum/event
	/// The human-readable name of the event
	var/name
	/// When in the lifetime to call start().
	var/startWhen		= 0
	/// When in the lifetime to call announce().
	var/announceWhen	= 0
	/// When in the lifetime the event should end.
	var/endWhen			= 0
	/// Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/severity		= 0
	/// The severity the event has normally
	var/nominal_severity = EVENT_LEVEL_MUNDANE
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
	/// The base weight of each role on the event for the purpose of calculating event weight and resource cost
	var/list/role_weights = list()
	/// A baseline requirement of different roles the event has at it's nominal severity
	var/list/role_requirements = list()

/datum/event/nothing
	name = "Nothing"

/datum/event/nothing/has_cooldown()
	return FALSE

/datum/event/nothing/is_relative()
	return TRUE

/// Calculate the weight for rolling the event based on round circumstances.
/datum/event/proc/get_weight(list/total_resources)
	var/job_weight = 0
	for(var/role in role_weights)
		var/role_available = total_resources[role] ? total_resources[role] : 0
		var/difference = (role_available - role_requirements[role] * (severity / nominal_severity)) * role_weights[role]
		// We add difference if it's negative, or the square root if it's positive
		job_weight += difference
	return job_weight

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
  * Ensure no sleep is called. Use INVOKE_ASYNC to call procs which do.
  */
/datum/event/proc/start()
	SHOULD_NOT_SLEEP(TRUE)
	return

/**
  * Called when the tick is equal to the announceWhen variable.
  *
  * Allows you to announce before starting or vice versa.
  * Only called once.
  * Ensure no sleep is called. Use INVOKE_ASYNC to call procs which do.
  */
/datum/event/proc/announce(false_alarm = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	return

/**
  * Called on or after the tick counter is equal to startWhen.
  *
  * You can include code related to your event or add your own
  * time stamped events.
  * Called more than once.
  * Ensure no sleep is called. Use INVOKE_ASYNC to call procs which do.
  */
/datum/event/proc/tick()
	SHOULD_NOT_SLEEP(TRUE)
	return

/**
  * Called on or after the tick is equal or more than endWhen
  *
  * You can include code related to the event ending.
  * Do not place spawn() in here, instead use tick() to check for
  * the activeFor variable.
  * For example: if(activeFor == myOwnVariable + 30) doStuff()
  * Only called once.
  * Ensure no sleep is called. Use INVOKE_ASYNC to call procs which do.
  */
/datum/event/proc/end()
	SHOULD_NOT_SLEEP(TRUE)
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
  * Ensure none of the code paths have a sleep in them. Use INVOKE_ASYNC to call procs which do.
  */
/datum/event/process()
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

// Events have cooldown by default
/datum/event/proc/has_cooldown()
	return TRUE

/datum/event/proc/is_relative()
	return FALSE

/datum/event/New(datum/event_meta/EM, skeleton = FALSE, _severity)
	// event needs to be responsible for this, as stuff like APLUs currently make their own events for curious reasons
	if(!skeleton)
		SSevents.active_events += src

	event_meta = EM

	severity = _severity ? _severity : nominal_severity
	if(severity < EVENT_LEVEL_MUNDANE)
		severity = EVENT_LEVEL_MUNDANE
		log_debug("Event of '[type]' with severity below mundane run has run")
	if(severity > EVENT_LEVEL_DISASTER)
		severity = EVENT_LEVEL_DISASTER
		log_debug("Event of '[type]' with severity above disaster has run")

	startedAt = world.time

	if(!skeleton)
		setup()
	..()

//Called after something followable has been spawned by an event
//Provides ghosts a follow link to an atom if possible
//Only called once.
/datum/event/proc/announce_to_ghosts(atom/atom_of_interest)
	if(atom_of_interest)
		notify_ghosts("[name] has an object of interest: [atom_of_interest]!", title = "Something's Interesting!", source = atom_of_interest, flashwindow = FALSE, action = NOTIFY_FOLLOW)

/// Override this to make a custom fake announcement that differs from the normal announcement.
/// Used for false alarms.
/// If this proc returns TRUE, the regular Announce() won't be called.
/datum/event/proc/fake_announce()
	return FALSE

/// The amount of people in different roles needed to handle an ongoing event.
/datum/event/proc/event_resource_cost()
	return role_requirements
