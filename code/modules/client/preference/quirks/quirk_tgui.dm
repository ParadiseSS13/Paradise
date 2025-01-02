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
	var/list/data = list(list(
		"quirk_balance" = user?.client?.prefs.get_quirk_balance(),
		"selected_quirks" = user?.client?.prefs?.active_character?.quirks
	))
	return data

/datum/ui_module/quirk/ui_static_data(mob/user)
	var/list/data = list(
		"all_quirks" = GLOB.quirk_tgui_info
	)
	return data

/datum/ui_module/loadout/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	var/mob/user = usr
	var/datum/character_save/active_character = user.client.prefs.active_character
	var/quirk_name = params["name"]
	switch(action)
		if("add_quirk")
			log_debug("Add [quirk_name]")
		if("remove_quirk")
			log_debug("Remove [quirk_name]")



