GLOBAL_DATUM_INIT(ghost_spawners_menu, /datum/spawners_menu, new)

/datum/spawners_menu

/datum/spawners_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/spawners_menu/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu", "Spawners Menu")
		ui.open()

/datum/spawners_menu/ui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner in GLOB.mob_spawners)
		var/is_perm_spawner = FALSE
		var/list/this = list()
		this["name"] = spawner
		this["desc"] = ""
		this["important_info"] = ""
		this["fluff"] = ""
		this["uids"] = list()
		for(var/obj/effect/mob_spawn/spawner_obj as anything in GLOB.mob_spawners[spawner]) // each spawner can contain multiple actual spawners, we use only one desc/info
			this["uids"] += "[spawner_obj.UID()]"
			if(!this["desc"]) // haven't set descriptions yet
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/MS = spawner_obj
					this["desc"] = MS.description
					this["important_info"] = MS.important_info
					this["fluff"] = MS.flavour_text
					if(MS.permanent)
						is_perm_spawner = TRUE
				else
					var/obj/O = spawner_obj
					this["desc"] = O.desc
		this["amount_left"] = is_perm_spawner ? "Infinite uses" : LAZYLEN(GLOB.mob_spawners[spawner])
		data["spawners"] += list(this)
	return data

/datum/spawners_menu/ui_act(action, params)
	if(..())
		return
	var/list/possible_spawners = params["ID"]
	if(!length(possible_spawners))
		return
	var/obj/effect/mob_spawn/MS = locate(pick(possible_spawners))
	if(!MS || !istype(MS))
		CRASH("A ghost tried to interact with an invalid spawner, or the spawner didn't exist.")
	switch(action)
		if("jump")
			var/mob/dead/observer/ghost = usr
			ghost.abstract_move(get_turf(MS))
			. = TRUE
		if("spawn")
			if(MS.attack_ghost(usr))
				SSblackbox.record_feedback("tally", "ghost_spawns", 1, "[MS.assignedrole]")
			. = TRUE
