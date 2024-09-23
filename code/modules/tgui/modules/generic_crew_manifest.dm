GLOBAL_DATUM_INIT(generic_crew_manifest, /datum/ui_module/generic_crew_manifest, new)

/datum/ui_module/generic_crew_manifest
	name = "Crew Manifest"

/datum/ui_module/generic_crew_manifest/ui_state(mob/user)
	if(isnewplayer(user))
		return GLOB.always_state
	if(isobserver(user))
		return GLOB.observer_state
	if(issilicon(user))
		return GLOB.not_incapacitated_state

/datum/ui_module/generic_crew_manifest/ui_interact(user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GenericCrewManifest", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/generic_crew_manifest/ui_data(user)
	var/list/data = list()
	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest
	return data
