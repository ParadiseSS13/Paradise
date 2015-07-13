/datum/event/blob
	announceWhen	= 12
	endWhen			= 120
	var/new_rate = 2
	var/obj/effect/blob/core/Blob

/datum/event/blob/New(var/strength)
	..()
	if(strength)
		new_rate = strength

/datum/event/blob/announce()
	command_announcement.Announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')


/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		return kill()
	Blob = new /obj/effect/blob/core(T, 200, null, new_rate)
	for(var/i = 1; i < rand(3, 6), i++)
		Blob.process()


/datum/event/blob/tick()
	if(!Blob)
		kill()
		return
	if(IsMultiple(activeFor, 3))
		Blob.process()
