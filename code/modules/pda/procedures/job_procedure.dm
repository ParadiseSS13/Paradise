GLOBAL_LIST_EMPTY(procedure_by_job)

// A procedure datum used by the procedure PDA app. Contains instructions on how to perform a part of a job.
/datum/procedure
	/// Name of the procedure
	var/name = ""
	/// List of jobs this procedure is relevant to
	var/list/jobs = list()
	/// The category of the procedure for the NTPM PDA app.
	var/procedure_categories = list("Miscellaneous")
	/// List of steps in text form
	var/list/steps = list()

/proc/initialize_procedures()
	GLOB.procedure_by_job.Cut()
	var/list/procedure_paths = subtypesof(/datum/procedure)
	for(var/path in procedure_paths)
		var/datum/procedure/example_procedure = new path()
		// No steps means no procedure. Probably an abstract
		if(!length(example_procedure.steps))
			continue
		var/list/entry = list()
		entry["name"] = example_procedure.name
		entry["instructions"] = example_procedure.steps.Copy()
		// Put the procedure in every job where it is relevant
		for(var/job in example_procedure.jobs)
			for(var/category in example_procedure.procedure_categories)
				LAZYORASSOCLIST(GLOB.procedure_by_job["[job]"], category, list(entry))
