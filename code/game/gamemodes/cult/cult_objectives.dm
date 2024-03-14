// Objectives
/// Given to cultists on conversion/roundstart
/datum/objective/servecult
	explanation_text = "Assist your fellow cultists and Tear the Veil! (Use the Study Veil action to check your progress.)"
	completed = TRUE
	needs_target = FALSE

/datum/objective/sacrifice
	var/sacced = FALSE
	explanation_text = "Sacrifice a crewmember in order to prepare the summoning."

/datum/objective/sacrifice/check_completion()
	return sacced || completed

/datum/objective/sacrifice/find_target(list/target_blacklist)
	. = ..()
	if(target && !(target in target_blacklist)) // check the blacklist, it wont update otherwise
		return

	//There are no living unconvertables on the station. Looking for a Sacrifice Target among the convertable minds
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target in target_blacklist)
			continue
		var/mind_result = is_invalid_target(possible_target)
		if(mind_result && mind_result != TARGET_INVALID_CULT_CONVERTABLE)
			continue

		possible_targets += possible_target

	if(length(possible_targets))
		target = pick(possible_targets)
		update_explanation_text()
		return TRUE

	message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. Nar'Sie summoning unlocked!")
	return FALSE

/datum/objective/sacrifice/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	if(possible_target.has_antag_datum(/datum/antagonist/cultist))
		return TARGET_INVALID_CULTIST
	if(!SSticker.mode.cult_team)
		stack_trace("/datum/objective/sacrifice/is_invalid_target was called without there being an assigned cult team")
		return
	if(SSticker.mode.cult_team.is_convertable_to_cult(possible_target))
		return TARGET_INVALID_CULT_CONVERTABLE

/datum/objective/sacrifice/update_explanation_text()
	if(target?.current)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking an Offer rune with [target.p_their()] body or brain on it and three acolytes around it."
	else
		// Code will reach here as part of find_target, but people should never be able to READ it.
		explanation_text = "If you're reading this, something went very wrong. Contact an admin."


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
