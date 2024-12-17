/datum/controller/subsystem/ticker/station_explosion_cinematic(nuke_site, override)
	auto_toggle_ooc(TRUE) // Turn it on
	if(nuke_site == NUKE_SITE_ON_STATION)
		// Kill everyone on z-level 1 except for mobs in freezers and
		// malfunctioning AIs.
		for(var/mob/M in GLOB.mob_list)
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z) && !istype(M.loc, /obj/structure/closet/secure_closet/freezer) && !(issilicon(M) && override == "AI malfunction"))
					to_chat(M, span_danger("<B>The blast wave from the explosion tears you atom from atom!</B>"))
					M.ghostize()
					M.dust() // No mercy
					CHECK_TICK

	switch(nuke_site)
		// Now animate the cinematic
		if(NUKE_SITE_ON_STATION)
			// Station was destroyed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") // Nuke Ops successfully bombed the station
					play_cinematic(/datum/cinematic/nuke/ops_victory, world)
				if("AI malfunction") // Malf (screen,explosion,summary)
					play_cinematic(/datum/cinematic/malf, world)
				else //Station nuked (nuke,explosion,summary)
					play_cinematic(/datum/cinematic/nuke/self_destruct, world)
		if(NUKE_SITE_ON_STATION_ZLEVEL)
			// Nuke was nearby but (mostly) missed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") // Nuke wasn't on station when it blew up
					play_cinematic(/datum/cinematic/nuke/ops_miss, world)
				if("fake") // The round isn't over, we're just freaking people out for fun
					play_cinematic(/datum/cinematic/nuke/fake, world)
				else
					play_cinematic(/datum/cinematic/nuke/self_destruct_miss, world)
		if(NUKE_SITE_OFF_STATION_ZLEVEL, NUKE_SITE_INVALID)
			// Nuke was nowhere nearby
			// TODO: a really distant explosion animation
			play_cinematic(/datum/cinematic/nuke/far_explosion, world)

