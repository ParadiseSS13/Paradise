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
	for(var/obj/effect/landmark/landmark in landmarks_list)
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
				respawnable_list -= C.client
				var/mob/living/carbon/human/M = create_trader(picked_loc)
				M.ckey = C.ckey
				M.mind.objectives += trader_objectives
				greet_trader(M)
				success_spawn = 1
		if(!success_spawn)
			unused_trade_stations += station // Return the station to the list of usable stations.

/datum/event/traders/proc/create_trader(var/turf/picked_loc)
	var/mob/living/carbon/human/M
	switch(station)
		if("sol")
			M = new /mob/living/carbon/human(picked_loc)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(M), slot_back)
			var/obj/item/weapon/card/id/supply/W = new(M)
			W.name = "[M.real_name]'s ID Card (Sol Trader)"
			W.assignment = "Sol Trader"
			W.registered_name = M.real_name
			W.access = list(access_trade_sol, access_maint_tunnels, access_external_airlocks)
			M.equip_to_slot_or_del(W, slot_wear_id)
	return M

/datum/event/traders/proc/greet_trader(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='boldnotice'>You are a trader!</span>")
	to_chat(M, "<span class='notice'>You are currently docked at [get_area(M)].</span>")
	to_chat(M, "<span class='notice'>You are about to trade with NSS Cyberiad.</span>")
	to_chat(M, "<span class='notice'>Negotiate an agreement, and request docking.</span>")
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
