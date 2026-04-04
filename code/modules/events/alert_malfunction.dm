/datum/event/alert_malf
	name = "Security Level Malfunction"
	startWhen = 0
	announceWhen = 30
	var/level
	var/previous_level

/datum/event/alert_malf/start()
	previous_level = SSsecurity_level.get_current_level_as_number()
	for(level = 0, level == previous_level || level == 4)
		level = rand(0, 6)
	SSsecurity_level.set_level(level)

/datum/event/alert_malf/announce()
	if(level >= 5 || previous_level == 3 || previous_level == 4)
		GLOB.minor_announcement.Announce("Critical malfunction detected in [station_name()] security level subroutines. Issuing correction...", "General Alert")
		SSsecurity_level.set_level(previous_level)
	else
		GLOB.minor_announcement.Announce("Critical malfunction detected in [station_name()] security level subroutines. Please correct the security level using a communications console or Card Swipers.", "General Alert")
