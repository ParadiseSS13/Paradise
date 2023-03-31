GLOBAL_DATUM_INIT(generic_crew_manifest, /datum/ui_module/generic_crew_manifest, new)

/datum/ui_module/generic_crew_manifest
	name = "Crew Manifest"

/datum/ui_module/generic_crew_manifest/ui_interact(user, ui_key = "GenericCrewManifest", datum/tgui/ui = null, datum/tgui/master_ui = null, state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui)
	if(!ui)
		ui = new(user, src, ui_key, "GenericCrewManifest", name, 588, 510, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/generic_crew_manifest/ui_data(user)
	var/list/data = list()
	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest
	return data
