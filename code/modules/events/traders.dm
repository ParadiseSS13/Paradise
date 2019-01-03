var/global/list/unused_trade_stations = list("sol")

// Traders event.
// Heavily copy-pasted from "heist" gamemode.

/datum/event/traders
	var/success_spawn = 0
	var/station = null
	var/spawn_count = 3
	var/list/trader_objectives = list()

/datum/event/traders/setup()
	if(unused_trade_stations.len)
		station = pick_n_take(unused_trade_stations)

/datum/event/traders/start()
	if(!station) // If there are no unused stations, just no.
		return
	var/list/spawnlocs = list()
	for(var/obj/effect/landmark/landmark in GLOB.landmarks_list)
		if(landmark.name == "traderstart_[station]")
			spawnlocs += get_turf(landmark)
	if(!spawnlocs.len)
		return

	trader_objectives = forge_trader_objectives()

	spawn()
		var/list/candidates = pollCandidates("Do you want to play as a trader?", ROLE_TRADER, 1)
		var/index = 1
		while(spawn_count > 0 && candidates.len > 0)
			if(index > spawnlocs.len)
				index = 1

			var/turf/picked_loc = spawnlocs[index]
			index++
			var/mob/C = pick_n_take(candidates)
			if(C)
				GLOB.respawnable_list -= C.client
				var/mob/living/carbon/human/M = new /mob/living/carbon/human(picked_loc)
				M.ckey = C.ckey // must be before equipOutfit, or that will runtime due to lack of mind
				M.equipOutfit(/datum/outfit/admin/sol_trader)
				M.dna.species.after_equip_job(null, M)
				M.mind.objectives += trader_objectives
				greet_trader(M)
				success_spawn = 1
		if(!success_spawn)
			unused_trade_stations += station // Return the station to the list of usable stations.

/datum/event/traders/proc/greet_trader(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='boldnotice'>You are a trader!</span>")
	to_chat(M, "<span class='notice'>You are currently docked at [get_area(M)].</span>")
	to_chat(M, "<span class='notice'>You are about to trade with [station_name()].</span>")
	spawn(25)
		show_objectives(M.mind)

/datum/event/traders/proc/forge_trader_objectives()
	var/i = 1
	var/max_objectives = pick(2, 2, 2, 2, 3, 3, 3, 4)
	var/list/objs = list()
	var/list/goals = list("stockparts")
	while(i<= max_objectives)
		var/goal = pick(goals)
		var/datum/objective/trade/O
		if(goal == "stockparts")
			O = new /datum/objective/trade/stock(station)
		O.choose_target()
		objs += O

		i++
	return objs
