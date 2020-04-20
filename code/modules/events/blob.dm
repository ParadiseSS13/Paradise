/datum/event/blob
	announceWhen	= 180
	endWhen			= 240

/datum/event/blob/announce()
	GLOB.event_announcement.Announce("Confirmada amenaza de riesgo biologico de nivel 5 a bordo de la [station_name()]. Todo el personal debe contener la amenaza.", "Alerta de Riesgo Biologico", 'sound/AI/outbreak5.ogg')

/datum/event/blob/start()
	processing = FALSE //so it won't fire again in next tick

	var/turf/T = pick(GLOB.blobstart)
	if(!T)
		return kill()

	var/list/candidates = pollCandidates("Quieres jugar como un raton infestado de blob?", ROLE_BLOB, 1)
	if(!candidates.len)
		return kill()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in GLOB.all_vent_pumps)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent

	var/obj/vent = pick(vents)
	var/mob/living/simple_animal/mouse/blobinfected/B = new(vent.loc)
	var/mob/M = pick(candidates)
	B.key = M.key
	SSticker.mode.update_blob_icons_added(B.mind)

	to_chat(B, "<span class='userdanger'>Ahora eres un raton infectado con blob. Encuentra un lugar aislado ... antes de explotar y convertirte en blob! Usa la ventilacion (alt-click en ventilas) para desplazarte.</span>")
	notify_ghosts("Raton infectado de blob en: [get_area(B)].", source = B)
	processing = TRUE // Let it naturally end, if it runs successfully
