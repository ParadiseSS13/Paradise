/datum/event/blob
	announceWhen	= 60
	endWhen			= 120
	var/obj/structure/blob/core/Blob

/datum/event/blob/announce()
	event_announcement.Announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		return kill()
	var/list/candidates = pollCandidates("Do you want to play as a blob?", ROLE_BLOB, 1)
	if(!candidates.len)
		return kill()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in all_vent_pumps)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent
	var/obj/vent = pick(vents)
	var/mob/living/simple_animal/mouse/blobinfected/B = new(vent.loc)
	var/mob/M = pick(candidates)
	B.key = M.key
	to_chat(B, "<span class='userdanger'>You are now a mouse, infected with blob spores. Find somewhere isolated... before you burst and become the blob! Use ventcrawl (alt-click on vents) to move around.</span>")
	var/image/alert_overlay = image('icons/mob/blob.dmi', "blank_blob")
	notify_ghosts("Infected Mouse has appeared in [get_area(B)].", source = B, alert_overlay = alert_overlay)

/datum/event/blob/tick()
	if(!Blob)
		kill()
		return
	if(IsMultiple(activeFor, 3))
		Blob.process()
