/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()

/datum/controller/subsystem/ambience/fire(resumed)
	for(var/C in ambience_listening_clients)
		var/client/client_iterator = C

		if(isnull(client_iterator))
			ambience_listening_clients -= client_iterator
			continue

		if(ambience_listening_clients[client_iterator] > world.time)
			continue //Not ready for the next sound

		var/area/current_area = get_area(client_iterator.mob)

		var/ambience = safepick(current_area.ambientsounds)
		if(!ambience)
			continue

		SEND_SOUND(client_iterator.mob, sound(ambience, repeat = 0, wait = 0, volume = 25 * client_iterator.prefs.get_channel_volume(CHANNEL_AMBIENCE), channel = CHANNEL_AMBIENCE))

		ambience_listening_clients[client_iterator] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)
