GLOBAL_LIST_EMPTY(gear_tgui_info)

/datum/ui_module/loadout
	name = "Loadout"

/datum/ui_module/loadout/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/loadout/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Loadout", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/loadout/ui_data(mob/user)
	var/list/data = list()
	data["gear_slots"] = user?.client?.prefs.build_loadout()
	data["selected_gears"] = user?.client?.prefs?.active_character?.loadout_gear
	return data

/datum/ui_module/loadout/ui_static_data(mob/user)
	var/list/data = list()
	data["gears"] = GLOB.gear_tgui_info
	data["max_gear_slots"] = user?.client?.prefs?.max_gear_slots
	data["user_tier"] = user?.client?.donator_level
	return data

/datum/ui_module/loadout/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	var/mob/user = usr
	var/datum/character_save/active_character = user.client.prefs.active_character
	switch(action)
		if("toggle_gear")
			var/datum/gear/gear = GLOB.gear_datums[text2path(params["gear"])]
			if(gear && ("[gear]" in active_character.loadout_gear))
				active_character.loadout_gear -= "[gear]"
				return TRUE

			if(gear.donator_tier && user.client.donator_level < gear.donator_tier)
				to_chat(user, "<span class='warning'>That gear is only available at a higher donation tier than you are on.</span>")
				return FALSE

			user.client.prefs.build_loadout(gear)
			return TRUE

		if("set_tweak")
			if(!(params["gear"] in active_character.loadout_gear))
				return FALSE

			var/datum/gear/gear = GLOB.gear_datums[text2path(params["gear"])]
			var/datum/gear_tweak/tweak = locate(text2path(params["tweak"])) in gear.gear_tweaks
			active_character.set_tweak_metadata(gear, tweak, tweak.get_metadata(user, active_character.get_tweak_metadata(gear, tweak)))
			return TRUE

		if("clear_loadout")
			active_character.loadout_gear.Cut()
			return TRUE
