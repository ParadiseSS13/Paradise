/datum/controller/subsystem/mapping/proc/handleDaBaby(zlevelyes)
	log_startup_progress("Iniciando la catastrofe de LeBaby...")
	var/dababy_setup_timer = start_watch()
	seedRuinsDaBabyStyle(list(zlevelyes), 50, /area/dababyruin, GLOB.dababy_ruins_templates) // budget de 50
	// BIG BOY TIME
	var/chance = rand(1,3)
	var/nombre
	switch(chance)
		if(1)
			nombre = "Puente Magico del Abismo"
		if(2)
			nombre = "El Valhalla de las Chaquetas"
		if(3)
			nombre = "Laberinto del Abismo"
	var/datum/map_template/ruin/dababyprincipal/R = GLOB.map_templates[nombre]
	R.load(locate(182,116,zlevelyes), TRUE)
	log_startup_progress("Ruina principal de LeBaby cargada.")

	log_startup_progress("LeBaby terminado en [stop_watch(dababy_setup_timer)]s.")

/datum/controller/subsystem/mapping/proc/seedRuinsDaBabyStyle(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins)
	var/list/ruins = GLOB.dababy_ruins_templates.Copy()

	var/list/forced_ruins = list()		//These go first on the z level associated (same random one by default)
	var/list/ruins_availible = list()	//we can try these in the current pass
	var/forced_z	//If set we won't pick z level and use this one instead.

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.cost > budget) //Why would you do that
			continue
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_availible[R] = R.placement_weight

	while(ruins_availible.len || forced_ruins.len) // No termines hasta que este llenito el mapa.
		var/datum/map_template/ruin/dababy/current_pick
		var/forced = FALSE
		if(forced_ruins.len) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pickweight(ruins_availible)

		var/placement_tries = PLACEMENT_TRIES
		var/failed_to_place = TRUE
		var/z_placed = 0
		while(placement_tries > 0)
			placement_tries--
			z_placed = pick(z_levels)
			if(!current_pick.try_to_place(forced_z ? forced_z : z_placed,whitelist))
				continue
			else
				failed_to_place = FALSE
				break

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick
			forced = FALSE

		if(failed_to_place)
			for(var/datum/map_template/ruin/R in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R
		else
			budget -= current_pick.cost
			if(current_pick.allow_duplicates)
				if(current_pick.max_duplictates == 0)
					for(var/datum/map_template/ruin/R in ruins_availible)
						if(R.id == current_pick.id)
							ruins_availible -= R
				else
					current_pick.max_duplictates--
			else
				for(var/datum/map_template/ruin/R in ruins_availible)
					if(R.id == current_pick.id)
						ruins_availible -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_availible)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_availible -= possible_exclusion
		forced_z = 0

		//Update the availible list
		for(var/datum/map_template/ruin/R in ruins_availible)
			if(R.cost > budget)
				ruins_availible -= R

	log_world("LeBaby terminado con un presupuesto de [budget] restante.")

/proc/handleDaBabyRuinsPreload()
	if(SSmapping.map_datum.fluff_name != "NSS LeBaby") return

	for(var/item in subtypesof(/datum/map_template/ruin/dababy))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		GLOB.map_templates[R.name] = R
		GLOB.ruins_templates[R.name] = R
		GLOB.dababy_ruins_templates[R.name] = R

	for(var/item in subtypesof(/datum/map_template/ruin/dababyprincipal))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		GLOB.map_templates[R.name] = R
		GLOB.ruins_templates[R.name] = R

	log_world("Ruinas de DaBaby precargadas.")
