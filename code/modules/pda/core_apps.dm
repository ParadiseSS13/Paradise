/datum/data/pda/app/main_menu
	icon = "home"
	template = "pda_main_menu"
	hidden = 1

/datum/data/pda/app/main_menu/update_ui(mob/user as mob, list/data)
	title = pda.name

	data["app"]["is_home"] = TRUE

	data["apps"] = pda.shortcut_cache
	data["categories"] = pda.shortcut_cat_order
	data["pai"] = !isnull(pda.pai)				// pAI inserted?

	var/list/notifying = list()
	for(var/datum/data/pda/P in pda.notifying_programs)
		notifying["[P.UID()]"] = TRUE
	data["notifying"] = notifying

/datum/data/pda/app/main_menu/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("UpdateInfo")
			pda.ownjob = pda.id.assignment
			pda.ownrank = pda.id.rank
			pda.owner = pda.id.registered_name
			pda.name = "PDA-[pda.owner] ([pda.ownjob])"
			if(!pda.silent)
				playsound(pda, 'sound/machines/terminal_processing.ogg', 15, TRUE)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), pda, 'sound/machines/terminal_success.ogg', 15, TRUE), 1.3 SECONDS)
		if("pai")
			if(pda.pai)
				if(pda.pai.loc != pda)
					pda.pai = null
				else
					switch(text2num(params["option"]))
						if(1)		// Configure pAI device
							pda.pai.attack_self__legacy__attackchain(usr)
						if(2)		// Eject pAI device
							var/turf/T = get_turf(pda.loc)
							if(T)
								pda.pai.forceMove(T)
								pda.pai = null
								playsound(pda, 'sound/machines/terminal_eject.ogg', 50, TRUE)

/datum/data/pda/app/notekeeper
	name = "Notekeeper"
	icon = "sticky-note-o"
	template = "pda_notes"

	var/note

/datum/data/pda/app/notekeeper/start()
	. = ..()
	if(!note)
		note = "Congratulations, your station has chosen the [pda.model_name]!"

/datum/data/pda/app/notekeeper/update_ui(mob/user as mob, list/data)
	data["note"] = html_decode(note)	// current pda notes

/datum/data/pda/app/notekeeper/ui_act(action, params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	switch(action)
		if("Edit")
			var/n = tgui_input_text(usr, "Please enter message", name, note, multiline = TRUE, encode = FALSE)
			if(isnull(n))
				return

			if(pda.loc == usr)
				note = n
			else
				pda.close(usr)

/datum/data/pda/app/manifest
	name = "Crew Manifest"
	icon = "user"
	template = "pda_manifest"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/manifest/update_ui(mob/user as mob, list/data)
	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest

/datum/data/pda/app/atmos_scanner
	name = "Atmospheric Scan"
	icon = "fire"
	template = "pda_atmos_scan"
	category = "Utilities"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/atmos_scanner/update_ui(mob/user as mob, list/data)
	var/list/results = list()
	var/turf/T = get_turf(user.loc)
	if(!isnull(T))
		var/datum/gas_mixture/environment = T.get_readonly_air()

		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()

		if(total_moles)
			var/o2_level = environment.oxygen()/total_moles
			var/n2_level = environment.nitrogen() / total_moles
			var/co2_level = environment.carbon_dioxide() / total_moles
			var/plasma_level = environment.toxins() / total_moles
			var/n2o_level = environment.sleeping_agent() / total_moles
			var/unknown_level = 1 - (o2_level + n2_level + co2_level + plasma_level + n2o_level)
			results = list(
				list("entry" = "Pressure", "units" = "kPa", "val" = "[round(pressure,0.1)]", "bad_high" = 120, "poor_high" = 110, "poor_low" = 95, "bad_low" = 80),
				list("entry" = "Temperature", "units" = "C", "val" = "[round(environment.temperature()-T0C,0.1)]", "bad_high" = 35, "poor_high" = 25, "poor_low" = 15, "bad_low" = 5),
				list("entry" = "Oxygen", "units" = "%", "val" = "[round(o2_level*100,0.1)]", "bad_high" = 140, "poor_high" = 135, "poor_low" = 19, "bad_low" = 17),
				list("entry" = "Nitrogen", "units" = "%", "val" = "[round(n2_level*100,0.1)]", "bad_high" = 105, "poor_high" = 85, "poor_low" = 50, "bad_low" = 40),
				list("entry" = "Carbon Dioxide", "units" = "%", "val" = "[round(co2_level*100,0.1)]", "bad_high" = 10, "poor_high" = 5, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Plasma", "units" = "%", "val" = "[round(plasma_level*100,0.01)]", "bad_high" = 0.5, "poor_high" = 0, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Nitrous Oxide", "units" = "%", "val" = "[round(n2o_level*100,0.01)]", "bad_high" = 0.5, "poor_high" = 0, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Other", "units" = "%", "val" = "[round(unknown_level*100,0.01)]", "bad_high" = 1, "poor_high" = 0.5, "poor_low" = 0, "bad_low" = 0)
			)

	if(isnull(results))
		results = list(list("entry" = "pressure", "units" = "%", "val" = "0", "bad_high" = 120, "poor_high" = 110, "poor_low" = 95, "bad_low" = 80))

	data["aircontents"] = results
