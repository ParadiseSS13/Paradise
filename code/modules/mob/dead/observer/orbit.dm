/datum/orbit_menu
	var/mob/dead/observer/owner
	var/auto_observe = FALSE

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_observer_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "Orbit", "title goes here", 800, 600, master_ui, state)
		ui.open()

/datum/orbit_menu/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if ("orbit")
			var/ref = params["ref"]

			var/atom/movable/poi = (locate(ref) in GLOB.mob_list) || (locate(ref) in GLOB.poi_list)
			if (poi == null)
				. = TRUE
				return
			owner.ManualFollow(poi)
			. = TRUE
		if ("refresh")
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

	var/list/pois = getpois(mobs_only=TRUE)
	for (var/name in pois)
		var/list/serialized = list()
		serialized["name"] = name

		var/poi = pois[name]

		serialized["ref"] = "\ref[poi]"

		var/mob/M = poi
		if (istype(M))
			if (isobserver(M))
				ghosts += list(serialized)
			else if (M.stat == DEAD)
				dead += list(serialized)
			else if (M.mind == null)
				npcs += list(serialized)
			else
				var/datum/mind/mind = M.mind
				var/was_antagonist = FALSE

				if(user.antagHUD)
					// I'm lazy and only showing datumized antags (i.e. traitors).
					for (var/_A in mind.antag_datums)
						var/datum/antagonist/A = _A
						was_antagonist = TRUE
						serialized["antag"] = A.name
						antagonists += list(serialized)
						break

				if (!was_antagonist)
					alive += list(serialized)
		else
			misc += list(serialized)

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data
