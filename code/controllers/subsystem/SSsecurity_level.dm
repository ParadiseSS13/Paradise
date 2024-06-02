#define DEFAULT_SECURITY_LEVEL_NUMBER SEC_LEVEL_GREEN
#define DEFAULT_SECURITY_LEVEL_NAME "green"

GLOBAL_DATUM_INIT(security_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/security))

SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	/// Option reference of a timer id of the latest set security level. Only set when security level is changed to one with `set_delay` > 0
	var/security_level_set_timer_id
	/// Currently set security level
	var/datum/security_level/current_security_level
	/// A list of initialised security level datums
	var/list/available_levels = list()

/datum/controller/subsystem/security_level/Initialize()
	if(!length(available_levels))
		for(var/security_level_type in subtypesof(/datum/security_level))
			var/datum/security_level/new_security_level = new security_level_type
			available_levels[new_security_level.name] = new_security_level

	if(!current_security_level)
		current_security_level = available_levels[number_level_to_text(DEFAULT_SECURITY_LEVEL_NUMBER)]

/datum/controller/subsystem/security_level/Recover()
	security_level_set_timer_id = SSsecurity_level.security_level_set_timer_id
	current_security_level = SSsecurity_level.current_security_level
	available_levels = SSsecurity_level.available_levels

/**
 * Sets a new security level as our current level
 *
 * This is how everything should change the security level
 *
 * Arguments:
 * * new_level - The new security level that will become our current level, could be number or name of security level
 */
/datum/controller/subsystem/security_level/proc/set_level(new_level)
	var/new_level_name = istext(new_level) ? new_level : number_level_to_text(new_level)
	if(new_level_name == current_security_level.name)
		return

	var/datum/security_level/selected_level = available_levels[new_level_name]

	if(!selected_level)
		CRASH("set_level was called with an invalid security level([new_level_name])")

	if(security_level_set_timer_id)
		deltimer(security_level_set_timer_id)
		security_level_set_timer_id = null

	pre_set_level(selected_level)

	if(selected_level.set_delay > 0)
		SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGE_PLANNED, current_security_level.number_level, selected_level.number_level)
		security_level_set_timer_id = addtimer(CALLBACK(src, PROC_REF(do_set_level), selected_level), selected_level.set_delay, TIMER_UNIQUE | TIMER_STOPPABLE)
	else
		do_set_level(selected_level)

/**
 * Do things before the actual security level set, like executing security level specific pre change behavior
 *
 * Arguments:
 * * selected_level - The datum of security level selected to be changed to
 */
/datum/controller/subsystem/security_level/proc/pre_set_level(datum/security_level/selected_level)
	PRIVATE_PROC(TRUE)

	selected_level.pre_change()

/**
 * Actually sets the security level after the announcement
 *
 * Sends `COMSIG_SECURITY_LEVEL_CHANGED` in the end
 *
 * Arguments:
 * * selected_level - The datum of security level selected to be changed to
 */
/datum/controller/subsystem/security_level/proc/do_set_level(datum/security_level/selected_level)
	PRIVATE_PROC(TRUE)

	var/datum/security_level/previous_security_level = current_security_level
	if(previous_security_level.number_level < SEC_LEVEL_RED && selected_level.number_level >= SEC_LEVEL_RED)
		// Mark down this time to prevent shuttle cheese
		SSshuttle.emergency_sec_level_time = world.time

	announce_security_level(selected_level)
	current_security_level = selected_level

	post_status(current_security_level.status_display_mode, current_security_level.status_display_data)
	SSnightshift.check_nightshift()
	SSblackbox.record_feedback("tally", "security_level_changes", 1, selected_level.name)

	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, previous_security_level.number_level, selected_level.number_level)

/**
 * Handles announcements of the newly set security level
 *
 * Arguments:
 * * selected_level - The new security level that has been set
 */
/datum/controller/subsystem/security_level/proc/announce_security_level(datum/security_level/selected_level)
	if(selected_level.number_level > current_security_level.number_level)
		GLOB.security_announcement.Announce(
			selected_level.elevating_to_announcement_text,
			selected_level.elevating_to_announcement_title,
			new_sound = selected_level.elevating_to_sound,
			new_sound2 = selected_level.ai_announcement_sound)
	else
		GLOB.security_announcement.Announce(
			selected_level.lowering_to_announcement_text,
			selected_level.lowering_to_announcement_title,
			new_sound = selected_level.lowering_to_sound,
			new_sound2 = selected_level.ai_announcement_sound)

/**
 * Returns the current security level as a number
 * In case the subsystem hasn't finished initializing yet, returns default security level
 */
/datum/controller/subsystem/security_level/proc/get_current_level_as_number()
	return ((!initialized || !current_security_level) ? DEFAULT_SECURITY_LEVEL_NUMBER : current_security_level.number_level)

/**
 * Returns the current security level as text
 */
/datum/controller/subsystem/security_level/proc/get_current_level_as_text()
	return ((!initialized || !current_security_level) ? DEFAULT_SECURITY_LEVEL_NAME : current_security_level.name)

/**
 * Converts a text security level to a number
 *
 * Arguments:
 * * level - The text security level to convert
 */
/datum/controller/subsystem/security_level/proc/text_level_to_number(text_level)
	var/datum/security_level/selected_level = available_levels[text_level]
	return selected_level?.number_level

/**
 * Converts a number security level to a text
 *
 * Arguments:
 * * level - The number security level to convert
 */
/datum/controller/subsystem/security_level/proc/number_level_to_text(number_level)
	for(var/level_text in available_levels)
		var/datum/security_level/security_level = available_levels[level_text]
		if(security_level.number_level == number_level)
			return security_level.name

/**
 * Returns security level name formatted with it's color
 */
/datum/controller/subsystem/security_level/proc/get_colored_current_security_level_name()
	return "<font color='[current_security_level.color]'>[current_security_level.name]</font>"

#undef DEFAULT_SECURITY_LEVEL_NUMBER
#undef DEFAULT_SECURITY_LEVEL_NAME
