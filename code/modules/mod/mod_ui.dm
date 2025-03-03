/obj/item/mod/control/ui_state(mob/user)
	return GLOB.default_state

/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit", name)
		ui.open()

/obj/item/mod/control/ui_data(mob/user)
	var/data = list()
	data["interface_break"] = interface_break
	data["malfunctioning"] = malfunctioning
	data["open"] = open
	data["active"] = active
	data["link_id"] = mod_link.id
	data["link_freq"] = mod_link.frequency
	data["link_call"] = mod_link.get_other()?.id
	data["locked"] = locked
	data["complexity"] = complexity
	data["selected_module"] = selected_module?.name
	data["wearer_name"] = wearer ? (wearer.get_authentification_name("Unknown") || "Unknown") : "No Occupant"
	data["wearer_job"] = wearer ? wearer.get_assignment("Unknown", "Unknown", FALSE) : "No Job"
	data["core"] = core?.name
	data["charge"] = get_charge_percent()
	data["modules"] = list()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_data = list(
			"module_name" = module.name,
			"description" = module.desc,
			"module_type" = module.module_type,
			"module_active" = module.active,
			"pinned" = module.pinned_to[user.UID()], //might just want user here
			"idle_power" = module.idle_power_cost,
			"active_power" = module.active_power_cost,
			"use_power" = module.use_power_cost,
			"module_complexity" = module.complexity,
			"cooldown_time" = module.cooldown_time,
			"cooldown" = round(COOLDOWN_TIMELEFT(module, cooldown_timer), 1 SECONDS),
			"ref" = module.module_UID, //might just want user here
			"id" = module.tgui_id,
			"configuration_data" = module.get_configuration()
		)
		module_data += module.add_ui_data()
		data["modules"] += list(module_data)
	return data

/obj/item/mod/control/ui_static_data(mob/user)
	var/data = list()
	data["ui_theme"] = ui_theme
	data["control"] = name
	data["complexity_max"] = complexity_max
	data["helmet"] = helmet?.name
	data["chestplate"] = chestplate?.name
	data["gauntlets"] = gauntlets?.name
	data["boots"] = boots?.name
	return data

/obj/item/mod/control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(locked && !allowed(usr))
		to_chat(usr, "<span class='warning'>Insufficient access!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(malfunctioning && prob(75))
		to_chat(usr, "<span class='warning'>ERROR!</span>")
		return
	switch(action)
		if("call")
			if(!mod_link.link_call)
				call_link(ui.user, mod_link)
			else
				mod_link.end_call()
		if("lock")
			locked = !locked
			to_chat(usr, "<span class='notice'>ID [locked ? "locked" : "unlocked"].</span>")
		if("activate")
			toggle_activate(usr)
		if("select")
			var/obj/item/mod/module/module = locateUID(params["ref"])
			if(!module)
				return
			module.on_select()
		if("configure")
			var/obj/item/mod/module/module = locateUID(params["ref"])
			if(!module)
				return
			module.configure_edit(params["key"], params["value"])
		if("pin")
			var/obj/item/mod/module/module = locateUID(params["ref"])
			if(!module)
				return
			module.pin(usr)
	return TRUE
