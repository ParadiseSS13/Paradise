/datum/data/pda/app/main_menu
	icon = "home"
	template = "pda_main_menu"
	hidden = 1

/datum/data/pda/app/main_menu/update_ui(mob/user as mob, list/data)
	title = pda.name

	data["app"]["is_home"] = 1

	data["apps"] = pda.shortcut_cache
	data["categories"] = pda.shortcut_cat_order
	data["pai"] = !isnull(pda.pai)				// pAI inserted?

	var/list/notifying[0]
	for(var/P in pda.notifying_programs)
		notifying["\ref[P]"] = 1
	data["notifying"] = notifying

/datum/data/pda/app/main_menu/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("UpdateInfo")
			pda.ownjob = pda.id.assignment
			pda.ownrank = pda.id.rank
			pda.name = "PDA-[pda.owner] ([pda.ownjob])"
		if("pai")
			if(pda.pai)
				if(pda.pai.loc != pda)
					pda.pai = null
				else
					switch(href_list["option"])
						if("1")		// Configure pAI device
							pda.pai.attack_self(usr)
						if("2")		// Eject pAI device
							var/turf/T = get_turf_or_move(pda.loc)
							if(T)
								pda.pai.loc = T
								pda.pai = null

/datum/data/pda/app/notekeeper
	name = "Notekeeper"
	icon = "sticky-note-o"
	template = "pda_notekeeper"

	var/note = null
	var/notehtml = ""

/datum/data/pda/app/notekeeper/start()
	. = ..()
	if(!note)
		note = "Congratulations, your station has chosen the [pda.model_name]!"

/datum/data/pda/app/notekeeper/update_ui(mob/user as mob, list/data)
	data["note"] = note									// current pda notes

/datum/data/pda/app/notekeeper/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Edit")
			var/n = input("Please enter message", name, notehtml) as message
			if(pda.loc == usr)
				note = adminscrub(n)
				notehtml = html_decode(note)
				note = replacetext(note, "\n", "<br>")
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

/datum/data/pda/app/manifest/Topic(href, list/href_list)

/datum/data/pda/app/atmos_scanner
	name = "Atmospheric Scan"
	icon = "fire"
	template = "pda_atmos_scan"
	category = "Utilities"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/atmos_scanner/update_ui(mob/user as mob, list/data)
	var/turf/T = get_turf(user.loc)
	if(!isnull(T))
		var/datum/gas_mixture/environment = T.return_air()

		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()

		if(total_moles)
			var/o2_level = environment.oxygen/total_moles
			var/n2_level = environment.nitrogen/total_moles
			var/co2_level = environment.carbon_dioxide/total_moles
			var/plasma_level = environment.toxins/total_moles
			var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
			data["aircontents"] = list(
				"pressure" = pressure,
				"nitrogen" = n2_level*100,
				"oxygen" = o2_level*100,
				"carbon_dioxide" = co2_level*100,
				"plasma" = plasma_level*100,
				"other" = unknown_level,
				"temp" = environment.temperature-T0C,
				"reading" = 1
				)
	if(isnull(data["aircontents"]))
		data["aircontents"] = list("reading" = 0)
