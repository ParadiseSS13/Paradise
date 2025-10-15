RESTRICT_TYPE(/datum/ui_module/ert_loadout_manager)

/datum/ui_module/ert_loadout_manager
	name = "ERT Loadout Manager"

	/// The loadout currently selected in the UI.
	var/datum/ert_loadout/selected_loadout
	/// Kept DM-side so that back-and-forth changes return the user to the
	/// tab they expect to see the change in.
	var/ui_tab_index = 0

/datum/ui_module/ert_loadout_manager/proc/set_loadout_by_name(loadout_name)
	for(var/datum/ert_loadout/loadout in GLOB.ert_loadouts)
		if(loadout.loadout_name == loadout_name)
			selected_loadout = loadout
			return
	for(var/datum/ert_loadout/loadout in GLOB.ert_custom_loadouts)
		if(loadout.loadout_name == loadout_name)
			selected_loadout = loadout
			return

/datum/ui_module/ert_loadout_manager/proc/get_all_loadout_names()
	var/list/names = list()
	for(var/datum/ert_loadout/loadout in GLOB.ert_loadouts)
		names += loadout.loadout_name
	for(var/datum/ert_loadout/loadout in GLOB.ert_custom_loadouts)
		names += loadout.loadout_name

	return names

/datum/ui_module/ert_loadout_manager/New(datum/_host)
	. = ..()
	var/datum/ert_loadout/first_loadout = GLOB.ert_loadouts[1]
	set_loadout_by_name(first_loadout.loadout_name)

/datum/ui_module/ert_loadout_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/ert_loadout_manager/ui_data(mob/user)
	. = list()

	.["tabIndex"] = ui_tab_index
	.["modal"] = ui_modal_data(src)
	.["selected_loadout"] = selected_loadout.ui_data(user)

// we keep most of this stuff in static data because there's a lot of it
// and we don't want to keep sending it over the wire at the default UI
// refresh rate
/datum/ui_module/ert_loadout_manager/ui_static_data(mob/user)
	. = list()
	.["loadouts"] = list()
	.["loadout_roles"] = GLOB.ert_roles

	for(var/datum/ert_loadout/loadout in GLOB.ert_loadouts)
		.["loadouts"] += list(loadout.ui_data(user))

	for(var/datum/ert_loadout/loadout in GLOB.ert_custom_loadouts)
		.["loadouts"] += list(loadout.ui_data(user))

	.["allowed_items"] = list()

	.["allowed_items"][selected_loadout.primary_firearm.type] = get_loadout_allowed_items(selected_loadout.primary_firearm)
	.["allowed_items"][selected_loadout.secondary_firearm.type] = get_loadout_allowed_items(selected_loadout.secondary_firearm)
	.["allowed_items"][selected_loadout.cybernetic_implants.type] = get_loadout_allowed_items(selected_loadout.cybernetic_implants)
	.["allowed_items"][selected_loadout.bio_chips.type] = get_loadout_allowed_items(selected_loadout.bio_chips)
	.["allowed_items"][selected_loadout.backpack_contents.type] = get_loadout_allowed_items(selected_loadout.backpack_contents)
	.["allowed_items"][selected_loadout.head.type] = get_loadout_allowed_items(selected_loadout.head)
	.["allowed_items"][selected_loadout.shoes.type] = get_loadout_allowed_items(selected_loadout.shoes)
	.["allowed_items"][selected_loadout.belt.type] = get_loadout_allowed_items(selected_loadout.belt)
	.["allowed_items"][selected_loadout.back.type] = get_loadout_allowed_items(selected_loadout.back)
	.["allowed_items"][selected_loadout.glasses.type] = get_loadout_allowed_items(selected_loadout.glasses)
	.["allowed_items"][selected_loadout.mask.type] = get_loadout_allowed_items(selected_loadout.mask)
	.["allowed_items"][selected_loadout.l_pocket.type] = get_loadout_allowed_items(selected_loadout.l_pocket)
	.["allowed_items"][selected_loadout.r_pocket.type] = get_loadout_allowed_items(selected_loadout.r_pocket)
	.["allowed_items"][selected_loadout.neck.type] = get_loadout_allowed_items(selected_loadout.neck)

/datum/ui_module/ert_loadout_manager/proc/get_loadout_allowed_items(datum/ert_loadout_slot/slot)
	. = list()

	var/list/allowed_items = slot.allowed_items()
	var/list/sorted = sortTim(allowed_items, GLOBAL_PROC_REF(cmp_objtype_name))
	for(var/item in sorted)
		. += list(list(
			"item_name" = get_loadout_item_name(item),
			"item_type" = item,
		))

/datum/ui_module/ert_loadout_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ERTLoadoutManager", name)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/ert_loadout_manager/proc/ui_act_modal(action, list/params)
	. = TRUE

	var/id = params["id"]
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]

	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("open_add_item_modal")
					ui_modal_message(src, id, "", arguments = arguments)
				else
					return FALSE
		else
			return FALSE

/datum/ui_module/ert_loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(ui_act_modal(action, params))
		return

	. = TRUE

	switch(action)
		if("set_tab")
			ui_tab_index = text2num(params["tab"])
			return TRUE
		if("set_selected_loadout")
			set_loadout_by_name(params["loadout_name"])
			return TRUE
		if("set_loadout_role")
			selected_loadout.role = params["loadout_role"]
		if("set_single_slot", "add_item_into_slot")
			var/item_path = text2path(params["item_type"])
			if(item_path)
				return add_item_into_slot(ui, params["slot_uid"], item_path)
			else
				to_chat(ui.user, SPAN_WARNING("Could not find path [params["path_text"]]."))
				return FALSE
		if("increment_backpack_item")
			var/item_path = text2path(params["item_type"])
			if(item_path)
				selected_loadout.backpack_contents.chosen_item_quantities[item_path]++
				return TRUE
		if("decrement_backpack_item")
			var/item_path = text2path(params["item_type"])
			if(item_path)
				selected_loadout.backpack_contents.chosen_item_quantities[item_path]--
				if(selected_loadout.backpack_contents.chosen_item_quantities[item_path] <= 0)
					selected_loadout.backpack_contents.chosen_item_quantities.Remove(item_path)
				return TRUE
		if("toggle_biochip")
			selected_loadout.toggle_biochip(text2path(params["biochip_type"]))
			return TRUE
		if("toggle_implant")
			selected_loadout.toggle_implant(text2path(params["implant_type"]))
			return TRUE

		// INVOKE_ASYNC because we open up tgui_inputs in these steps
		if("copy_to_new_loadout")
			INVOKE_ASYNC(src, PROC_REF(copy_to_new_loadout), ui)
			return TRUE
		if("export_loadout")
			INVOKE_ASYNC(src, PROC_REF(export_loadout), ui)
			return TRUE
		if("import_loadout")
			INVOKE_ASYNC(src, PROC_REF(import_loadout), ui)
			return TRUE

/datum/ui_module/ert_loadout_manager/proc/add_item_into_slot(datum/tgui/ui, slot_uid, item_path)
	var/datum/ert_loadout_slot/slot = locateUID(slot_uid)
	if(istype(slot))
		slot.set_item(item_path)
	else
		to_chat(ui.user, SPAN_WARNING("Could not find slot to place item in: [slot_uid]"))
		return FALSE

	update_static_data(ui.user, ui)
	ui_modal_clear(src)
	return TRUE

/datum/ui_module/ert_loadout_manager/proc/export_loadout(datum/tgui/ui)
	var/json_data = json_encode(selected_loadout.serialize())
	tgui_input_text(ui.user, "Your loadout is in JSON format below. Copy and paste somewhere safe.", "Export Loadout to JSON", json_data, max_length = 4096, multiline = TRUE)

/datum/ui_module/ert_loadout_manager/proc/import_loadout(datum/tgui/ui)
	var/import_data = tgui_input_text(ui.user, "Paste your loadout JSON here.", "Import Loadout", "", max_length = 4096)
	if(import_data)
		try
			var/json = json_decode(html_decode(import_data))

			var/all_names = get_all_loadout_names()
			var/valid_name = FALSE
			var/new_name = json["loadout_name"]
			while(!valid_name)
				// do a bunch of goofy shit to make sure we don't import a
				// layout with a name that already exists. start iterating
				// through "name (1)" "name (2)" etc. will almost never be
				// a problem irl but still necessary
				// hate hate hate
				if(new_name in all_names)
					var/next_idx = 1
					do
						new_name = "[json["loadout_name"]] ([next_idx])"
						if(new_name in all_names)
							new_name = null
							next_idx++
					while(!new_name)
					new_name = tgui_input_text(ui.user, "A loadout with the name already exists. Choose a new name to finish importing.", "Import Loadout", "[new_name]")
				else
					valid_name = TRUE

			var/datum/ert_loadout/imported_loadout = new(new_name)
			imported_loadout.deserialize(json)
			GLOB.ert_custom_loadouts |= imported_loadout
			update_static_data(ui.user, ui)
			return TRUE
		catch
			to_chat(ui.user, SPAN_WARNING("Unable to decode JSON data."))

/datum/ui_module/ert_loadout_manager/proc/copy_to_new_loadout(datum/tgui/ui)
	var/new_name = tgui_input_text(ui.user, "Choose a unique name for this loadout.", "Copy to New Loadout", "Copy of [selected_loadout.loadout_name]")
	if(new_name)
		var/all_names = get_all_loadout_names()
		if(new_name in all_names)
			tgui_alert(ui.user, "A loadout with the name [new_name] already exists.", "Copy to New Loadout", list("OK"))
			return
		var/datum/ert_loadout/new_loadout = selected_loadout.copy_to_new(new_name)
		GLOB.ert_custom_loadouts.Add(new_loadout)
		set_loadout_by_name(new_name)
		update_static_data(ui.user, ui)
