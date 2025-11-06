// All the TGUI interactions are in their own file to keep things simpler

/obj/item/pda/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/pda/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDA", name)
		ui.open()


/obj/item/pda/ui_data(mob/user)
	var/list/data = list()

	data["owner"] = owner
	data["ownjob"] = ownjob

	// update list of shortcuts, only if they changed
	if(!length(shortcut_cache))
		shortcut_cache = list()
		shortcut_cat_order = list()
		var/list/prog_list = programs.Copy()
		if(cartridge)
			prog_list |= cartridge.programs

		for(var/A in prog_list)
			var/datum/data/pda/P = A

			if(P.hidden)
				continue
			var/list/cat
			if(P.category in shortcut_cache)
				cat = shortcut_cache[P.category]
			else
				cat = list()
				shortcut_cache[P.category] = cat
				shortcut_cat_order += P.category
			cat |= list(list(name = P.name, icon = P.icon, notify_icon = P.notify_icon, uid = "[P.UID()]"))

		// force the order of a few core categories
		shortcut_cat_order = list("General") \
			+ sortList(shortcut_cat_order - list("General", "Scanners", "Utilities")) \
			+ list("Scanners", "Utilities")

	data["idInserted"] = (id ? TRUE : FALSE)
	data["idLink"] = (id ? "[id.registered_name], [id.assignment]" : "--------")

	data["cartridge_name"] = cartridge ? cartridge.name : ""
	data["stationTime"] = station_time_timestamp()

	data["app"] = list()
	data["app"] |= list(
		"name" = current_app.title,
		"icon" = current_app.icon,
		"template" = current_app.template,
		"has_back" = current_app.has_back)

	current_app.update_ui(user, data)

	return data

// Yes the stupid amount of args here is important, see L102
/obj/item/pda/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(ui.user)

	. = TRUE
	switch(action)
		if("Home") //Go home, largely replaces the old Return
			var/datum/data/pda/app/main_menu/A = find_program(/datum/data/pda/app/main_menu)
			if(A)
				start_program(A)
		if("StartProgram")
			if(params["program"])
				var/datum/data/pda/app/A = locateUID(params["program"])
				if(A)
					start_program(A)
		if("Eject")//Ejects the cart, only done from hub.
			// Do not eject the sillycone cart!
			if(silicon_pda)
				return
			if(!isnull(cartridge))
				var/obj/item/cartridge/C = cartridge
				if(ismob(loc))
					var/mob/T = loc
					T.put_in_hands(C)
				else
					C.forceMove(get_turf(src))
				if(scanmode in C.programs)
					scanmode = null
				if(current_app in C.programs)
					start_program(find_program(/datum/data/pda/app/main_menu))
				for(var/datum/data/pda/P in notifying_programs)
					if(P in C.programs)
						P.unnotify()
				cartridge = null
				update_shortcuts()
				playsound(src, 'sound/machines/terminal_eject.ogg', 50, TRUE)
		if("Authenticate") //Checks for ID
			id_check(ui.user, 1)
		if("Available_Ringtones")
			ttone = params["selected_ringtone"]
		if("Ringtone")
			if(!silent)
				playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			return set_ringtone(ui.user)
		else
			if(current_app)
				. = current_app.ui_act(action, params, ui, state) // It needs proxying through down here so apps actually have their interacts called

	if((honkamt > 0) && (prob(60))) //For clown virus.
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)
