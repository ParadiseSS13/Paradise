GLOBAL_VAR(scoreboard) // Variable to save the scoreboard string once it's been generated

//Thresholds for Score Ratings
#define SINGULARITY_DESERVES_BETTER -3500
#define SINGULARITY_FODDER -3000
#define ALL_FIRED -2500
#define WASTE_OF_OXYGEN -2000
#define HEAP_OF_SCUM -1500
#define LAB_MONKEYS -1000
#define UNDESIREABLES -500
#define SERVANTS_OF_SCIENCE 500
#define GOOD_BUNCH 1000
#define MACHINE_THIRTEEN 1500
#define PROMOTIONS_FOR_EVERYONE 2000
#define AMBASSADORS_OF_DISCOVERY 3000
#define PRIDE_OF_SCIENCE 4000
#define NANOTRASEN_FINEST 5000

/datum/scoreboard
	/// Overall combined score for the whole round.
	var/crewscore = 0
	/// How many useful items have cargo shipped out?
	var/score_things_shipped = 0
	/// How many harvests have hydroponics done?
	var/score_things_harvested = 0
	/// How much ore has been mined on the mining z level?
	var/score_ore_mined = 0
	/// How much research was done by science?
	var/score_research_done = 0
	/// How many random events did the station survive?
	var/score_events_endured = 0
	/// How many APCs have poor charge?
	var/score_power_loss = 0
	/// How many GigaJoules of power did we export?
	var/score_gigajoules_exported = 0
	/// How many people got out alive?
	var/score_escapees = 0
	/// How many people /didn't/ get out alive?
	var/score_dead_crew = 0
	/// How much blood, puke, stains etc went uncleaned?
	var/score_mess = 0
	/// How many meals were made?
	var/score_meals = 0
	/// How many rampant, uncured diseases are on board the station?
	var/score_disease = 0
	/// How many command members died? (Revolution)
	var/score_dead_command = 0
	/// How many antagonists are alive in the brig? (Nuke ops & Revolution)
	var/score_arrested = 0
	/// How many operatives were killed? (Nuke ops & Revolution)
	var/score_ops_killed = 0
	/// How much noms were had by the crew?
	var/score_food_eaten = 0
	/// How many times was the clown punched, struck, or otherwise maligned?
	var/score_clown_abuse = 0

	// Booleans //
	/// Were the antagonists successful?
	var/score_greentext = FALSE
	/// Did the crew catch all of the antags alive?
	var/all_arrested = FALSE
	/// Is the NAD safe and secure?
	var/disc_secure = FALSE

	// Points penalties/bonuses //
	/// If all APCs on the station are running optimally, big bonus.
	var/power_bonus = FALSE
	/// If there are no messes on the station anywhere, huge bonus.
	var/mess_bonus = FALSE
	/// If the AI is dead, big points penalty.
	var/dead_ai = FALSE
	/// Was the station blown into little bits?
	var/nuked = FALSE
	/// Points penalty for being blown to little bits.
	var/nuked_penalty = 0

	// Player Stats //
	/// What was the name of the richest person on the shuttle?
	var/richest_name = ""
	/// What was the ckey of the richest person on the shuttle?
	var/richest_key = ""
	/// What was the job of the richest person on the shuttle?
	var/richest_job = ""
	/// How much money did the richest person on the shuttle have?
	var/richest_cash = 0

	/// What was the name of the most injured person on the shuttle?
	var/damaged_name
	/// What was the ckey of the most injured person on the shuttle?
	var/damaged_key
	/// What was the job of the most injured person on the shuttle?
	var/damaged_job
	/// How damaged was the most injured person on the shuttle?
	var/damaged_health


/datum/scoreboard/proc/scoreboard()
	// Print a list of antagonists to the server log.
	log_antags()

	for(var/_I in GLOB.mob_list)
		var/mob/M = _I
		if(is_station_level(M.z))
			check_station_player(M)
		else if(!M.loc)
			stack_trace("[M] ended up without a location!")
		else if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME && istype(get_area(M), SSshuttle.emergency.areaInstance))
			check_shuttle_player(M)

	check_apc_power()
	check_cleanables()

	generate_scoreboard()

/datum/scoreboard/proc/log_antags()
	var/list/total_antagonists = list()
	// Look into all mobs in the world, dead or alive
	for(var/mind in SSticker.minds)
		var/datum/mind/M = mind
		var/role = M.special_role

		// If they're an antagonist of some sort.
		if(role)
			if(total_antagonists[role]) // If the role exists already, add the name to it.
				total_antagonists[role] += ", [M.name]([M.key])"
			else // If the role doesn't exist in the list, create it and add the mob
				total_antagonists[role] += ": [M.name]([M.key])"

	// Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/I in total_antagonists)
		log_game("[I]s[total_antagonists[I]].")


/datum/scoreboard/proc/check_station_player(mob/M)
	if(!is_station_level(M.z) || M.stat != DEAD)
		return
	if(is_ai(M))
		dead_ai = TRUE
		score_dead_crew++
	else if(ishuman(M))
		score_dead_crew++

/datum/scoreboard/proc/check_shuttle_player(mob/M)
	if(!M.mind || M.stat == DEAD || !ishuman(M))
		return
	var/mob/living/carbon/human/H = M

	score_escapees++

	var/cash_score = get_score_person_worth(H)
	if(cash_score > richest_cash)
		richest_cash = cash_score
		richest_name = H.real_name
		richest_job = H.job
		richest_key = (H.client?.prefs.toggles2 & PREFTOGGLE_2_ANON) ? "Anon" : H.key

	var/damage_score = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss() + H.getOxyLoss()
	if(damage_score > damaged_health)
		damaged_health = damage_score
		damaged_name = H.real_name
		damaged_job = H.job
		damaged_key = (H.client?.prefs.toggles2 & PREFTOGGLE_2_ANON) ? "Anon" : H.key

/// A function to determine the cash plus the account balance of the wealthiest escapee
/datum/scoreboard/proc/get_score_person_worth(mob/living/carbon/human/H)
	if(!H.mind)
		return // if they have no mind, we don't care
	// return value of space cash on the person + whatever balance they currently have in their original money account
	return get_score_container_worth(H) + H.mind.initial_account?.credit_balance

/// A recursive function to properly determine the cash on the wealthiest escapee
/datum/scoreboard/proc/get_score_container_worth(atom/C, level = 0)
	. = 0
	if(level >= 5) // in case the containers recurse or something
		return 0

	for(var/obj/item/stack/spacecash/cash in C.contents)
		. += cash.amount
	for(var/obj/item/storage/S in C.contents)
		. += .(S, level + 1)

/datum/scoreboard/proc/check_apc_power()
	for(var/_A in GLOB.apcs)
		var/obj/machinery/power/apc/A = _A
		if(!is_station_level(A.z))
			continue
		var/obj/item/stock_parts/cell/C = A.cell
		if(!C || C.charge < 2300)
			score_power_loss++ //200 charge leeway

/datum/scoreboard/proc/check_cleanables()
	for(var/obj/effect/decal/cleanable/C in world)
		if(!is_station_level(C.z))
			continue
		if(istype(C, /obj/effect/decal/cleanable/blood/gibs))
			score_mess += 3
		else if(istype(C, /obj/effect/decal/cleanable/blood))
			score_mess += 1
		else if(istype(C, /obj/effect/decal/cleanable/vomit))
			score_mess += 1


/datum/scoreboard/proc/generate_scoreboard()
	// Point modifiers
	var/points_events_endured = score_events_endured	 * 50
	var/points_research_done = score_research_done		 * 30
	var/points_disease = score_disease					 * 30
	var/points_dead_crew = score_dead_crew				 * 25
	var/points_escapees = score_escapees				 * 25
	var/points_power_loss = score_power_loss			 * 20
	var/points_things_harvested = score_things_harvested * 5
	var/points_things_shipped = score_things_shipped	 * 5
	var/points_meals = score_meals						 * 5
	var/points_ore_mined = score_ore_mined				 * 2

	// Bonuses
	crewscore += points_events_endured
	crewscore += points_research_done
	crewscore += points_escapees
	crewscore += points_things_harvested
	crewscore += points_things_shipped
	crewscore += points_meals
	crewscore += points_ore_mined

	if(!score_power_loss)
		crewscore += 2500
		power_bonus = TRUE

	if(!score_mess)
		crewscore += 1500
		mess_bonus = TRUE

	if(all_arrested) // This only seems to be implemented for Rev and Nukies. -DaveKorhal
		crewscore *= 3 // This needs to be here for the bonus to be applied properly

	// Penalties
	crewscore -= points_dead_crew
	crewscore -= points_power_loss
	crewscore -= points_disease
	crewscore -= score_mess

	if(dead_ai)
		crewscore -= 250


	// Generate the score panel
	var/list/dat = list("<!DOCTYPE html><meta charset='UTF-8'><b>Round Statistics and Score</b><br><hr>")
	if(SSticker.mode)
		dat += SSticker.mode.get_scoreboard_stats()

	dat += {"
	<b><u>General Statistics</u></b><br>
	<u>The Good</u><br>
	<b>Ore Mined:</b> [score_ore_mined] ([points_ore_mined] Points)<br>"}
	if(score_escapees)
		dat += "<b>Shuttle Escapees:</b> [score_escapees] ([points_escapees] Points)<br>"
	dat += "<b>Energy Exported:</b> [score_gigajoules_exported] GigaJoules<br>"
	dat += "<b>Whole Station Powered:</b> [power_bonus ? "Yes" : "No"] ([power_bonus * 2500] Points)<br>"
	dat += "<b>Whole Station Cleaned:</b> [mess_bonus ? "Yes" : "No"] ([mess_bonus * 1500] Points)<br><br>"

	dat += "<U>The Bad</U><br>"
	dat += "<b>Dead bodies on Station:</b> [score_dead_crew] (-[points_dead_crew] Points)<br>"
	if(!mess_bonus)
		dat += "<b>Uncleaned Messes:</b> [score_mess] (-[score_mess] Points)<br>"
	if(!power_bonus)
		dat += "<b>Station Power Issues:</b> [score_power_loss] (-[points_power_loss] Points)<br>"
	dat += {"
	<b>AI Destroyed:</b> [dead_ai ? "Yes" : "No"] (-[dead_ai * 250] Points)<br><br>

	<U>The Weird</U><br>
	<b>Food Eaten:</b> [score_food_eaten] bites/sips.<br>
	<b>Times a Clown was Abused:</b> [score_clown_abuse]<br><br>"}
	if(score_escapees)
		dat += "<b>Richest Escapee:</b> [richest_name], [richest_job]: $[num2text(richest_cash, 50)] ([richest_key])<br>"
		if(damaged_health)
			dat += "<b>Most Battered Escapee:</b> [damaged_name], [damaged_job]: [damaged_health] damage ([damaged_key])<br>"
	else
		if(SSshuttle.emergency.mode <= SHUTTLE_STRANDED)
			dat += "The station wasn't evacuated!<br>"
		else
			dat += "No-one escaped!<br>"

	dat += SSticker.mode.declare_job_completion()

	dat += {"
	<hr><br>
	<b><u>FINAL SCORE: [crewscore]</u></b><br>
	"}

	var/score_rating = "The Aristocrats!"
	switch(crewscore)
		if(-INFINITY to SINGULARITY_DESERVES_BETTER) score_rating = 				"Even the Singularity Deserves Better"
		if(SINGULARITY_DESERVES_BETTER+1 to SINGULARITY_FODDER) score_rating = 		"Singularity Fodder"
		if(SINGULARITY_FODDER+1 to ALL_FIRED) score_rating = 						"You're All Fired"
		if(ALL_FIRED+1 to WASTE_OF_OXYGEN) score_rating = 							"A Waste of Perfectly Good Oxygen"
		if(WASTE_OF_OXYGEN+1 to HEAP_OF_SCUM) score_rating = 						"A Wretched Heap of Scum and Incompetence"
		if(HEAP_OF_SCUM+1 to LAB_MONKEYS) score_rating = 							"Outclassed by Lab Monkeys"
		if(LAB_MONKEYS+1 to UNDESIREABLES) score_rating = 							"The Undesirables"
		if(UNDESIREABLES+1 to SERVANTS_OF_SCIENCE-1) score_rating = 				"Ambivalently Average"
		if(SERVANTS_OF_SCIENCE to GOOD_BUNCH-1) score_rating = 						"Skillful Servants of Science"
		if(GOOD_BUNCH to MACHINE_THIRTEEN-1) score_rating = 						"Best of a Good Bunch"
		if(MACHINE_THIRTEEN to PROMOTIONS_FOR_EVERYONE-1) score_rating = 			"Lean Mean Machine Thirteen"
		if(PROMOTIONS_FOR_EVERYONE to AMBASSADORS_OF_DISCOVERY-1) score_rating = 	"Promotions for Everyone"
		if(AMBASSADORS_OF_DISCOVERY to PRIDE_OF_SCIENCE-1) score_rating = 			"Ambassadors of Discovery"
		if(PRIDE_OF_SCIENCE to NANOTRASEN_FINEST-1) score_rating = 				"The Pride of Science Itself"
		if(NANOTRASEN_FINEST to INFINITY) score_rating = 							"Nanotrasen's Finest"

	dat += "<b><u>RATING:</u></b> [score_rating]"
	GLOB.scoreboard = jointext(dat, "")

	for(var/mob/E in GLOB.player_list)
		if(E.client)
			to_chat(E, "<b>The crew's final score is:</b>")
			to_chat(E, "<b><font size='4'><a href='byond://?src=[E.UID()];scoreboard=1'>[crewscore]</a></font></b>")
			to_chat(E, "<b><font size='4'><a href='byond://?src=[E.UID()];station_report=1'>View Station Report</a></font></b>")
			if(!E.get_preference(PREFTOGGLE_DISABLE_SCOREBOARD))
				E << browse(GLOB.scoreboard, "window=roundstats;size=500x600")


/datum/game_mode/proc/get_scoreboard_stats()
	return null

/datum/game_mode/proc/set_scoreboard_vars()
	return null

#undef SINGULARITY_DESERVES_BETTER
#undef SINGULARITY_FODDER
#undef ALL_FIRED
#undef WASTE_OF_OXYGEN
#undef HEAP_OF_SCUM
#undef LAB_MONKEYS
#undef UNDESIREABLES
#undef SERVANTS_OF_SCIENCE
#undef GOOD_BUNCH
#undef MACHINE_THIRTEEN
#undef PROMOTIONS_FOR_EVERYONE
#undef AMBASSADORS_OF_DISCOVERY
#undef PRIDE_OF_SCIENCE
#undef NANOTRASEN_FINEST
