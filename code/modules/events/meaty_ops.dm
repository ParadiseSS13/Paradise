/datum/event/meteor_wave/goreop/announce()
	var/meteor_declaration = "MeteorOps have declared their intent to utterly destroy [station_name()] with their own bodies, and dares the crew to try and stop them."
	command_announcement.Announce(meteor_declaration, "Declaration of 'War'", 'sound/effects/siren.ogg')

/datum/event/meteor_wave/goreop/setup()
	waves = 3


/datum/event/meteor_wave/goreop/tick()
	if(waves && activeFor >= next_meteor)
		spawn() spawn_meteors(5, meteors_ops)
		next_meteor += rand(15, 30)
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)



/datum/event/meteor_wave/goreops/end()
	command_announcement.Announce("All MeteorOps are dead. Major Station Victory.", "MeteorOps")