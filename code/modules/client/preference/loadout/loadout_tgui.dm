/datum/ui_module/loadout
	name = "Loadout"

/datum/ui_module/loadout/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/loadout/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Loadout", name)
		ui.autoupdate = FALSE
		ui.open()

/datum/ui_module/loadout/ui_data(mob/user)
	var/list/data = list()
	data["gear_slots"] = user.client.prefs.build_loadout()
	data["selected_gears"] = user.client.prefs.active_character.loadout_gear
	return data

/datum/ui_module/loadout/ui_static_data(mob/user)
	var/list/data = list()
	data["gears"] = GLOB.gear_datums
	data["max_gear_slots"] = user.client.prefs.max_gear_slots
	data["user_tier"] = user.client.donator_level
	return data

/datum/ui_module/loadout/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	var/mob/user = usr
	switch(action)
		if("toggle_gear")
			var/datum/gear/TG = text2path(params["gear"])
			if(TG && (TG.type in user.client.prefs.active_character.loadout_gear))
				user.client.prefs.active_character.loadout_gear -= TG.type
				return TRUE

			if(TG.donator_tier && user.client.donator_level < TG.donator_tier)
				to_chat(user, "<span class='warning'>That gear is only available at a higher donation tier than you are on.</span>")
				return FALSE

			user.client.prefs.build_loadout(TG)
			return TRUE

		if("clear_loadout")
			user.client.prefs.active_character.loadout_gear.Cut()
			return TRUE
