/datum/cult_objectives //Replace with team antag datum objectives from tg once ported
	var/cult_status = NARSIE_IS_ASLEEP
	var/list/presummon_objs = list()
	var/datum/objective/eldergod/obj_summon = new
	var/sacrifices_done = 0
	var/sacrifices_required = 2

/datum/cult_objectives/proc/setup()
	if(cult_status != NARSIE_IS_ASLEEP)
		return FALSE
	cult_status = NARSIE_DEMANDS_SACRIFICE
	var/datum/objective/sacrifice/obj_sac = new
	if(obj_sac.find_target())
		presummon_objs.Add(obj_sac)
	else
		ready_to_summon()

/datum/cult_objectives/proc/study(mob/living/M, display_members = FALSE) //Called by cultists/cult constructs checking their objectives
	if(!M)
		return FALSE

	switch(cult_status)
		if(NARSIE_IS_ASLEEP)
			to_chat(M, "<span class='cult'>[SSticker.cultdat ? SSticker.cultdat.entity_name : "The Dark One"] is asleep.</span>")
		if(NARSIE_DEMANDS_SACRIFICE)
			if(!length(presummon_objs))
				to_chat(M, "<span class='danger'>Error: No objectives in sacrifice list. Something went wrong. Oof.</span>")
			else
				var/datum/objective/sacrifice/current_obj = presummon_objs[length(presummon_objs)] //get the last obj in the list, ie the current one
				to_chat(M, "<span class='cult'>The Veil needs to be weakened before we are able to summon [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "The Dark One"].</span>")
				to_chat(M, "<span class='cult'>Current goal: [current_obj.explanation_text]</span>")
		if(NARSIE_NEEDS_SUMMONING)
			to_chat(M, "<span class='cult'>The Veil is weak! We can summon [SSticker.cultdat ? SSticker.cultdat.entity_title3 : "The Dark One"]!</span>")
			to_chat(M, "<span class='cult'>Current goal: [obj_summon.explanation_text]</span>")
		if(NARSIE_HAS_RISEN)
			to_chat(M, "<span class='cultlarge'>\"I am here.\"</span>")
			to_chat(M, "<span class='cult'>Current goal:</span> <span class='cultlarge'>\"Feed me.\"</span>")
		if(NARSIE_HAS_FALLEN)
			to_chat(M, "<span class='cultlarge'>[SSticker.cultdat ? SSticker.cultdat.entity_name : "The Dark One"] has been banished!</span>")
			to_chat(M, "<span class='cult'>Current goal: Slaughter the unbelievers!</span>")
		else
			to_chat(M, "<span class='danger'>Error: Cult objective status currently unknown. Something went wrong. Oof.</span>")

	if(display_members)
		var/list/cult = SSticker.mode.get_cultists(TRUE)
		var/total_cult = cult[1] + cult[2]
		var/rise = SSticker.mode.rise_number - total_cult
		var/ascend = SSticker.mode.ascend_number - total_cult

		var/overview = "<span class='cultitalic'><br><b>Current cult members: [total_cult]"
		if(!SSticker.mode.cult_ascendant)
			if(rise > 0)
				overview += " | Conversions until Rise: [rise]"
			else if(ascend > 0)
				overview += " | Conversions until Ascension: [ascend]"
		to_chat(M, "[overview]</b></span>")

		if(cult[2]) // If there are any constructs, separate them out
			to_chat(M, "<span class='cultitalic'><b>Cultists:</b> [cult[1]]")
			to_chat(M, "<span class='cultitalic'><b>Constructs:</b> [cult[2]]")


/datum/cult_objectives/proc/current_sac_objective() //Return the current sacrifice objective datum, if any
	if(cult_status == NARSIE_DEMANDS_SACRIFICE && length(presummon_objs))
		var/datum/objective/sacrifice/current_obj = presummon_objs[length(presummon_objs)]
		return current_obj
	return FALSE

/datum/cult_objectives/proc/is_sac_target(datum/mind/mind)
	if(cult_status != NARSIE_DEMANDS_SACRIFICE || !length(presummon_objs))
		return FALSE
	var/datum/objective/sacrifice/current_obj = presummon_objs[length(presummon_objs)]
	if(current_obj.target == mind)
		return TRUE
	return FALSE

/datum/cult_objectives/proc/find_new_sacrifice_target(datum/mind/mind)
	var/datum/objective/sacrifice/current_obj = presummon_objs[length(presummon_objs)]
	if(current_obj.find_target())
		for(var/datum/mind/cult_mind in SSticker.mode.cult)
			if(cult_mind && cult_mind.current)
				to_chat(cult_mind.current, "<span class='danger'>[SSticker.cultdat.entity_name]</span> murmurs, <span class='cultlarge'>Our goal is beyond your reach. Sacrifice [current_obj.target] instead...</span>")
		return TRUE
	return FALSE

/datum/cult_objectives/proc/succesful_sacrifice()
	var/datum/objective/sacrifice/current_obj = presummon_objs[length(presummon_objs)]
	current_obj.sacced = TRUE
	sacrifices_done++
	if(sacrifices_done >= sacrifices_required)
		ready_to_summon()
	else
		var/datum/objective/sacrifice/obj_sac = new
		if(obj_sac.find_target())
			presummon_objs += obj_sac
			for(var/datum/mind/cult_mind in SSticker.mode.cult)
				if(cult_mind && cult_mind.current)
					to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have made progress, but there is more to do still before [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "The Dark One"] can be summoned!</span>")
					to_chat(cult_mind.current, "<span class='cult'>Current goal: [obj_sac.explanation_text]</span>")
		else
			ready_to_summon()

/datum/cult_objectives/proc/ready_to_summon()
	cult_status = NARSIE_NEEDS_SUMMONING
	for(var/datum/mind/cult_mind in SSticker.mode.cult)
		if(cult_mind && cult_mind.current)
			to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have succeeded in preparing the station for the ultimate ritual!</span>")
			to_chat(cult_mind.current, "<span class='cult'>Current goal: [obj_summon.explanation_text]</span>")

/datum/cult_objectives/proc/succesful_summon()
	cult_status = NARSIE_HAS_RISEN
	obj_summon.summoned = TRUE

/datum/cult_objectives/proc/narsie_death()
	cult_status = NARSIE_HAS_FALLEN
	obj_summon.killed = TRUE

//Objectives

/datum/objective/servecult //Given to cultists on conversion/roundstart
	explanation_text = "Assist your fellow cultists and Tear the Veil! (Use the Study Veil action to check your progress.)"
	completed = TRUE

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
		if(H.mind && !iscultist(H) && !is_convertable_to_cult(H.mind) && (H.stat != DEAD) && !H.mind.offstation_role)
			target_candidates += H.mind
	if(!length(target_candidates))	//There are no living unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(is_admin_level(H.z)) //We can't sacrifice people that are on the centcom z-level
				continue
			if(H.mind && !iscultist(H) && (H.stat != DEAD) && !H.mind.offstation_role) // Same checks, but add them even if they could be converted
				target_candidates += H.mind
	if(length(target_candidates))
		target = pick(target_candidates)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking an Offer rune with [target.p_their()] body or brain on it and three acolytes around it."
		return TRUE
	message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. Nar'Sie summoning unlocked!")
	return FALSE


/datum/objective/eldergod
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
	explanation_text = "Summon [SSticker.cultdat ? SSticker.cultdat.entity_name : "your god"] by invoking the rune 'Tear Veil' with 9 cultists, constructs, or summoned ghosts on it.\
	\nThe summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin."


/datum/objective/eldergod/check_completion()
	if(killed)
		return NARSIE_HAS_FALLEN // You failed so hard that even the code went backwards.
	return summoned || completed
