/datum/data/pda/app/job_guide
	name = "Job Guide"
	title = "Job Guide"
	template = "pda_job_guide"
	// Almost positive this is never used anywhere but sure
	update = PDA_APP_NOUPDATE
	/// Which job is this for
	var/job = ""
	var/current_category
	var/list/procedure_list = list()
	var/search_text = ""

/datum/data/pda/app/job_guide/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui.set_autoupdate(FALSE)

/datum/data/pda/app/job_guide/update_ui(mob/user, list/data)
	data["categories"] = list()
	for(var/category in GLOB.pcwj_job_guide_lookup)
		data["categories"] += category

	data["procedures"] = procedure_list
	data["current_category"] = current_category
	data["search_text"] = search_text

	return data

/datum/data/pda/app/job_guide/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("set_category")
			current_category = params["name"]
			search_text = params["search_text"]
			procedure_list = isnull(current_category) ? list() : GLOB.procedure_by_job[job][current_category]
			SStgui.update_uis(pda)