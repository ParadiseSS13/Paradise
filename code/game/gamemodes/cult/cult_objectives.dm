// Objectives
/datum/objective/servecult //Given to cultists on conversion/roundstart
	explanation_text = "Assist your fellow cultists and Tear the Veil! (Use the Study Veil action to check your progress.)"
	completed = TRUE
	needs_target = FALSE

/datum/objective/sacrifice
	var/sacced = FALSE
	explanation_text = "Sacrifice a crewmember in order to prepare the summoning."

/datum/objective/sacrifice/check_completion()
	return sacced || completed

/datum/objective/sacrifice/find_target()
	var/list/target_candidates = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(is_admin_level(H.z)) //We can't sacrifice people that are on the centcom z-level
			continue
		if(H.mind && !H.mind.has_antag_datum(/datum/antagonist/cultist) && !is_convertable_to_cult(H.mind) && (H.stat != DEAD) && !H.mind.offstation_role)
			target_candidates += H.mind
	if(!length(target_candidates))	//There are no living unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(is_admin_level(H.z)) //We can't sacrifice people that are on the centcom z-level
				continue
			if(H.mind && !H.mind.has_antag_datum(/datum/antagonist/cultist) && (H.stat != DEAD) && !H.mind.offstation_role) // Same checks, but add them even if they could be converted
				target_candidates += H.mind
	if(length(target_candidates))
		target = pick(target_candidates)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking an Offer rune with [target.p_their()] body or brain on it and three acolytes around it."
		return TRUE
	message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. Nar'Sie summoning unlocked!")
	return FALSE


/datum/objective/eldergod
	needs_target = FALSE
	var/summoned = FALSE
	var/killed = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	find_summon_locations()

/datum/objective/eldergod/proc/find_summon_locations(reroll = FALSE)
	if(reroll)
		summon_spots = new()
	var/sanity = 0
	while(length(summon_spots) < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(return_sorted_areas() - summon_spots)
		var/valid_spot = FALSE
		if(summon && is_station_level(summon.z) && summon.valid_territory) // Check if there's a turf that you can walk on, if not it's not valid
			for(var/turf/T in get_area_turfs(summon))
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
			summon_spots += summon
		sanity++
	explanation_text = "Summon [GET_CULT_DATA(entity_name, "your god")] by invoking the rune 'Tear Veil' with 9 cultists, constructs, or summoned ghosts on it.\
	\nThe summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin."


/datum/objective/eldergod/check_completion()
	if(killed)
		return NARSIE_HAS_FALLEN // You failed so hard that even the code went backwards.
	return summoned || completed
