/*
VOX TRADE ROUNDTYPE
*/

/datum/game_mode/
	var/list/datum/mind/traders = list()  //Antags.


/datum/game_mode/vox/trade
	name = "trade"
	config_tag = "trade"
	required_players = 10
	required_players_secret = 10
	required_enemies = 1
	recommended_enemies = 3

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/trade_objectives = list()     //Trade objectives.

/datum/game_mode/vox/trade/announce()
	world << "<B>The current game mode is - Traders!</B>"
	world << "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>"
	world << "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!"
	world << "<B>Traders:</B> Trade with [station_name()] for anything and everything you need."
	world << "<B>Personnel:</B> Perform your duties normally, earn extra cash to trade with the Vox."

/datum/game_mode/vox/trade/can_start()

	if(!..())
		return 0

	var/list/candidates = get_players_for_role(BE_VOX)
	var/trader_num = 0

	//Check that we have enough vox.
	if(candidates.len < required_enemies)
		return 0
	else if(candidates.len < recommended_enemies)
		trader_num = candidates.len
	else
		trader_num = recommended_enemies

	//Grab candidates randomly until we have enough.
	while(trader_num > 0)
		var/datum/mind/new_trader = pick(candidates)
		traders += new_trader
		candidates -= new_trader
		trader_num--

	for(var/datum/mind/trader in traders)
		trader.assigned_role = "MODE"
		trader.special_role = "Vox Traders"
	return 1

/datum/game_mode/vox/trade/pre_setup()
	return 1

/datum/game_mode/vox/trade/post_setup()

	//Build a list of spawn points.
	var/list/turf/trader_spawn = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			trader_spawn += get_turf(L)
			del(L)
			continue

	//Generate objectives for the group.
	trade_objectives = forge_vox_objectives()

	var/index = 1

	//Spawn the vox!
	for(var/datum/mind/trader in traders)

		if(index > trader_spawn.len)
			index = 1

		trader.current.loc = trader_spawn[index]
		index++

		var/mob/living/carbon/human/vox = trader.current

		trader.name = vox.name
		vox.age = rand(12,20)
		vox.dna.mutantrace = "vox"
		vox.set_species("Vox")
		vox.generate_name()
		vox.languages = list() // Removing language from chargen.
		vox.flavor_text = ""
		vox.add_language("Vox-pidgin")
		vox.h_style = "Short Vox Quills"
		vox.f_style = "Shaved"
		for(var/datum/organ/external/limb in vox.organs)
			limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT)
		vox.equip_vox_raider()
		vox.regenerate_icons()

		trader.objectives = trade_objectives
		greet_vox(trader)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()



/datum/game_mode/vox/trade/proc/forge_vox_objectives()




	trade_objectives += new /datum/objective/vox/trade/raw_materials
	trade_objectives += new /datum/objective/vox/trade/trade
	trade_objectives += new /datum/objective/vox/inviolate_crew
	trade_objectives += new /datum/objective/vox/inviolate_death

	for(var/datum/objective/vox/trade/O in trade_objectives)
		O.choose_target()

	return trade_objectives

/datum/game_mode/vox/trade/proc/greet_vox(var/datum/mind/trader)
	trader.current << "\blue <B>You are a Vox Trader, fresh from the Shoal!</b>"
	trader.current << "\blue The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to Tau Ceti and much of the unexplored galaxy. You and the crew have come to the Exodus for trade."
	trader.current << "\blue Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious."
	trader.current << "\blue Use :V to voxtalk, :H to talk on your encrypted channel, and don't forget to turn on your nitrogen internals!"
	var/obj_count = 1
	for(var/datum/objective/objective in trader.objectives)
		trader.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++


/datum/game_mode/vox/trade/declare_completion()

	//No objectives, go straight to the feedback.
	if(!(trade_objectives.len)) return ..()

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = trade_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in trade_objectives)
		if(!(O.check_completion())) success--

	//Set result by objectives.
	if(success == trade_objectives.len)
		win_type = "Major"
		win_group = "Vox"
	else if(success > 2)
		win_type = "Minor"
		win_group = "Vox"
	else
		win_type = "Minor"
		win_group = "Crew"

	//Now we modify that result by the state of the vox crew.
	if(!is_vox_crew_alive())

		win_type = "Major"
		win_group = "Crew"
		win_msg += "<B>The Vox Traders have been wiped out!</B>"

	else if(!is_vox_crew_safe())

		if(win_group == "Crew" && win_type == "Minor")
			win_type = "Major"

		win_group = "Crew"
		win_msg += "<B>The Vox Traders have left someone behind!</B>"

	else

		if(win_group == "Vox")
			if(win_type == "Minor")

				win_type = "Major"
			win_msg += "<B>The Vox Traders escaped the station!</B>"
		else
			win_msg += "<B>The Vox Traders were repelled!</B>"

	world << "\red <FONT size = 3><B>[win_type] [win_group] victory!</B></FONT>"
	world << "[win_msg]"
	feedback_set_details("round_end_result","trade - [win_type] [win_group]")

	var/count = 1
	for(var/datum/objective/objective in trade_objectives)
		if(objective.check_completion())
			world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
			feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
			feedback_add_details("traitor_objective","[objective.type]|FAIL")
		count++

	..()

datum/game_mode/proc/auto_declare_completion_trade()
	if(traders.len)
		var/check_return = 0
		if(ticker && istype(ticker.mode,/datum/game_mode/vox/trade))
			check_return = 1
		var/text = "<FONT size = 2><B>The vox traders were:</B></FONT>"

		for(var/datum/mind/vox in traders)
			text += "<br>[vox.key] was [vox.name] ("
			if(check_return)
				var/obj/stack = traders[vox]
				if(get_area(stack) != locate(/area/shuttle/vox/station))
					text += "left behind)"
					continue
			if(vox.current)
				if(vox.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vox.current.real_name != vox.name)
					text += " as [vox.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		world << text
	return 1

/datum/game_mode/vox/trade/check_finished()
//	if (!(is_vox_crew_alive()) || (vox_shuttle_location && (vox_shuttle_location == "start")))
//		return 1
	return ..()

/datum/game_mode/vox/trade/proc/is_vox_crew_alive()

	for(var/datum/mind/trader in traders)
		if(trader.current)
			if(istype(trader.current,/mob/living/carbon/human) && trader.current.stat != 2)
				return 1
	return 0