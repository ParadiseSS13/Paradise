/datum/cult_objectives //Replace with team antag datum objectives from tg once ported
	var/status = NARSIE_IS_ASLEEP
	var/datum/objective/sacrifice/obj_sac = new
	var/datum/objective/eldergod/obj_summon = new

/datum/cult_objectives/proc/setup()
	if(status != NARSIE_IS_ASLEEP)
		return FALSE
	status = NARSIE_DEMANDS_SACRIFICE
	if(!obj_sac.find_target())
		succesful_sacrifice()

/datum/cult_objectives/proc/study(mob/living/M) //Called by cultists/cult constructs checking their objectives
	if(!M)
		return FALSE
	switch(status)
		if(NARSIE_IS_ASLEEP)
			to_chat(M, "<span class='cult'>[SSticker.cultdat ? SSticker.cultdat.entity_name : "The Dark One"] is asleep. (This should never happen. Yell at a coder.)</span>")
		if(NARSIE_DEMANDS_SACRIFICE)
			to_chat(M, "<span class='cult'>The Veil needs to be weakened before we are able to summon [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "The Dark One"]</span>")
			to_chat(M, "<span class='cult'>Current goal : [obj_sac.explanation_text]</span>")
		if(NARSIE_NEEDS_SUMMONING)
			to_chat(M, "<span class='cult'>The Veil is weak! We can summon [SSticker.cultdat ? SSticker.cultdat.entity_title3 : "The Dark One"]!</span>")
			to_chat(M, "<span class='cult'>Current goal : [obj_summon.explanation_text]</span>")
		if(NARSIE_HAS_RISEN)
			to_chat(M, "<span class='cultlarge'>\"I am here.\"</span>")
			to_chat(M, "<span class='cult'>Current goal : </span><span class='cultlarge'>\"Feed me.\"</span>")
		if(NARSIE_HAS_FALLEN)
			to_chat(M, "<span class='cultlarge'>[SSticker.cultdat ? SSticker.cultdat.entity_name : "The Dark One"] has been banished!</span>")
			to_chat(M, "<span class='cult'>Current goal : Slaughter the unbelievers!</span>")

/datum/cult_objectives/proc/succesful_sacrifice()
	status = NARSIE_NEEDS_SUMMONING
	obj_sac.sacced = TRUE
	for(var/datum/mind/cult_mind in SSticker.mode.cult)
		if(cult_mind && cult_mind.current)
			to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have succeeded in preparing the station for the ultimate ritual!</span>")
			to_chat(cult_mind.current, "<span class='cult'>Current goal : [obj_summon.explanation_text]</span>")

/datum/cult_objectives/proc/succesful_summon()
	status = NARSIE_HAS_RISEN
	obj_summon.summoned = TRUE

/datum/cult_objectives/proc/narsie_death()
	status = NARSIE_HAS_FALLEN
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
	for(var/mob/M in GLOB.player_list)
		var/mob/living/carbon/human/H = M
		if(is_admin_level(H.z)) //We can't sacrifice people that are on the centcom z-level
			continue
		if(H.mind && !is_convertable_to_cult(H.mind) && (H.stat != DEAD) && (H.mind.offstation_role != TRUE))
			target_candidates += H.mind
	if(!target_candidates.len) 	//There are no living unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
		for(var/mob/M in GLOB.player_list)
			var/mob/living/carbon/human/H = M
			if(is_admin_level(H.z)) //We can't sacrifice people that are on the centcom z-level
				continue
			if(H.mind && !iscultist(H) && (H.stat != DEAD) && (H.mind.offstation_role != TRUE))
				target_candidates += H.mind
	if(target_candidates.len)
		target = pick(target_candidates)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking an Offer rune with [target.p_them()] on it and three acolytes around it."
		return TRUE
	message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. Nar'Sie summoning unlocked!")
	return FALSE


/datum/objective/eldergod
	var/summoned = FALSE
	var/killed = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(return_sorted_areas() - summon_spots)
		var/valid_spot = FALSE
		if(summon && is_station_level(summon.z) && summon.valid_territory) //check if there's a turf that you can walk on, if not it's not valid
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
	explanation_text = "Summon [SSticker.cultdat ? SSticker.cultdat.entity_name : "your god"] by invoking the rune 'Tear Veil'. <b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/eldergod/check_completion()
	if(killed)
		return NARSIE_HAS_FALLEN // You failed so hard that even the code went backwards.
	return summoned || completed