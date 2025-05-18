GLOBAL_LIST_INIT(procedure_manager_jobs, list(
		NTPM_CAPTAIN,
		NTPM_BLUESHIELD,
		NTPM_NTR,

		NTPM_CE,
		NTPM_ENGINEER,
		NTPM_ATMOS,

		NTPM_CMO,
		NTPM_DOCTOR,
		NTPM_PARAMED,
		NTPM_CORONER,
		NTPM_CHEMIST,
		NTPM_VIROLOGIST,
		NTPM_PSYCHAIATRIST,

		NTPM_HOS,
		NTPM_WARDEN,
		NTPM_SECURITY_OFFICER,
		NTPM_DETECTIVE,

		NTPM_HOP,
		NTPM_BARTENDER,
		NTPM_BOTANIST,
		NTPM_CHAPLAIN,
		NTPM_CHEF,
		NTPM_CLOWN,
		NTPM_MIME,
		NTPM_JANITOR,
		NTPM_LIBRARIAN,

		NTPM_QM,
		NTPM_CARGO_TECH,
		NTPM_MINER,
		NTPM_EXPLORER,
		NTPM_SMITH,

		NTPM_RD,
		NTPM_SCIENTIST,
		NTPM_ROBOTICIST,
		NTPM_GENETICIST,

		NTPM_IAA,
		NTPM_MAGISTRATE,
		))

/datum/data/pda/app/procedure_manager
	name = "Procedure Manager"
	title = "Nanotrassen Procedure Manager"
	template = "pda_procedure_manager"
	// Almost positive this is never used anywhere but sure
	update = PDA_APP_NOUPDATE
	/// Which job we have selected
	var/job = ""
	/// The tab currently selected in the app
	var/current_category
	/// A list of the procedures under the currently selected category for our job
	var/list/procedure_list = list()
	/// The text we are searching for within the selected category's procedure list
	var/search_text = ""

/datum/data/pda/app/procedure_manager/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui.set_autoupdate(FALSE)

/datum/data/pda/app/procedure_manager/update_ui(mob/user, list/data)
	data["categories"] = list()
	for(var/category in GLOB.procedure_by_job[job])
		data["categories"] += category
	data["job"] = job
	data["job_list"] = GLOB.procedure_manager_jobs
	data["procedures"] = procedure_list
	data["current_category"] = current_category
	data["search_text"] = search_text

	return data

/datum/data/pda/app/procedure_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("set_category")
			current_category = params["name"]
			search_text = params["search_text"]
			procedure_list = isnull(current_category) ? list() : GLOB.procedure_by_job[job][current_category]
			SStgui.update_uis(pda)
		if("select_job")
			job = params["job"]
			current_category = ""
			SStgui.update_uis(pda)
