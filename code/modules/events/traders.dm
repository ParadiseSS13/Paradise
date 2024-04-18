GLOBAL_LIST_INIT(unused_trade_stations, list("sol"))

// Traders event.
// Heavily copy-pasted from "heist" gamemode.

/datum/event/traders
	var/success_spawn = 0
	var/station = null
	var/spawn_count = 2
	var/list/trader_objectives = list()

/datum/event/traders/setup()
	if(length(GLOB.unused_trade_stations))
		station = pick_n_take(GLOB.unused_trade_stations)

/datum/event/traders/fake_announce()
	. = TRUE
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		GLOB.minor_announcement.Announce("A trading shuttle from Jupiter Station has been denied docking permission due to the heightened security alert aboard [station_name()].", "Trader Shuttle Docking Request Refused")
		return
	GLOB.minor_announcement.Announce("A trading shuttle from Jupiter Station has been granted docking permission at [station_name()] arrivals port 4.", "Trader Shuttle Docking Request Accepted")


/datum/event/traders/start()
	if(!station) // If there are no unused stations, just no.
		return
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		GLOB.minor_announcement.Announce("A trading shuttle from Jupiter Station has been denied docking permission due to the heightened security alert aboard [station_name()].", "Trader Shuttle Docking Request Refused")
		// if the docking request was refused, fire another major event in 60 seconds
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return

	var/list/spawnlocs = list()
	for(var/obj/effect/landmark/spawner/soltrader/S in GLOB.landmarks_list)
		spawnlocs += get_turf(S)
	if(!length(spawnlocs))
		return

	trader_objectives = forge_trader_objectives()

	INVOKE_ASYNC(src, PROC_REF(spawn_traders), spawnlocs)

/datum/event/traders/proc/spawn_traders(list/spawnlocs)
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Sol Trader?", ROLE_TRADER, TRUE)
	var/index = 1
	while(spawn_count > 0 && length(candidates))
		if(index > length(spawnlocs))
			index = 1

		var/turf/picked_loc = spawnlocs[index]
		index++
		var/mob/C = pick_n_take(candidates)
		spawn_count--
		if(C)
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(picked_loc)
			M.ckey = C.ckey // must be before equipOutfit, or that will runtime due to lack of mind
			dust_if_respawnable(C)
			M.equipOutfit(/datum/outfit/admin/sol_trader)
			M.dna.species.after_equip_job(null, M)
			for(var/datum/objective/O in trader_objectives)
				M.mind.objective_holder.add_objective(O) // traders dont have a team, so we manually have to add this objective to all of their minds, without setting an owner
			M.mind.offstation_role = TRUE
			greet_trader(M)
			success_spawn = TRUE
	if(success_spawn)
		GLOB.minor_announcement.Announce("A trading shuttle from Jupiter Station has been granted docking permission at [station_name()] arrivals port 4.", "Trader Shuttle Docking Request Accepted")
	else
		GLOB.unused_trade_stations += station // Return the station to the list of usable stations.

/datum/event/traders/proc/greet_trader(mob/living/carbon/human/M)
	var/list/messages = list()
	messages.Add("<span class='boldnotice'>You are a trader!</span><span class='notice'>You are currently docked at [get_area(M)].<br>You are about to trade with [station_name()].</span><br>")
	messages.Add(M.mind.prepare_announce_objectives())
	to_chat(M, chat_box_green(messages.Join("<br>")))
	M.create_log(MISC_LOG, "[M] was made into a Sol Trader")

/datum/event/traders/proc/forge_trader_objectives()
	var/list/objs = list()

	objs += new /datum/objective/trade/plasma
	objs += new /datum/objective/trade/credits

	return objs
