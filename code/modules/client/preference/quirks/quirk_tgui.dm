GLOBAL_LIST_EMPTY(quirk_tgui_info)

/datum/ui_module/quirk
	name = "Quirks"

/datum/ui_module/quirk/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/quirk/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "quirk", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/quirk/ui_data(mob/user)
	var/list/data = list()
	data["quirk_slots"] = user?.client?.prefs.build_loadout()
	data["selected_quirks"] = user?.client?.prefs?.active_character?.loadout_gear
	return data

/datum/ui_module/loadout/ui_static_data(mob/user)
	var/list/data = list()
	data["quirks"] = GLOB.quirk_tgui_info
	return data
