/datum/game_mode/cult/proc/blood_check()
	max_spilled_blood = (max(bloody_floors.len,max_spilled_blood))
	if((objectives[current_objective] == "bloodspill") && (bloody_floors.len >= spilltarget) && !spilled_blood)
		spilled_blood = 1
		additional_phase()

/datum/game_mode/cult/proc/check_numbers()
	if((objectives[current_objective] == "convert") && (cult.len >= convert_target) && !mass_convert)
		mass_convert = 1
		additional_phase()

/datum/game_mode/cult/proc/first_phase()


	var/new_objective = pick_objective()

	objectives += new_objective

	var/explanation

	switch(new_objective)
		if("convert")
			explanation = "We must increase our influence before we can summon [ticker.mode.cultdat.entity_name], Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
		if("bloodspill")
			spilltarget = 100 + rand(0,player_list.len * 3)
			explanation = "We must prepare this place for [ticker.mode.cultdat.entity_title1]'s coming. Spill blood and gibs over [spilltarget] floor tiles."
		if("sacrifice")
			explanation = "We need to sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role], for his blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune to perform the ritual."

	for(var/datum/mind/cult_mind in cult)
		to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

/datum/game_mode/cult/proc/bypass_phase()
	switch(objectives[current_objective])
		if("convert")
			mass_convert = 1
		if("bloodspill")
			spilled_blood = 1
		if("sacrifice")
			sacrificed += sacrifice_target
	additional_phase()

/datum/game_mode/cult/proc/additional_phase()
	current_objective++

	message_admins("Picking a new Cult objective.")
	var/new_objective = "eldergod"
	//the idea here is that if the cult performs well, the should get more objectives before they can summon Nar-Sie.
	if(cult.len >= 4)//if there are less than 4 remaining cultists, they get a free pass to the summon objective.
		if(current_objective <= prenarsie_objectives)
			var/list/unconvertables = get_unconvertables()
			if(unconvertables.len <= (cult.len * 2))//if cultists are getting radically outnumbered, they get a free pass to the summon objective.
				new_objective = pick_objective()
			else
				message_admins("There are over twice more unconvertables than there are cultists ([cult.len] cultists for [unconvertables.len]) unconvertables! Nar-Sie objective unlocked.")
				log_admin("There are over twice more unconvertables than there are cultists ([cult.len] cultists for [unconvertables.len]) unconvertables! Nar-Sie objective unlocked.")
		else
			message_admins("The Cult has already completed [prenarsie_objectives] objectives! Nar-Sie objective unlocked.")
			log_admin("The Cult has already completed [prenarsie_objectives] objectives! Nar-Sie objective unlocked.")
	else
		message_admins("There are less than 4 cultists! [ticker.mode.cultdat.entity_name] objective unlocked.")
		log_admin("There are less than 4 cultists! [ticker.mode.cultdat.entity_name] objective unlocked.")

	if(!sacrificed.len && (new_objective != "sacrifice"))
		sacrifice_target = null

	if(new_objective == "eldergod")
		second_phase()
		return
	else
		objectives += new_objective

		var/explanation

		switch(new_objective)
			if("convert")
				explanation = "We must increase our influence before we can summon [ticker.mode.cultdat.entity_name]. Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
			if("bloodspill")
				spilltarget = 100 + rand(0,player_list.len * 3)
				explanation = "We must prepare this place for [ticker.mode.cultdat.entity_title1]'s coming. Spread blood and gibs over [spilltarget] of the Station's floor tiles."
			if("sacrifice")
				explanation = "We need to sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role], for his blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune to perform the ritual."

		for(var/datum/mind/cult_mind in cult)
			to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have completed your task, but this place requires yet more preparation!</span>")
			to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
			cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

		message_admins("New Cult Objective: [new_objective]")
		log_admin("New Cult Objective: [new_objective]")

		blood_check()//in case there are already enough blood covered tiles when the objective is given.

/datum/game_mode/cult/proc/second_phase()
	narsie_condition_cleared = 1
	var/explanation

	if(prob(50))//split the chance of this
		objectives += "eldergod"
		explanation = "Summon [ticker.mode.cultdat.entity_name] on the Station via the use of the Tear Reality rune."
	else
		objectives += "slaughter"
		explanation = "Bring the Slaughter via the rune 'Tear Reality'."

	for(var/datum/mind/cult_mind in cult)
		to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have succeeded in preparing the station for the ultimate ritual!</span>")
		to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

/datum/game_mode/cult/proc/third_phase()
	current_objective++

	sleep(10)

	var/last_objective = pick_bonus_objective()

	objectives += last_objective

	var/explanation

	switch(last_objective)
		if("harvest")
			explanation = "[ticker.mode.cultdat.entity_title1] hungers for his first meal of this never-ending day. Offer him [harvest_target] humans in sacrifice."
		if("hijack")
			explanation = "[ticker.mode.cultdat.entity_name] wishes for his troops to start the assault on Centcom immediately. Hijack the escape shuttle and don't let a single non-cultist board it."
		if("massacre")
			explanation = "[ticker.mode.cultdat.entity_name] wants to watch you as you massacre the remaining humans on the station (until less than [massacre_target] humans are left alive)."

	for(var/datum/mind/cult_mind in cult)
		to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

	message_admins("Last Cult Objective: [last_objective]")
	log_admin("Last Cult Objective: [last_objective]")


/datum/game_mode/cult/proc/pick_objective()
	var/list/possible_objectives = list()

	if(!spilled_blood && (bloody_floors.len < spilltarget))
		possible_objectives |= "bloodspill"

	if(!sacrificed.len)
		var/list/possible_targets = list()
		for(var/mob/living/carbon/human/player in player_list)
			if(player.z == ZLEVEL_CENTCOMM) //We can't sacrifice people that are on the centcom z-level
				continue
			if(player.mind && !is_convertable_to_cult(player.mind) && (player.stat != DEAD))
				possible_targets += player.mind

		if(!possible_targets.len)
			//There are no living Unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
			for(var/mob/living/carbon/human/player in player_list)
				if(player.z == ZLEVEL_CENTCOMM) //We can't sacrifice people that are on the centcom z-level
					continue
				if(player.mind && !(player.mind in cult))
					possible_targets += player.mind

		if(possible_targets.len > 0)
			sacrifice_target = pick(possible_targets)
			possible_objectives |= "sacrifice"
		else
			message_admins("Didn't find a suitable sacrifice target...what the hell? Shout at a coder.")
			log_admin("Didn't find a suitable sacrifice target...what the hell? Shout at a coder.")

	if(!mass_convert)
		var/living_crew = 0
		var/living_cultists = 0
		for(var/mob/living/L in player_list)
			if(L.stat != DEAD)
				if(L.mind in cult)
					living_cultists++
				else
					if(istype(L, /mob/living/carbon))
						living_crew++

		var/total = living_crew + living_cultists

		if((living_cultists * 2) < total)
			if (total < 15)
				message_admins("There are [total] players, too little for the mass convert objective!")
				log_admin("There are [total] players, too little for the mass convert objective!")
			else if (total > 50)
				message_admins("There are [total] players, too many for the mass convert objective!")
				log_admin("There are [total] players, too many for the mass convert objective!")
			else
				possible_objectives |= "convert"
				convert_target = round(total / 2)

	if(!possible_objectives.len)//No more possible objectives, time to summon Nar-Sie
		message_admins("No suitable objectives left! Nar-Sie objective unlocked.")
		log_admin("No suitable objectives left! Nar-Sie objective unlocked.")
		var/lastbit
		if(prob(50))
			lastbit = "eldergod"
		else
			lastbit = "slaughter"
		return lastbit
	else
		return pick(possible_objectives)

/datum/game_mode/cult/proc/pick_bonus_objective()
	var/list/possible_objectives = list()

	var/living_crew = 0
	for(var/mob/living/carbon/C in player_list)
		if(C.stat != DEAD)
			if(!(C.mind in cult))
				var/turf/T = get_turf(C)
				if(T.z == ZLEVEL_STATION)	//we're only interested in the remaining humans on the station
					living_crew++

	if(living_crew > 5)
		possible_objectives |= "massacre"

	if(living_crew > 10)
		possible_objectives |= "harvest"

	possible_objectives |= "hijack"	//we need at least one objective guarranted to fire

	return pick(possible_objectives)

/datum/game_mode/cult/proc/bonus_check()
	switch(objectives[current_objective])
		if("harvest")
			if(harvested >= harvest_target)
				bonus = 1

		if("hijack")
			for(var/mob/living/L in player_list)
				if(L.stat != DEAD)
					if(!(L.mind in cult))
						var/area/A = get_area(L)
						if(is_type_in_list(A.loc, centcom_areas))
							escaped_shuttle++
			if(!escaped_shuttle)
				bonus = 1

		if("massacre")
			for(var/mob/living/carbon/C in player_list)
				if(C.stat != DEAD)
					if(!(C.mind in cult))
						var/turf/T = get_turf(C)
						if(T.z == ZLEVEL_STATION)	//we're only interested in the remaining humans on the station
							survivors++
			if(survivors < massacre_target)
				bonus = 1