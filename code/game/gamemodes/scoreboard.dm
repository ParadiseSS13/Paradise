/datum/controller/gameticker/proc/scoreboard()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
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
			score_deadaipenalty++
			score_deadcrew++

	for(var/mob/living/carbon/human/I in GLOB.mob_list)
		if(I.stat == DEAD && is_station_level(I.z))
			score_deadcrew++

	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
		for(var/mob/living/player in GLOB.mob_list)
			if(player.client)
				if(player.stat != DEAD)
					var/turf/location = get_turf(player.loc)
					var/area/escape_zone = locate(/area/shuttle/escape)
					if(location in escape_zone)
						score_escapees++



	var/cash_score = 0
	var/dmg_score = 0

	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
		for(var/mob/living/carbon/human/E in GLOB.mob_list)
			cash_score = 0
			dmg_score = 0
			var/turf/location = get_turf(E.loc)
			var/area/escape_zone = SSshuttle.emergency.areaInstance

			if(E.stat != DEAD && location in escape_zone) // Escapee Scores
				cash_score = get_score_container_worth(E)

				if(cash_score > score_richestcash)
					score_richestcash = cash_score
					score_richestname = E.real_name
					score_richestjob = E.job
					score_richestkey = E.key

				dmg_score = E.bruteloss + E.fireloss + E.toxloss + E.oxyloss
				if(dmg_score > score_dmgestdamage)
					score_dmgestdamage = dmg_score
					score_dmgestname = E.real_name
					score_dmgestjob = E.job
					score_dmgestkey = E.key

	if(ticker && ticker.mode)
		ticker.mode.set_scoreboard_gvars()


	// Check station's power levels
	for(var/obj/machinery/power/apc/A in GLOB.apcs)
		if(!is_station_level(A.z)) continue
		for(var/obj/item/stock_parts/cell/C in A.contents)
			if(C.charge < 2300)
				score_powerloss++ //200 charge leeway


	// Check how much uncleaned mess is on the station
	for(var/obj/effect/decal/cleanable/M in world)
		if(!is_station_level(M.z)) continue
		if(istype(M, /obj/effect/decal/cleanable/blood/gibs))
			score_mess += 3

		if(istype(M, /obj/effect/decal/cleanable/blood))
			score_mess += 1

		if(istype(M, /obj/effect/decal/cleanable/vomit))
			score_mess += 1


	// Bonus Modifiers
	//var/traitorwins = score_traitorswon
	var/deathpoints = score_deadcrew * 25 //done
	var/researchpoints = score_researchdone * 30
	var/eventpoints = score_eventsendured * 50
	var/escapoints = score_escapees * 25 //done
	var/harvests = score_stuffharvested * 5 //done
	var/shipping = score_stuffshipped * 5
	var/mining = score_oremined * 2 //done
	var/meals = score_meals * 5 //done, but this only counts cooked meals, not drinks served
	var/power = score_powerloss * 20
	var/messpoints
	if(score_mess != 0)
		messpoints = score_mess //done
	var/plaguepoints = score_disease * 30


	// Good Things
	score_crewscore += shipping
	score_crewscore += harvests
	score_crewscore += mining
	score_crewscore += researchpoints
	score_crewscore += eventpoints
	score_crewscore += escapoints

	if(power == 0)
		score_crewscore += 2500
		score_powerbonus = 1

	if(score_mess == 0)
		score_crewscore += 3000
		score_messbonus = 1


	score_crewscore += meals
	if(score_allarrested)
		score_crewscore *= 3 // This needs to be here for the bonus to be applied properly


	score_crewscore -= deathpoints
	if(score_deadaipenalty)
		score_crewscore -= 250
	score_crewscore -= power


	score_crewscore -= messpoints
	score_crewscore -= plaguepoints

	// Show the score - might add "ranks" later
	to_chat(world, "<b>The crew's final score is:</b>")
	to_chat(world, "<b><font size='4'>[score_crewscore]</font></b>")
	for(var/mob/E in GLOB.player_list)
		if(E.client && !E.get_preference(DISABLE_SCOREBOARD))
			E.scorestats()

// A recursive function to properly determine the wealthiest escapee
/datum/controller/gameticker/proc/get_score_container_worth(atom/C, level=0)
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

/mob/proc/scorestats()
	var/dat = "<b>Round Statistics and Score</b><br><hr>"
	if(ticker && ticker.mode)
		dat += ticker.mode.get_scoreboard_stats()

	dat += {"
	<b><u>General Statistics</u></b><br>
	<u>The Good:</u><br>

	<b>Useful Items Shipped:</b> [score_stuffshipped] ([score_stuffshipped * 5] Points)<br>
	<b>Hydroponics Harvests:</b> [score_stuffharvested] ([score_stuffharvested * 5] Points)<br>
	<b>Ore Mined:</b> [score_oremined] ([score_oremined * 2] Points)<br>
	<b>Refreshments Prepared:</b> [score_meals] ([score_meals * 5] Points)<br>
	<b>Research Completed:</b> [score_researchdone] ([score_researchdone * 30] Points)<br>"}
	if(SSshuttle.emergency.mode == SHUTTLE_ENDGAME) dat += "<b>Shuttle Escapees:</b> [score_escapees] ([score_escapees * 25] Points)<br>"
	dat += {"<b>Random Events Endured:</b> [score_eventsendured] ([score_eventsendured * 50] Points)<br>
	<b>Whole Station Powered:</b> [score_powerbonus ? "Yes" : "No"] ([score_powerbonus * 2500] Points)<br>
	<b>Ultra-Clean Station:</b> [score_mess ? "No" : "Yes"] ([score_messbonus * 3000] Points)<br><br>
	<U>The bad:</U><br>

	<b>Dead bodies on Station:</b> [score_deadcrew] (-[score_deadcrew * 25] Points)<br>
	<b>Uncleaned Messes:</b> [score_mess] (-[score_mess] Points)<br>
	<b>Station Power Issues:</b> [score_powerloss] (-[score_powerloss * 20] Points)<br>
	<b>Rampant Diseases:</b> [score_disease] (-[score_disease * 30] Points)<br>
	<b>AI Destroyed:</b> [score_deadaipenalty ? "Yes" : "No"] (-[score_deadaipenalty * 250] Points)<br><br>
	<U>The Weird</U><br>

	<b>Food Eaten:</b> [score_foodeaten] bites/sips<br>
	<b>Times a Clown was Abused:</b> [score_clownabuse]<br><br>
	"}
	if(score_escapees)
		dat += {"<b>Richest Escapee:</b> [score_richestname], [score_richestjob]: $[num2text(score_richestcash,50)] ([score_richestkey])<br>
		<b>Most Battered Escapee:</b> [score_dmgestname], [score_dmgestjob]: [score_dmgestdamage] damage ([score_dmgestkey])<br>"}
	else
		if(SSshuttle.emergency.mode <= SHUTTLE_STRANDED)
			dat += "The station wasn't evacuated!<br>"
		else
			dat += "No-one escaped!<br>"

	dat += ticker.mode.declare_job_completion()

	dat += {"
	<hr><br>
	<b><u>FINAL SCORE: [score_crewscore]</u></b><br>
	"}

	var/score_rating = "The Aristocrats!"
	switch(score_crewscore)
		if(-99999 to -50000) score_rating = "Even the Singularity Deserves Better"
		if(-49999 to -5000) score_rating = "Singularity Fodder"
		if(-4999 to -1000) score_rating = "You're All Fired"
		if(-999 to -500) score_rating = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250) score_rating = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100) score_rating = "Outclassed by Lab Monkeys"
		if(-99 to -21) score_rating = "The Undesirables"
		if(-20 to 20) score_rating = "Ambivalently Average"
		if(21 to 99) score_rating = "Not Bad, but Not Good"
		if(100 to 249) score_rating = "Skillful Servants of Science"
		if(250 to 499) score_rating = "Best of a Good Bunch"
		if(500 to 999) score_rating = "Lean Mean Machine Thirteen"
		if(1000 to 4999) score_rating = "Promotions for Everyone"
		if(5000 to 9999) score_rating = "Ambassadors of Discovery"
		if(10000 to 49999) score_rating = "The Pride of Science Itself"
		if(50000 to INFINITY) score_rating = "Nanotrasen's Finest"

	dat += "<b><u>RATING:</u></b> [score_rating]"
	src << browse(dat, "window=roundstats;size=500x600")
