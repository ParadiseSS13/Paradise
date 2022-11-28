/client/proc/open_borgopanel(borgo in GLOB.silicon_mob_list)
	set category = "Admin"
	set name = "Show Borg Panel"
	set desc = "Show borg panel"

	if(!check_rights(R_ADMIN))
		return

	if(!isrobot(borgo))
		borgo = input("Select a borg", "Select a borg", null, null) as null|anything in GLOB.silicon_mob_list
	if(!isrobot(borgo))
		to_chat(usr, "<span class='warning'>Borg is required for borgpanel</span>")
		return

	var/datum/borgpanel/borgpanel = new(usr, borgo)

	borgpanel.ui_interact(usr, state = GLOB.admin_state)
	log_and_message_admins("has opened [borgo]'s Borg Panel.")

/datum/borgpanel
	var/name = "Borg Panel"
	var/mob/living/silicon/robot/borg
	var/user

/datum/borgpanel/New(to_user, mob/living/silicon/robot/to_borg)
	if(!istype(to_borg))
		qdel(src)
		CRASH("Borg panel is only available for borgs")
	user = to_user
	borg = to_borg

/datum/borgpanel/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BorgPanel", name, 700, 700, master_ui, state)
		ui.open()

/datum/borgpanel/ui_data(mob/user)
	. = list()
	.["borg"] = list(
		"name" = "[borg]",
		"emagged" = borg.emagged,
		"active_module" = "[borg.module ? borg.module.name : "No module"]",
		"lawupdate" = borg.lawupdate,
		"lockdown" = borg.lockcharge,
		"scrambledcodes" = borg.scrambledcodes
	)
	.["upgrades"] = list()
	for (var/upgradetype in subtypesof(/obj/item/borg/upgrade)-list(/obj/item/borg/upgrade/rename, /obj/item/borg/upgrade/restart, /obj/item/borg/upgrade/reset))
		var/obj/item/borg/upgrade/upgrade = upgradetype
		if(!borg.module && initial(upgrade.require_module)) //Borg needs to select a module first
			continue
		if (initial(upgrade.module_type) && (borg.module != initial(upgrade.module_type))) // Upgrade requires a different module
			continue
		var/installed = FALSE
		if (locate(upgradetype) in borg)
			installed = TRUE
		.["upgrades"] += list(list("name" = initial(upgrade.name), "installed" = installed, "type" = upgradetype))
	.["laws"] = list()
	for(var/datum/ai_law/law in borg.laws?.all_laws())
		.["laws"] += "[law.index]. [law.law]"
	.["channels"] = list()
	for (var/k in SSradio.radiochannels)
		if (k == PUB_FREQ)
			continue
		.["channels"] += list(list("name" = k, "installed" = (k in borg.radio.channels)))
	.["cell"] = borg.cell ? list("missing" = FALSE, "maxcharge" = borg.cell.maxcharge, "charge" = borg.cell.charge) : list("missing" = TRUE, "maxcharge" = 1, "charge" = 0)
	.["modules"] = list()
	for(var/module_type in typesof(/obj/item/robot_module)-/obj/item/robot_module)
		var/obj/item/robot_module/module = module_type
		var/name = initial(module.name)
		.["modules"] += list(list("name" = "[name]", "type" = module_type))
	.["ais"] = list(list("name" = "None", "connected" = isnull(borg.connected_ai)))
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		.["ais"] += list(list("name" = ai.name, "connected" = (borg.connected_ai == ai)))


/datum/borgpanel/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch (action)
		if("set_charge")
			var/newcharge = input(usr, "Set new charge", borg.name, borg.cell.charge) as num|null
			newcharge = between(0,newcharge, borg.cell.maxcharge)
			if(isnull(newcharge))
				return
			borg.cell.charge = newcharge
			log_and_message_admins("set the charge of [key_name(borg)] to [borg.cell.charge].")
		if("remove_cell")
			var/datum/robot_component/cell/C = borg.components["power cell"]
			if(!borg.cell)
				to_chat(usr, "There is no power cell installed!")
				return
			borg.cell = null
			C.wrapped = null
			C.installed = FALSE
			C.uninstall()
			log_and_message_admins("removed the cell of [key_name(borg)].")
		if("change_cell")
			var/datum/robot_component/cell/C = borg.components["power cell"]
			var/chosen = pick_closest_path(null, make_types_fancy(typesof(/obj/item/stock_parts/cell)))
			if(!ispath(chosen))
				chosen = text2path(chosen)
			if(chosen)
				if(borg.cell)
					borg.cell = null
					C.wrapped = null
					C.installed = FALSE
					C.uninstall()
				var/obj/item/stock_parts/cell/new_cell = new chosen(borg)
				borg.cell = new_cell
				C.wrapped = new_cell
				C.installed = TRUE
				C.install()
				borg.cell.charge = borg.cell.maxcharge
				borg.diag_hud_set_borgcell()
				log_and_message_admins("changed the cell of [key_name(borg)] to [new_cell].")
		if("toggle_emagged")
			borg.SetEmagged(!borg.emagged)
			if (borg.emagged)
				log_and_message_admins("emagged [key_name(borg)].")
			else
				log_and_message_admins("un-emagged [key_name(borg)].")
		if("lawmanager")
			var/datum/ui_module/law_manager/L = new(borg)
			L.ui_interact(usr, state = GLOB.admin_state)
			log_and_message_admins("has opened [borg]'s law manager.")
		if("toggle_lawupdate")
			borg.lawupdate = !borg.lawupdate
			if (borg.lawupdate)
				log_and_message_admins("enabled lawsync on [key_name(borg)].")
			else
				log_and_message_admins("disabled lawsync on [key_name(borg)].")
		if("toggle_lockdown")
			borg.SetLockdown(!borg.lockcharge)
			if (borg.lockcharge)
				log_and_message_admins("locked down [key_name(borg)].")
			else
				log_and_message_admins("released [key_name(borg)] from lockdown.")
		if("toggle_scrambledcodes")
			borg.scrambledcodes = !borg.scrambledcodes
			if (borg.scrambledcodes)
				log_and_message_admins("enabled scrambled codes on [key_name(borg)].")
			else
				log_and_message_admins("disabled scrambled codes on [key_name(borg)].")
		if("rename")
			var/new_name = sanitize(input(user, "What would you like to name this cyborg?", "Cyborg Reclassification", borg.real_name))
			if(!new_name)
				return
			log_and_message_admins("renamed [key_name(borg)] to [new_name].")
			borg.rename_character(borg.real_name,new_name)
		if("toggle_upgrade")
			var/upgradepath = text2path(params["upgrade"])
			var/obj/item/borg/upgrade/installedupgrade = locate(upgradepath) in borg
			if(installedupgrade)
				log_and_message_admins("removed the [installedupgrade] upgrade from [key_name(borg)].")
				qdel(installedupgrade) // see [mob/living/silicon/robot/on_upgrade_deleted()].
			else
				var/obj/item/borg/upgrade/upgrade = new upgradepath(borg)
				if(upgrade.action(borg))
					borg.install_upgrade(upgrade)
					log_and_message_admins("added the [upgrade] borg upgrade to [key_name(borg)].")
		if("toggle_radio")
			var/channel = params["channel"]
			if(channel in borg.radio.channels) // We're removing a channel
				if(!borg.radio.keyslot) // There's no encryption key. This shouldn't happen but we can cope
					borg.radio.channels -= channel
				else
					borg.radio.keyslot.channels -= channel
					if(channel == "Syndicate")
						borg.radio.keyslot.syndie = FALSE
				log_and_message_admins("removed the [channel] radio channel from [key_name(borg)].")
			else // We're adding a channel
				if(!borg.radio.keyslot) // Assert that an encryption key exists
					borg.radio.keyslot = new()
				borg.radio.keyslot.channels[channel] = 1
				if(channel == "Syndicate")
					borg.radio.keyslot.syndie = TRUE
				log_and_message_admins("added the [channel] radio channel to [key_name(borg)].")
			borg.radio.recalculateChannels()
		if("setmodule")
			var/new_module = params["module"]
			if(borg.module)
				borg.reset_module()
			borg.pick_module(new_module)
			log_and_message_admins("changed the module of [key_name(borg)] to [new_module].")
		if("reset_module")
			var/obj/item/borg/upgrade/reset/reset = new(borg)
			if(reset.action(borg))
				borg.install_upgrade(reset)
				log_and_message_admins("resets [key_name(borg)] module.")
		if("slavetoai")
			var/mob/living/silicon/ai/newai = locate(params["slavetoai"]) in GLOB.ai_list
			if(newai && newai != borg.connected_ai)
				borg.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
				borg.connect_to_ai(newai)
				borg.notify_ai(TRUE)
				log_and_message_admins("slaved [key_name(borg)] to the AI [key_name(newai)].")
			else if (params["slavetoai"] == "null")
				borg.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
				borg.disconnect_from_ai()
				log_and_message_admins("freed [key_name(borg)] from being slaved to an AI.")
			if (borg.lawupdate)
				borg.lawsync()

	. = TRUE
