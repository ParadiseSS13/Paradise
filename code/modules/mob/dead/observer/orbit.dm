GLOBAL_DATUM_INIT(orbit_menu, /datum/orbit_menu, new)

/datum/orbit_menu

/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Orbit", "Orbit")
		ui.open()

/datum/orbit_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/job_icons)
	)

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("orbit")
			var/ref = params["ref"]

			var/atom/movable/poi = (locate(ref) in GLOB.mob_list) || (locate(ref) in GLOB.poi_list)
			if(poi == null)
				. = TRUE
				return
			var/mob/dead/observer/ghost = ui.user
			ghost.manual_follow(poi)
			. = TRUE
		if("refresh")
			update_static_data(ui.user, ui)
			. = TRUE

/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/alive = list()
	var/list/highlights = list()
	var/list/response_teams = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ssd = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()
	var/list/tourist = list()
	var/length_of_ghosts = length(get_observers())

	var/list/pois = getpois(mobs_only = FALSE, skip_mindless = FALSE)
	for(var/name in pois)
		var/mob/M = pois[name]
		if(name == null)
			if(pois[name] && M.type)
				stack_trace("getpois returned something under a null name. Type: [M.type]")
			else
				stack_trace("getpois returned a null value")
			continue

		var/list/serialized = list()
		serialized["name"] = "[name]" // stringify it; If it's null or something - we'd like to know it and fix getpois()
		if(serialized["name"] != name)
			stack_trace("getpois returned something under a non-string name [name] - [pois[name]] - [M.type]")
			continue

		serialized["ref"] = "\ref[M]"
		var/list/orbiters = M.get_orbiters_recursive()
		if(length(orbiters) > 0)
			serialized["orbiters"] = length(orbiters)

		if(istype(M))
			if(isnewplayer(M))  // People in the lobby screen; only have their ckey as a name.
				continue
			if(isobserver(M) && M.client)
				ghosts += list(serialized)
			else if(M.mind == null)
				npcs += list(serialized)
			else if(M.stat == DEAD)
				dead += list(serialized)
			else if(!M.client) // this includes mobs which ghosted, but aren't `player_logged`, so that the Alive count is more accurate
				ssd += list(serialized)
			else
				if(length(orbiters) >= 0.2 * length_of_ghosts) // They're important if 20% of observers are watching them
					highlights += list(serialized)
				serialized["ssd"] = !M.client
				alive += list(serialized)

				var/datum/mind/mind = M.mind
				if(mind.special_role in list(SPECIAL_ROLE_ERT, SPECIAL_ROLE_DEATHSQUAD, SPECIAL_ROLE_SYNDICATE_DEATHSQUAD))
					response_teams += list(serialized)
				if(mind.special_role == SPECIAL_ROLE_TOURIST)
					tourist += list(serialized)

				if(user.antagHUD)
					/*
					If a mind is many antags at once, we'll display all of them, each
					under their own antag sub-section.
					This is arguably better, than picking one of the antag datums at random.

					list of antags that are datumised:
					- traitor
					- mindslaves/vampire thralls
					- vampire
					- changelings
					- revolutionaries/headrevs
					- event
					*/
					for(var/_A in mind.antag_datums)
						var/datum/antagonist/A = _A
						var/antag_serialized = serialized.Copy()
						antag_serialized["antag"] = A.name
						antagonists += list(antag_serialized)

					// Not-very-datumized antags follow
					// Associative list of antag name => whether this mind is this antag
					var/list/other_antags = list()
					if(SSticker && SSticker.mode)
						other_antags += list(
							"Blob" = (mind.special_role == SPECIAL_ROLE_BLOB),
							"Nuclear Operative" = (mind in SSticker.mode.syndicates)
						)

					for(var/antag_name in other_antags)
						var/is_antag = other_antags[antag_name]
						if(!is_antag)
							continue
						var/antag_serialized = serialized.Copy()
						antag_serialized["antag"] = antag_name
						antagonists += list(antag_serialized)

					// Antaghud? Let them see everyone's role
					if(isliving(M))
						var/mob/living/L = M
						if(L.mind?.has_normal_assigned_role())
							serialized["assigned_role"] = L.mind.assigned_role
							serialized["assigned_role_sprite"] = ckey(L.mind.get_assigned_role_asset())

				// Player terror spiders (and other hostile player-controlled event mobs) have their own category to help see how much there are.
				// Not in the above block because terrors can be known whether AHUD is on or not.
				if(isterrorspider(M))
					var/list/antag_serialized = serialized.Copy()
					antag_serialized["antag"] = "Terror Spider"
					antagonists += list(antag_serialized)
				else if(istype(M, /mob/living/simple_animal/revenant))
					var/list/antag_serialized = serialized.Copy()
					antag_serialized["antag"] = "Revenant"
					antagonists += list(antag_serialized)
				else if(isalien(M))
					var/list/antag_serialized = serialized.Copy()
					antag_serialized["antag"] = "Xenomorph"
					antagonists += list(antag_serialized)
				else if(isdemon(M))
					var/list/antag_serialized = serialized.Copy()
					antag_serialized["antag"] = "Demon"
					antagonists += list(antag_serialized)
				else if(ismorph(M))
					var/list/antag_serialized = serialized.Copy()
					antag_serialized["antag"] = "Morph"
					antagonists += list(antag_serialized)
		else
			if(length(orbiters) >= 0.2 * length_of_ghosts) // If a bunch of people are orbiting an object, like the nuke disk.
				highlights += list(serialized)
			misc += list(serialized)

	data["antagonists"] = antagonists
	data["highlights"] = highlights
	data["response_teams"] = response_teams
	data["tourist"] = tourist
	data["alive"] = alive
	data["ssd"] = ssd
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data
