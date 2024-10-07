/// Opens the station traits admin panel
/datum/admins/proc/station_traits_panel()
	set name = "Modify Station Traits"
	set category = "Event"

	var/static/datum/ui_module/station_traits_panel/station_traits_panel = new
	station_traits_panel.ui_interact(usr)

/datum/ui_module/station_traits_panel
	var/static/list/future_traits

/datum/ui_module/station_traits_panel/ui_data(mob/user)
	var/list/data = list()

	data["too_late_to_revert"] = too_late_to_revert()

	var/list/current_station_traits = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		current_station_traits += list(list(
			"name" = station_trait.name,
			"can_revert" = station_trait.can_revert,
			"ref" = station_trait.UID()
		))

	data["current_traits"] = current_station_traits
	data["future_station_traits"] = future_traits

	return data

/datum/ui_module/station_traits_panel/ui_static_data(mob/user)
	var/list/data = list()

	var/list/valid_station_traits = list()

	for(var/datum/station_trait/station_trait_path as anything in subtypesof(/datum/station_trait))
		valid_station_traits += list(list(
			"name" = initial(station_trait_path.name),
			"path" = station_trait_path
		))

	data["valid_station_traits"] = valid_station_traits

	return data

/datum/ui_module/station_traits_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("revert")
			var/ref = params["ref"]
			if(!ref)
				return TRUE

			var/datum/station_trait/station_trait = locateUID(ref)

			if(!istype(station_trait))
				return TRUE

			if(too_late_to_revert())
				to_chat(ui.user, "<span class='warning'>It's too late to revert station traits, the round has already started!</span>")
				return TRUE

			if(!station_trait.can_revert)
				stack_trace("[station_trait.type] can't be reverted, but was requested anyway.")
				return TRUE

			var/message = "[key_name(ui.user)] reverted the station trait [station_trait.name] ([station_trait.type])"
			log_admin(message)
			message_admins(message)

			station_trait.revert()
			return TRUE

		if("setup_future_traits")
			if(too_late_for_future_traits())
				to_chat(ui.user, "<span class='warning'>It's too late to add future station traits, the round is already over!</span>")
				return TRUE

			var/list/new_future_traits = list()
			var/list/station_trait_names = list()
			for(var/station_trait_text in params["station_traits"])
				var/datum/station_trait/station_trait_path = text2path(station_trait_text)
				if(!ispath(station_trait_path, /datum/station_trait) || station_trait_path == /datum/station_trait)
					log_admin("[key_name(ui.user)] tried to set an invalid future station trait: [station_trait_text]")
					to_chat(ui.user, "<span class='warning'>Invalid future station trait: [station_trait_text]</span>")
					return TRUE

				station_trait_names += initial(station_trait_path.name)

				new_future_traits += list(list(
					"name" = initial(station_trait_path.name),
					"path" = station_trait_path
				))

			var/message = "[key_name(ui.user)] has prepared the following station traits for next round: [station_trait_names.Join(", ") || "None"]"
			log_admin(message)
			message_admins(message)

			future_traits = new_future_traits
			fdel("data/next_traits.txt") //Delete it.
			var/F = file("data/next_traits.txt")
			F << json_encode(params["station_traits"])
			return TRUE

		if("clear_future_traits")
			if(!future_traits)
				to_chat(ui.user, "<span class='warning'>There are no future station traits.</span>")
				return TRUE

			var/message = "[key_name(ui.user)] has cleared the station traits for next round."
			log_admin(message)
			message_admins(message)

			fdel("data/next_traits.txt")
			future_traits = null

			return TRUE

/datum/ui_module/station_traits_panel/proc/too_late_for_future_traits()
	return SSticker.current_state >= GAME_STATE_FINISHED

/datum/ui_module/station_traits_panel/proc/too_late_to_revert()
	return SSticker.current_state >= GAME_STATE_PLAYING

/datum/ui_module/station_traits_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/station_traits_panel/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationTraitsPanel")
		ui.open()
