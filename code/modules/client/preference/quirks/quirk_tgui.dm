GLOBAL_LIST_EMPTY(quirk_tgui_info)

/datum/ui_module/quirk
	name = "Quirks"

/datum/ui_module/quirk/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/quirk/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuirkMenu", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/quirk/ui_data(mob/user)
	var/datum/character_save/character = user?.client?.prefs.active_character
	var/list/data = list("quirk_balance" = character.rebuild_quirks())
	var/list/selected_quirks = list()
	for(var/quirk in character?.quirks)
		selected_quirks += quirk
	data["selected_quirks"] = selected_quirks
	return data

/datum/ui_module/quirk/ui_static_data(mob/user)
	var/list/data = list(
		"all_quirks" = GLOB.quirk_tgui_info
	)
	return data

/datum/ui_module/quirk/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	var/mob/user = usr
	var/quirk_path = text2path(params["path"])
	var/datum/quirk/quirk = new quirk_path
	user.client.prefs.active_character.rebuild_quirks()
	switch(action)
		if("add_quirk")
			user.add_quirk_to_save(quirk)
		if("remove_quirk")
			user.remove_quirk_from_save(quirk)



