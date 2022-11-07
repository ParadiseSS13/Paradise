/datum/event/meteor_wave/goreop/announce()
	var/meteor_declaration = "MeteorOps have declared their intent to utterly destroy [station_name()] with their own bodies, and dares the crew to try and stop them."
	GLOB.major_announcement.Announce(meteor_declaration, "Declaration of 'War'", 'sound/effects/siren.ogg')

/datum/event/meteor_wave/goreop/setup()
	waves = 3

/datum/event/meteor_wave/goreop/get_meteor_count()
	return 5

/datum/event/meteor_wave/goreop/get_meteors()
	return GLOB.meteors_ops

/datum/event/meteor_wave/goreop/end()
	GLOB.minor_announcement.Announce("All MeteorOps are dead. Major Station Victory.", "MeteorOps")
