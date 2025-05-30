/datum/ui_module/debug_types
	name = "Debug types" 
	var/target_path
	var/list/items


/datum/ui_module/debug_types/New(datum/_host, target_path, list/data)
	..()
	src.target_path = target_path
	src.items = data

/datum/ui_module/debug_types/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/debug_types/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DebugTypes", name)
		ui.autoupdate = FALSE
		ui.open()

// /datum/ui_module/debug_types/ui_data(mob/user)
// 	return data

/datum/ui_module/debug_types/ui_static_data(mob/user)
	var/list/data = list()
	data["target_path"] = src.target_path
	data["items"] = src.items
	return data

/datum/ui_module/debug_types/ui_act(action, list/params)
	if(..())
		return TRUE
	. = TRUE
	switch(action)
		if("edit")
			var/datum/D = locate(params["edit"])
			if(!D)
				CRASH("Tried to edit a null target")
			var/client/C = client_from_var(usr)
			C.debug_variables(D)
		if("jump")
			var/datum/D = locate(params["jump"])
			if(!D)
				CRASH("Tried to jump to a null target")
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.ManualFollow(D)
