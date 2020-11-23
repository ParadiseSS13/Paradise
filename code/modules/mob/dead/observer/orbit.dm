/datum/orbit_menu
	var/mob/dead/observer/owner

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_observer_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Orbit", "Orbit", 700, 500, master_ui, state)
		ui.open()

/datum/orbit_menu/tgui_act(action, list/params, datum/tgui/ui)
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
			owner.ManualFollow(poi)
			. = TRUE
		if("refresh")
			update_tgui_static_data(owner, ui)
			. = TRUE

/datum/orbit_menu/tgui_data(mob/user)
	var/list/data = list()
	return data

/datum/orbit_menu/tgui_static_data(mob/user)
	var/list/data = list()

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	var/list/pois = getpois(mobs_only = FALSE, skip_mindless = FALSE)
	for(var/name in pois)
		var/list/serialized = list()
		serialized["name"] = "[name]" // stringify it; If it's null or something - we'd like to know it and fix getpois()
		if(name == null || serialized["name"] != name)
			stack_trace("getpois returned something under a non-string name [name] - [pois[name]]")

		var/poi = pois[name]

		serialized["ref"] = "\ref[poi]"

		var/mob/M = poi
		if(istype(M))
			if(isobserver(M))
				ghosts += list(serialized)
			else if(M.stat == DEAD)
				dead += list(serialized)
			else if(M.mind == null)
				npcs += list(serialized)
			else
				alive += list(serialized)

				var/datum/mind/mind = M.mind
				if(user.antagHUD)
					// If a mind is many antags at once, we'll display all of them, each
					// under their own antag sub-section.
					// This is arguably better, than picking one of the antag datums at random.

					// Traitors - the only antags in `.antag_datums` at the time of writing.
					for(var/_A in mind.antag_datums)
						var/datum/antagonist/A = _A
						var/antag_serialized = serialized.Copy()
						antag_serialized["antag"] = A.name
						antagonists += list(antag_serialized)

					// Not-very-datumized antags follow
					// Associative list of antag name => whether this mind is this antag
					var/other_antags = list(
						"Changeling" = (mind.changeling != null),
						"Vampire" = (mind.vampire != null),
					)
					if(SSticker && SSticker.mode)
						other_antags += list(
							"Cultist" = (mind in SSticker.mode.cult),
							"Wizard" = (mind in SSticker.mode.wizards),
							"Wizard's Apprentice" = (mind in SSticker.mode.apprentices),
							"Nuclear Operative" = (mind in SSticker.mode.syndicates),
							"Shadowling" = (mind in SSticker.mode.shadows),
							"Shadowling Thrall" = (mind in SSticker.mode.shadowling_thralls),
							"Abductor" = (mind in SSticker.mode.abductors),
							"Revolutionary" = (mind in SSticker.mode.revolutionaries),
						)

					for(var/antag_name in other_antags)
						var/is_antag = other_antags[antag_name]
						if(!is_antag)
							continue
						var/antag_serialized = serialized.Copy()
						antag_serialized["antag"] = antag_name
						antagonists += list(antag_serialized)

		else
			misc += list(serialized)

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data
