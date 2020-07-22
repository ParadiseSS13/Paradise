#define ALARM_RESET_DELAY 100 // How long will the alarm/trigger remain active once origin/source has been found to be gone?

/datum/alarm_source
	var/source		= null	// The source trigger
	var/source_name = ""	// The name of the source should it be lost (for example a destroyed camera)
	var/duration	= 0		// How long this source will be alarming, 0 for indefinetely.
	var/severity 	= 1		// How severe the alarm from this source is.
	var/start_time	= 0		// When this source began alarming.
	var/end_time	= 0		// Use to set when this trigger should clear, in case the source is lost.

/datum/alarm_source/New(var/atom/source)
	src.source = source
	start_time = world.time
	source_name = source.get_source_name()

/datum/alarm
	var/atom/origin					//Used to identify the alarm area.
	var/list/sources = new()		//List of sources triggering the alarm. Used to determine when the alarm should be cleared.
	var/list/sources_assoc = new()	//Associative list of source triggers. Used to efficiently acquire the alarm source.
	var/list/cameras				//List of cameras that can be switched to, if the player has that capability.
	var/area/last_area				//The last acquired area, used should origin be lost (for example a destroyed borg containing an alarming camera).
	var/area/last_name				//The last acquired name, used should origin be lost
	var/area/last_camera_area		//The last area in which cameras where fetched, used to see if the camera list should be updated.
	var/end_time					//Used to set when this alarm should clear, in case the origin is lost.

/datum/alarm/New(var/atom/origin, var/atom/source, var/duration, var/severity)
	src.origin = origin

	cameras()	// Sets up both cameras and last alarm area.
	set_source_data(source, duration, severity)

/datum/alarm/process()
	// Has origin gone missing?
	if(!origin && !end_time)
		end_time = world.time + ALARM_RESET_DELAY
	for(var/datum/alarm_source/AS in sources)
		// Has the alarm passed its best before date?
		if((AS.end_time && world.time > AS.end_time) || (AS.duration && world.time > (AS.start_time + AS.duration)))
			sources -= AS
		// Has the source gone missing?	Then reset the normal duration and set end_time
		if(!AS.source && !AS.end_time)	// end_time is used instead of duration to ensure the reset doesn't remain in the future indefinetely.
			AS.duration = 0
			AS.end_time = world.time + ALARM_RESET_DELAY

/datum/alarm/proc/set_source_data(var/atom/source, var/duration, var/severity)
	var/datum/alarm_source/AS = sources_assoc[source]
	if(!AS)
		AS = new/datum/alarm_source(source)
		sources += AS
		sources_assoc[source] = AS
	// Currently only non-0 durations can be altered (normal alarms VS EMP blasts)
	if(AS.duration)
		duration = SecondsToTicks(duration)
		AS.duration = duration
	AS.severity = severity

/datum/alarm/proc/clear(var/source)
	var/datum/alarm_source/AS = sources_assoc[source]
	sources -= AS
	sources_assoc -= source

/datum/alarm/proc/alarm_area()
	if(!origin)
		return last_area

	last_area = origin.get_alarm_area()
	return last_area

/datum/alarm/proc/alarm_name()
	if(!origin)
		return last_name

	last_name = origin.get_alarm_name()
	return last_name

/datum/alarm/proc/cameras()
	// If the alarm origin has changed area, for example a borg containing an alarming camera, reset the list of cameras
	if(cameras && (last_camera_area != alarm_area()))
		cameras = null

	// The list of cameras is also reset by /proc/invalidateCameraCache()
	if(!cameras)
		cameras = origin ? origin.get_alarm_cameras() : last_area.get_alarm_cameras()

	last_camera_area = last_area
	return cameras

/datum/alarm/proc/max_severity()
	var/max_severity = 0
	for(var/datum/alarm_source/AS in sources)
		max_severity = max(AS.severity, max_severity)

	return max_severity

/******************
* Assisting procs *
******************/
/atom/proc/get_alarm_area()
	var/area/A = get_area(src)
	return A

/area/get_alarm_area()
	return src

/atom/proc/get_alarm_name()
	var/area/A = get_area(src)
	return A.name

/area/get_alarm_name()
	return name

/mob/get_alarm_name()
	return name

/atom/proc/get_source_name()
	return name

/obj/machinery/camera/get_source_name()
	return c_tag

/atom/proc/get_alarm_cameras()
	var/area/A = get_area(src)
	return A.get_cameras()

/area/get_alarm_cameras()
	return get_cameras()

/mob/living/silicon/robot/get_alarm_cameras()
	var/list/cameras = ..()
	if(camera)
		cameras += camera

	return cameras

/mob/living/silicon/robot/syndicate/get_alarm_cameras()
	return list()
