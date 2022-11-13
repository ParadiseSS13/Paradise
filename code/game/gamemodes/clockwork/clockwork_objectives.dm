/datum/clockwork_objectives //It's mostly same as blood cult
	var/clock_status = RATVAR_IS_ASLEEP
	var/datum/objective/demand_power/obj_demand = new // I demand three things! Power beacons and clockers
	var/datum/objective/clockgod/obj_summon = new
	var/power_goal = 1
	var/beacon_goal = 1
	var/clocker_goal = 1

/datum/clockwork_objectives/proc/setup()
	if(clock_status != RATVAR_IS_ASLEEP)
		return FALSE
	clock_status = RATVAR_DEMANDS_POWER
	//power_goal in gamemode/clockwork_threshold_check
	beacon_goal = 3 + round(length(GLOB.player_list)*0.1) // 3 + all crew* 0.1
	clocker_goal = round(CLOCK_CREW_REVEAL_HIGH * (length(GLOB.player_list) - SSticker.mode.get_clockers()),1)
	if(obj_demand.check_completion())
		ratvar_is_ready()

/**
  * Called by cultists/cult constructs checking their objectives
  *
  * to_chats mob/living/M the currents status.
  *
  * * display_members set FALSE - additionally how many cult members.
  */
/datum/clockwork_objectives/proc/study(mob/living/M, display_members = FALSE)
	if(!M)
		return FALSE

	switch(clock_status)
		if(RATVAR_IS_ASLEEP)
			to_chat(M, "<span class='clock'>Ratvar is asleep.</span>")
		if(RATVAR_DEMANDS_POWER)
			to_chat(M, "<span class='clock'>The Ratvar seeks the power throught the station. Help him to overcome the mighty Veil!</span>")
			to_chat(M, "<span class='clock'>Current goal: </span>")
			if(!obj_demand.power_get)
				to_chat(M, "<span class='clock'>We need to fulfill the power. Power needed: [GLOB.clockwork_power]/[power_goal]</span>")
			if(!obj_demand.beacon_get)
				to_chat(M, "<span class='clock'>The beacons will mark the soft spots of the Veil. Beacons needed: [length(GLOB.clockwork_beacons)]/[beacon_goal]</span>")
			if(!obj_demand.clockers_get)
				to_chat(M, "<span class='clock'>Let the power from our clockers assemble the path for our Ratvar! Clockers needed: [SSticker.mode.get_clockers()]/[clocker_goal]</span>")
		if(RATVAR_NEEDS_SUMMONING)
			to_chat(M, "<span class='clock'>Ratvar is strong enough! It's time to point his power on weak point of the Veil!</span>")
			to_chat(M, "<span class='clock'>Current goal: [obj_summon.explanation_text]</span>")
		if(RATVAR_HAS_RISEN)
			to_chat(M, "<span class='clocklarge'>\"I am here.\"</span>")
			to_chat(M, "<span class='clock'>Current goal:</span> <span class='clocklarge'>\"Bring me unclocked ones.\"</span>")
		if(RATVAR_HAS_FALLEN)
			to_chat(M, "<span class='clocklarge'>Ratvar has been banished!</span>")
			to_chat(M, "<span class='clock'>Current goal: Slaughter the unbelievers!</span>")
		else
			to_chat(M, "<span class='danger'>Error: Clock cult objective status currently unknown. Something went wrong. Oof.</span>")

	if(display_members)
		var/list/clock_cult = SSticker.mode.get_clockers(TRUE)
		var/total_clockers = clock_cult[1] + clock_cult[2]

		to_chat(M, "<span class='clockitalic'><br><b>Current cult members: [total_clockers]</b></span>")

		if(clock_cult[2]) // If there are any constructs, separate them out
			to_chat(M, "<span class='clockitalic'><b>Clockers:</b> [clock_cult[1]]")
			to_chat(M, "<span class='clockitalic'><b>Constructs:</b> [clock_cult[2]]")

/*
 * Makes a check if power or beacon has been completed.
 *
 * The clockers check is in check_clock_size
 */
/datum/clockwork_objectives/proc/power_check()
	if(GLOB.clockwork_power >= power_goal && !obj_demand.power_get)
		obj_demand.power_get = TRUE
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, "<span class='clocklarge'>Yes! That's enough power i need! Well done...</span>")
				if(!obj_demand.check_completion())
					to_chat(clock_mind.current, "<span class='clock'>But there's still more tasks to do.</span>")
				else
					ratvar_is_ready()
		adjust_clockwork_power(-0.6*power_goal)

/datum/clockwork_objectives/proc/beacon_check()
	if(length(GLOB.clockwork_beacons) >= beacon_goal && !obj_demand.beacon_get)
		obj_demand.beacon_get = TRUE
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, "<span class='clocklarge'>Now i see the weak points of the Veil. You have done well...</span>")
				if(!obj_demand.check_completion())
					to_chat(clock_mind.current, "<span class='clock'>But there's still more tasks to do.</span>")
				else
					ratvar_is_ready()


// After all goals 've completed check this proc for start summoning
/datum/clockwork_objectives/proc/ratvar_is_ready()
	if(clock_status >= RATVAR_NEEDS_SUMMONING) //or already prepared or summoned
		return
	clock_status = RATVAR_NEEDS_SUMMONING
	for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
		if(clock_mind && clock_mind.current)
			to_chat(clock_mind.current, "<span class='clock'>You and your acolytes have succeeded in preparing the station for the ultimate ritual!</span>")
			to_chat(clock_mind.current, "<span class='clock'>Current goal: [obj_summon.explanation_text]</span>")

/datum/clockwork_objectives/proc/succesful_summon()
	clock_status = RATVAR_HAS_RISEN
	obj_summon.summoned = TRUE

/datum/clockwork_objectives/proc/ratvar_death()
	clock_status = RATVAR_HAS_FALLEN
	obj_summon.killed = TRUE

//Objectives

/datum/objective/serveclock //Given to clockers on conversion/roundstart
	explanation_text = "Assist your fellow clockwork associates and Power Ratvar to Tear the Veil! (Use the Study Veil action to check your progress.)"
	completed = TRUE

/datum/objective/demand_power
	var/power_get = FALSE
	var/beacon_get = FALSE
	var/clockers_get = FALSE
	explanation_text = "The Ratvar demands power in order to prepare the summoning."

/datum/objective/demand_power/check_completion()
	return (power_get && beacon_get && clockers_get) || completed


/datum/objective/clockgod
	var/summoned = FALSE
	var/killed = FALSE
	var/list/ritual_spots = list()

/datum/objective/clockgod/New()
	..()
	find_summon_locations()

/datum/objective/clockgod/proc/find_summon_locations(reroll = FALSE)
	if(reroll)
		ritual_spots = new()
	var/sanity = 0
	while(length(ritual_spots) < RATVAR_SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(return_sorted_areas() - ritual_spots)
		var/valid_spot = FALSE
		if(summon && is_station_level(summon.z) && summon.valid_territory) // Check if there's a turf that you can walk on, if not it's not valid
			for(var/turf/T as anything in get_area_turfs(summon))
				if(!T.density)
					var/clear = TRUE
					for(var/obj/O in T)
						if(O.density)
							clear = FALSE
							break
					if(clear)
						valid_spot = TRUE
						break
		if(valid_spot)
			ritual_spots += summon
		sanity++
	explanation_text = "Summon Ratvar by setting up the credence and power it.\
	\nThe summoning can only be accomplished in [english_list(ritual_spots)] - where the veil is weak enough for the ritual to begin."

/datum/objective/clockgod/check_completion()
	if(killed)
		return RATVAR_HAS_FALLEN // You failed so hard that even the code went backwards.
	return summoned || completed
