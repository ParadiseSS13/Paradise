GLOBAL_LIST_INIT(job_guide_jobs, list(
		JOBGUIDE_CAPTAIN,
		JOBGUIDE_BLUESHIELD,
		JOBGUIDE_NTR,

		JOBGUIDE_CE,
		JOBGUIDE_ENGINEER,
		JOBGUIDE_ATMOS,

		JOBGUIDE_CMO,
		JOBGUIDE_DOCTOR,
		JOBGUIDE_PARAMED,
		JOBGUIDE_CORONER,
		JOBGUIDE_CHEMIST,
		JOBGUIDE_VIROLOGIST,
		JOBGUIDE_PSYCHAIATRIST,

		JOBGUIDE_HOS,
		JOBGUIDE_WARDEN,
		JOBGUIDE_SECURITY_OFFICER,
		JOBGUIDE_DETECTIVE,

		JOBGUIDE_HOP,
		JOBGUIDE_BARTENDER,
		JOBGUIDE_BOTANIST,
		JOBGUIDE_CHAPLAIN,
		JOBGUIDE_CHEF,
		JOBGUIDE_CLOWN,
		JOBGUIDE_MIME,
		JOBGUIDE_JANITOR,
		JOBGUIDE_LIBRARIAN,

		JOBGUIDE_QM,
		JOBGUIDE_CARGO_TECH,
		JOBGUIDE_MINER,
		JOBGUIDE_EXPLORER,
		JOBGUIDE_SMITH,

		JOBGUIDE_RD,
		JOBGUIDE_SCIENTIST,
		JOBGUIDE_ROBOTICIST,
		JOBGUIDE_GENETICIST,

		JOBGUIDE_IAA,
		JOBGUIDE_MAGISTRATE,
		))

/datum/data/pda/app/job_guide
	name = "Procedure Manager"
	title = "Nanotrassen Procedure Manager"
	template = "pda_job_guide"
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

/datum/data/pda/app/job_guide/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui.set_autoupdate(FALSE)

/datum/data/pda/app/job_guide/update_ui(mob/user, list/data)
	data["categories"] = list()
	for(var/category in GLOB.procedure_by_job[job])
		data["categories"] += category
	data["job"] = job
	data["job_list"] = GLOB.job_guide_jobs
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
		if("select_job")
			job = params["job"]
			current_category = ""
			SStgui.update_uis(pda)
