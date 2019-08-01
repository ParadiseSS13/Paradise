/datum/antagonist/cult/proc/get_possible_sac_targets()
	var/list/possible_sac_targets = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !is_convertable_to_cult(player.mind) && (player.stat != DEAD))
			possible_sac_targets += player.mind
	if(!possible_sac_targets.len)
	//There are no living Unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(is_secure_level(player.z)) //We can't sacrifice people that are on the centcom z-level
				continue
			if(player.mind && !(player.mind in cult) && (player.stat != DEAD))//make DAMN sure they are not dead
				possible_sac_targets += player.mind
	return possible_sac_targets


/datum/objective/sacrifice
	var/sacced = FALSE


/datum/objective/sacrifice/New()
	..()
	team = src
	var/datum/antagonist/cult/C = new()
	target = pick(C.get_possible_sac_targets())
	update_explanation_text()

/datum/objective/sacrifice/check_completion()
	return sacced || completed

/datum/objective/sacrifice/update_explanation_text()
	if(!sacced)
		explanation_text = "We need to sacrifice [target.name], the [target.assigned_role], for [target.p_their()] blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune to perform the ritual."
	else
		explanation_text = "We have sacrificed [target.name], the [target.assigned_role] and the veil has been weakened here, proceed to the next objective."

/datum/objective/eldergod
	var/summoned = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	if(!summon_spots.len)
		while(summon_spots.len < SUMMON_POSSIBILITIES)
			var/area/summon = pick(return_sorted_areas() - summon_spots)
			if(summon && is_station_level(summon.z) && summon.valid_territory)
				summon_spots += summon
	update_explanation_text()

/datum/objective/eldergod/update_explanation_text()
	explanation_text = "Summon [SSticker.cultdat.entity_name] on the Station via the use of the Tear Reality rune. The veil is weak enough in [english_list(summon_spots)] for the ritual to begin."

/datum/objective/eldergod/check_completion()
	return summoned || completed

/datum/objective/demon
	var/summoned = FALSE
	var/list/summon_spots = list()

/datum/objective/demon/New()
	..()
	if(!summon_spots.len)
		while(summon_spots.len < SUMMON_POSSIBILITIES)
			var/area/summon = pick(return_sorted_areas() - summon_spots)
			if(summon && is_station_level(summon.z) && summon.valid_territory)
				summon_spots += summon
	update_explanation_text()


/datum/objective/demon/update_explanation_text()
	explanation_text = "Bring forth demons of Slaughter on the Station via the use of the Bring the Slaughter rune. The veil is weak enough in [english_list(summon_spots)] for the ritual to begin."

/datum/objective/demon/check_completion()
	return summoned || completed


/datum/objective/convert
	var/hasbookclub = FALSE
	var/convert_target

/datum/objective/convert/New()
	..()
	convert_target = rand(9,15)
	update_explanation_text()

/datum/objective/convert/update_explanation_text()
	if(!hasbookclub)
		explanation_text = "We must increase our influence before we can summon [SSticker.cultdat.entity_name], Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
	else
		explanation_text = "We have converted [convert_target] crew members. We may continue."
/datum/objective/convert/check_completion()
	return hasbookclub || completed

/datum/objective/bloodspill
	var/bloodystation = FALSE
	var/list/bloody_floors = list()
	var/spilltarget

/datum/objective/bloodspill/proc/blood_check()
	if((GLOB.bloody_floors.len >= spilltarget) && !bloodystation)
		bloodystation = TRUE
	update_explanation_text()

/datum/objective/bloodspill/New()
	..()
	spilltarget = 100 + rand(0, GLOB.player_list.len * 3)
	update_explanation_text()

/datum/objective/bloodspill/update_explanation_text()
	if(!bloodystation)
		explanation_text = "We must prepare this place for [SSticker.cultdat.entity_title1]'s coming. Spread blood and gibs over [spilltarget] of the Station's floor tiles. You have currently spread [GLOB.bloody_floors.len] tiles of blood"
	else
		explanation_text = "We have spread blood and gibs over [GLOB.bloody_floors.len] tiles."

/datum/objective/bloodspill/check_completion()
	return bloodystation || completed
	
/datum/objective/harvest

/datum/objective/harvest/update_explanation_text()
	explanation_text = "Begin the harvest! Convert unbelivers or feed the Slaughter then escape on the shuttle! Choose well who is worthy!"


/datum/objective/harvest/check_completion()
	return TRUE