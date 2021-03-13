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
#define NANOTRANSEN_FINEST 5000

/datum/controller/subsystem/ticker/proc/scoreboard()
	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in SSticker.minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	// Score Calculation and Display

	// Who is alive/dead, who escaped
	for(var/mob/living/silicon/ai/I in GLOB.mob_list)
		if(I.stat == DEAD && is_station_level(I.z))
			GLOB.score_deadaipenalty++
			GLOB.score_deadcrew++

	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/I = thing
		if(I.stat == DEAD && is_station_level(I.z))
			GLOB.score_deadcrew++

	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
		for(var/mob/living/player in GLOB.mob_list)
			if(player.client)
				if(player.stat != DEAD)
					var/turf/location = get_turf(player.loc)
					var/area/escape_zone = locate(/area/shuttle/escape)
					if(location in escape_zone)
						GLOB.score_escapees++



	var/cash_score = 0
	var/dmg_score = 0

	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
		for(var/thing in GLOB.human_list)
			var/mob/living/carbon/human/E = thing
			cash_score = 0
			dmg_score = 0
			var/turf/location = get_turf(E.loc)
			var/area/escape_zone = SSshuttle.emergency.areaInstance

			if(E.stat != DEAD && (location in escape_zone)) // Escapee Scores
				cash_score = get_score_container_worth(E)

				if(cash_score > GLOB.score_richestcash)
					GLOB.score_richestcash = cash_score
					GLOB.score_richestname = E.real_name
					GLOB.score_richestjob = E.job
					GLOB.score_richestkey = E.key

				dmg_score = E.getBruteLoss() + E.getFireLoss() + E.getToxLoss() + E.getOxyLoss()
				if(dmg_score > GLOB.score_dmgestdamage)
					GLOB.score_dmgestdamage = dmg_score
					GLOB.score_dmgestname = E.real_name
					GLOB.score_dmgestjob = E.job
					GLOB.score_dmgestkey = E.key

	if(SSticker && SSticker.mode)
		SSticker.mode.set_scoreboard_gvars()


	// Check station's power levels
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/A = thing
		if(!is_station_level(A.z)) continue
		for(var/obj/item/stock_parts/cell/C in A.contents)
			if(C.charge < 2300)
				GLOB.score_powerloss++ //200 charge leeway


	// Check how much uncleaned mess is on the station
	for(var/obj/effect/decal/cleanable/M in world)
		if(!is_station_level(M.z)) continue
		if(istype(M, /obj/effect/decal/cleanable/blood/gibs))
			GLOB.score_mess += 3

		if(istype(M, /obj/effect/decal/cleanable/blood))
			GLOB.score_mess += 1

		if(istype(M, /obj/effect/decal/cleanable/vomit))
			GLOB.score_mess += 1


	// Bonus Modifiers
	var/deathpoints = GLOB.score_deadcrew * 25 //done
	var/researchpoints = GLOB.score_researchdone * 30
	var/eventpoints = GLOB.score_eventsendured * 50
	var/escapoints = GLOB.score_escapees * 25 //done
	var/harvests = GLOB.score_stuffharvested * 5
	var/shipping = GLOB.score_stuffshipped * 5
	var/mining = GLOB.score_oremined * 2 //done, might want polishing
	var/meals = GLOB.score_meals * 5
	var/power = GLOB.score_powerloss * 20
	var/messpoints
	if(GLOB.score_mess != 0)
		messpoints = GLOB.score_mess //done
	var/plaguepoints = GLOB.score_disease * 30


	// Good Things
	GLOB.score_crewscore += shipping
	GLOB.score_crewscore += harvests
	GLOB.score_crewscore += mining
	GLOB.score_crewscore += researchpoints
	GLOB.score_crewscore += eventpoints
	GLOB.score_crewscore += escapoints

	if(power == 0)
		GLOB.score_crewscore += 2500
		GLOB.score_powerbonus = 1


	GLOB.score_crewscore += meals
	if(GLOB.score_allarrested) // This only seems to be implemented for Rev and Nukies. -DaveKorhal
		GLOB.score_crewscore *= 3 // This needs to be here for the bonus to be applied properly


	GLOB.score_crewscore -= deathpoints
	if(GLOB.score_deadaipenalty)
		GLOB.score_crewscore -= 250
	GLOB.score_crewscore -= power


	GLOB.score_crewscore -= messpoints
	GLOB.score_crewscore -= plaguepoints

	// Show the score - might add "ranks" later
	to_chat(world, "<b>The crew's final score is:</b>")
	to_chat(world, "<b><font size='4'>[GLOB.score_crewscore]</font></b>")

	// Generate the score panel
	var/dat = "<b>Round Statistics and Score</b><br><hr>"
	if(mode)
		dat += mode.get_scoreboard_stats()

	dat += {"
	<b><u>General Statistics</u></b><br>
	<u>The Good</u><br>
	<b>Ore Mined:</b> [GLOB.score_oremined] ([GLOB.score_oremined * 2] Points)<br>"}
	if(SSshuttle.emergency.mode == SHUTTLE_ENDGAME) dat += "<b>Shuttle Escapees:</b> [GLOB.score_escapees] ([GLOB.score_escapees * 25] Points)<br>"
	dat += {"
	<b>Whole Station Powered:</b> [GLOB.score_powerbonus ? "Yes" : "No"] ([GLOB.score_powerbonus * 2500] Points)<br><br>

	<U>The Bad</U><br>
	<b>Dead bodies on Station:</b> [GLOB.score_deadcrew] (-[GLOB.score_deadcrew * 25] Points)<br>
	<b>Uncleaned Messes:</b> [GLOB.score_mess] (-[GLOB.score_mess] Points)<br>
	<b>Station Power Issues:</b> [GLOB.score_powerloss] (-[GLOB.score_powerloss * 20] Points)<br>
	<b>AI Destroyed:</b> [GLOB.score_deadaipenalty ? "Yes" : "No"] (-[GLOB.score_deadaipenalty * 250] Points)<br><br>

	<U>The Weird</U><br>
	<b>Food Eaten:</b> [GLOB.score_foodeaten] bites/sips<br>
	<b>Times a Clown was Abused:</b> [GLOB.score_clownabuse]<br><br>
	"}
	if(GLOB.score_escapees)
		dat += {"<b>Richest Escapee:</b> [GLOB.score_richestname], [GLOB.score_richestjob]: $[num2text(GLOB.score_richestcash,50)] ([GLOB.score_richestkey])<br>
		<b>Most Battered Escapee:</b> [GLOB.score_dmgestname], [GLOB.score_dmgestjob]: [GLOB.score_dmgestdamage] damage ([GLOB.score_dmgestkey])<br>"}
	else
		if(SSshuttle.emergency.mode <= SHUTTLE_STRANDED)
			dat += "The station wasn't evacuated!<br>"
		else
			dat += "No-one escaped!<br>"

	dat += mode.declare_job_completion()

	dat += {"
	<hr><br>
	<b><u>FINAL SCORE: [GLOB.score_crewscore]</u></b><br>
	"}

	var/score_rating = "The Aristocrats!"
	switch(GLOB.score_crewscore)
		if(-99999 to SINGULARITY_DESERVES_BETTER) score_rating = 					"Even the Singularity Deserves Better"
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
		if(PRIDE_OF_SCIENCE to NANOTRANSEN_FINEST-1) score_rating = 				"The Pride of Science Itself"
		if(NANOTRANSEN_FINEST to INFINITY) score_rating = 							"Nanotrasen's Finest"

	dat += "<b><u>RATING:</u></b> [score_rating]"
	src << browse(dat, "window=roundstats;size=500x600")

	for(var/mob/E in GLOB.player_list)
		if(E.client && !E.get_preference(PREFTOGGLE_DISABLE_SCOREBOARD))
			E << browse(dat, "window=roundstats;size=500x600")

// A recursive function to properly determine the wealthiest escapee
/datum/controller/subsystem/ticker/proc/get_score_container_worth(atom/C, level=0)
	if(level >= 5)
		// in case the containers recurse or something
		return 0
	else
		. = 0
		for(var/obj/item/card/id/id in C.contents)
			var/datum/money_account/A = get_money_account(id.associated_account_number)
			// has an account?
			if(A)
				. += A.money
		for(var/obj/item/stack/spacecash/cash in C.contents)
			. += cash.amount
		for(var/obj/item/storage/S in C.contents)
			. += .(S, level + 1)

/datum/game_mode/proc/get_scoreboard_stats()
	return null

/datum/game_mode/proc/set_scoreboard_gvars()
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
#undef NANOTRANSEN_FINEST
