/datum/event/blob
	announceWhen	= 180
	endWhen			= 240
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.
	var/for_players = 40 		//Количество людей для спавна доп. мыши

/datum/event/blob/announce()
	if(successSpawn)
		GLOB.event_announcement.Announce("Вспышка биологической угрозы 5-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/AI/outbreak5.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Blob")

/datum/event/blob/start()
	processing = FALSE //so it won't fire again in next tick

	var/turf/T = pick(GLOB.blobstart)
	if(!T)
		return kill()

	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за мышь, зараженную Блобом?", ROLE_BLOB, TRUE, source = /mob/living/simple_animal/mouse/blobinfected)
	if(!length(candidates))
		return kill()

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	if(!length(vents))
		return

	var/num_blobs = round((length(GLOB.clients) / for_players)) + 1
	for(var/i in 1 to num_blobs)
		if (length(candidates))
			var/obj/vent = pick(vents)
			var/mob/living/simple_animal/mouse/blobinfected/B = new(vent.loc)
			var/mob/M = pick(candidates)
			candidates.Remove(M)
			B.key = M.key
			SSticker.mode.update_blob_icons_added(B.mind)

			to_chat(B, "<span class='userdanger'>Теперь вы мышь, заражённая спорами Блоба. Найдите какое-нибудь укромное место до того, как вы взорветесь и станете Блобом! Вы можете перемещаться по вентиляции, нажав Alt+ЛКМ на вентиляционном отверстии.</span>")
			notify_ghosts("Заражённая мышь появилась в [get_area(B)].", source = B, action = NOTIFY_FOLLOW)
	successSpawn = TRUE
	processing = TRUE // Let it naturally end, if it runs successfully
