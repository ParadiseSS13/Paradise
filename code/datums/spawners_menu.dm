/datum/spawners_menu
	var/mob/dead/observer/owner

/datum/spawners_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/spawners_menu/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui_state/state = GLOB.tgui_observer_state, datum/tgui/master_ui = null)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SpawnersMenu", "Spawners Menu", 700, 600, master_ui, state = state)
		ui.open()

/datum/spawners_menu/tgui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner in GLOB.mob_spawners)
		var/list/this = list()
		this["name"] = spawner
		this["desc"] = ""
		this["important_info"] = ""
		this["fluff"] = ""
		this["uids"] = list()
		for(var/spawner_obj in GLOB.mob_spawners[spawner])//each spawner can contain multiple actual spawners, we use only one desc/info
			this["uids"] += "\ref[spawner_obj]"
			if(!this["desc"])	//haven't set descriptions yet
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/MS = spawner_obj
					this["desc"] = MS.description
					this["important_info"] = MS.important_info
					this["fluff"] = MS.flavour_text
				else
					var/obj/O = spawner_obj
					this["desc"] = O.desc
		this["amount_left"] = LAZYLEN(GLOB.mob_spawners[spawner])
		data["spawners"] += list(this)
	return data

/datum/spawners_menu/tgui_act(action, params)
	if(..())
		return
	var/spawners = replacetext(params["ID"], ",", ";")
	var/list/possible_spawners = params2list(spawners)
	var/obj/effect/mob_spawn/MS = locate(pick(possible_spawners))
	if(!MS || !istype(MS))
		log_runtime(EXCEPTION("A ghost tried to interact with an invalid spawner, or the spawner didn't exist."))
		return
	switch(action)
		if("jump")
			owner.forceMove(get_turf(MS))
			. = TRUE
		if("spawn")
			MS.attack_ghost(owner)
			. = TRUE
