/datum/event/meteor_wave
	name = "Meteor Wave"
	startWhen		= 5
	nominal_severity = EVENT_LEVEL_MODERATE
	// We set this when the station clears the meteor storm to keep the event ongoing for a bit so it keeps having a cost
	noAutoEnd = TRUE
	role_weights = list(ASSIGNMENT_ENGINEERING = 5)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 4)
	var/next_meteor = 6
	var/waves = 1
	var/atom/movable/screen/alert/augury/meteor/screen_alert
	/// The time at which we clear the storm. This is set during the event run so we initialize it to an unreachable value
	var/clear_time = -1

/datum/event/meteor_wave/setup()
	for(var/mob/dead/observer/O in GLOB.dead_mob_list)
		var/atom/movable/screen/alert/augury/meteor/A = O.throw_alert("\ref[src]_augury", /atom/movable/screen/alert/augury/meteor)
		if(A)
			screen_alert = A

	waves = severity * 2 + rand(0, severity) //4-6 waves on medium. 6-9 waves on major. More consistant.

/datum/event/meteor_wave/announce(false_alarm)
	if(severity == EVENT_LEVEL_MAJOR || (false_alarm && prob(30)))
		GLOB.minor_announcement.Announce("Meteors have been detected on collision course with the station.", "Meteor Alert", new_sound = 'sound/AI/meteors.ogg')
	else
		GLOB.minor_announcement.Announce("The station is now in a meteor shower.", "Meteor Alert")

//meteor showers are lighter and more common,
/datum/event/meteor_wave/tick()
	// keep observers updated with the alert
	if(screen_alert)
		for(var/mob/dead/observer/O in GLOB.dead_mob_list)
			O.throw_alert("\ref[src]_augury", /atom/movable/screen/alert/augury/meteor)
	if(waves && activeFor >= next_meteor)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_meteors), get_meteor_count(), get_meteors())
		next_meteor += rand(15, 30) / severity
		waves--
	// When the storm is done we set a timer for the event end instead of finishing it.
	// This is so it still incurs a cost for the event system for a while.
	if(!waves && noAutoEnd)
		// Set a 15 cycle(30 second) timer before we announce clearing the storm.
		// This is to give the last meteor enough time to finish moving
		clear_time = activeFor + 15
		endWhen = activeFor + 700
		noAutoEnd = FALSE
	if(activeFor == clear_time)
		announce_clear()

/datum/event/meteor_wave/proc/announce_clear()
	for(var/mob/M in GLOB.dead_mob_list)
		M.clear_alert("\ref[src]_augury")
	QDEL_NULL(screen_alert)
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			GLOB.minor_announcement.Announce("The station has cleared the meteor storm.", "Meteor Alert")
		else
			GLOB.minor_announcement.Announce("The station has cleared the meteor shower", "Meteor Alert")

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return GLOB.meteors_catastrophic
		if(EVENT_LEVEL_MODERATE)
			return GLOB.meteors_threatening
		else
			return GLOB.meteors_normal

/datum/event/meteor_wave/proc/get_meteor_count()
	return severity + rand(1, severity) //3 to 4 per wave for medium, 4-6 for major
