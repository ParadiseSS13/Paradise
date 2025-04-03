GLOBAL_LIST_EMPTY(procedure_by_department)

// A procedure datum used by the procedure PDA app. Contains instructions on how to perform a part of a job.
/datum/procedure
	/// Name of the procedure
	var/name = ""
	/// List of jobs this procedure is relevant to
	var/list/jobs = list()
	/// The category of the procedure for the jobguide PDA app.
	var/catalog_category = "Miscellaneous"
	/// List of steps in text form
	var/list/steps = list()

/proc/initialize_procedures()
	GLOB.procedure_by_department.Cut()
	var/list/procedure_paths = subtypesof(/datum/procedure)
	for(var/path in procedure_paths)
		var/datum/procedure/example_procedure = new path()
		if(!length(example_procedure(steps)))
			continue

		var/list/entry = list()
		entry["name"] = procedure.name
		entry["instructions"] = steps.Copy()
		for(var/job in procedure.jobs)
			LAZYORASSOCLIST(GLOB.procedure_by_job["[job]"], example_procedure.catalog_category, list(entry))
