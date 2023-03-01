GLOBAL_LIST_INIT(unused_trade_stations, list("sol"))

// Traders event.
// Heavily copy-pasted from "heist" gamemode.

/datum/event/traders
	var/success_spawn = 0
	var/station = null
	var/spawn_count = 2
	var/list/trader_objectives = list()

/datum/event/traders/setup()
	if(GLOB.unused_trade_stations.len)
		station = pick_n_take(GLOB.unused_trade_stations)

/datum/event/traders/start()
	if(!station) // If there are no unused stations, just no.
		return
	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED)
		GLOB.event_announcement.Announce("Торговому шаттлу со станции Юпитер-6 было отказано в разрешении на стыковку из-за повышенной угрозы безопасности на борту [station_name()].", "ОПОВЕЩЕНИЕ: Запрос на стыковку шаттла торговцев отклонен.")
		// if the docking request was refused, fire another major event in 60 seconds
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return

	var/list/spawnlocs = list()
	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/landmark = thing
		if(landmark.name == "traderstart_[station]")
			spawnlocs += get_turf(landmark)
	if(!spawnlocs.len)
		return

	trader_objectives = forge_trader_objectives()

	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Торговца ТСФ?", ROLE_TRADER, TRUE)
		var/index = 1
		while(spawn_count > 0 && candidates.len > 0)
			if(index > spawnlocs.len)
				index = 1

			var/turf/picked_loc = spawnlocs[index]
			index++
			var/mob/C = pick_n_take(candidates)
			spawn_count--
			if(C)
				GLOB.respawnable_list -= C.client
				var/mob/living/carbon/human/M = new /mob/living/carbon/human(picked_loc)
				M.ckey = C.ckey // must be before equipOutfit, or that will runtime due to lack of mind
				M.equipOutfit(/datum/outfit/admin/sol_trader)
				M.dna.species.after_equip_job(null, M)
				M.mind.objectives += trader_objectives
				M.mind.offstation_role = TRUE
				greet_trader(M)
				success_spawn = 1
		if(success_spawn)
			var/map_trader_port = 5
			if(station_name() == "NSS Cyberiad")
				map_trader_port = 4
			GLOB.event_announcement.Announce("Торговый шаттл со станции Юпитер-6 получил разрешение на стыковку в порту прибытия [map_trader_port] [station_name()].", "ОПОВЕЩЕНИЕ: Запрос на стыковку шаттла торговцев принят.")
		else
			GLOB.unused_trade_stations += station // Return the station to the list of usable stations.

/datum/event/traders/proc/greet_trader(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='boldnotice'>Вы - торговец!</span>")
	to_chat(M, "<span class='notice'>В данный момент вы находитесь на [get_area(M)].</span>")
	to_chat(M, "<span class='notice'>Вам предстоит торговать со станцией [station_name()].</span>")
	spawn(25)
		show_objectives(M.mind)

/datum/event/traders/proc/forge_trader_objectives()
	var/list/objs = list()

	var/datum/objective/trade/plasma/P = new /datum/objective/trade/plasma
	P.choose_target()
	objs += P

	var/datum/objective/trade/credits/C = new /datum/objective/trade/credits
	C.choose_target()
	objs += C

	return objs
