/datum/crew_manifest
	var/mob/user

/datum/crew_manifest/New(mob/user)
	if(!istype(user))
		qdel(src)


/datum/crew_manifest/ui_interact(user, ui_key = "crew_manifest", datum/tgui/ui = null, datum/tgui/master_ui = null, state = GLOB.observer_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui)
	if(!ui)
		ui = new(user, src, ui_key, "crew_manifest", "Crew Manifest", 588, 510, master_ui)
		ui.open()

/datum/crew_manifest/ui_data(user)
	var/list/data = list()
	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest
	return data
