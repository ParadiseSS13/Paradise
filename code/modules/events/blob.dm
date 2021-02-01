/datum/event/blob
	announceWhen	= 180
	endWhen			= 240
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/blob/announce()
	if(successSpawn)
		GLOB.event_announcement.Announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Blob")

/datum/event/blob/start()
	var/turf/T = pick(GLOB.blobstart)
	if(!T)
		return kill()
	INVOKE_ASYNC(src, .proc/make_blob)

/datum/event/blob/proc/make_blob()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a blob infested mouse?", ROLE_BLOB, TRUE, source = /mob/living/simple_animal/mouse/blobinfected)
	if(!length(candidates))
		return kill()

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	if(!length(vents))
		return
	var/obj/vent = pick(vents)
	var/mob/living/simple_animal/mouse/blobinfected/B = new(vent.loc)
	var/mob/M = pick(candidates)
	B.key = M.key
	SSticker.mode.update_blob_icons_added(B.mind)

	to_chat(B, "<span class='userdanger'>You are now a mouse, infected with blob spores. Find somewhere isolated... before you burst and become the blob! Use ventcrawl (alt-click on vents) to move around.</span>")
	notify_ghosts("Infected Mouse has appeared in [get_area(B)].", source = B)
	successSpawn = TRUE
