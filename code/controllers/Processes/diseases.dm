var/datum/controller/process/diseases/disease_master

/datum/controller/process/diseases
	var/list/currentrun = list()
	var/list/processing_diseases = list()

/datum/controller/process/diseases/setup()
	name = "disease"
	schedule_interval = 20 // every 2 seconds
	start_delay = 7
	log_startup_progress("Disease controller starting.")
	if(disease_master)
		qdel(disease_master) //only one mob master
	disease_master = src

	register_diseases() //register all pre-round diseases created

/datum/controller/process/diseases/statProcess()
	..()
	stat(null, "[processing_diseases.len] diseases")


/datum/controller/process/diseases/doWork()
	src.currentrun = processing_diseases.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/disease/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			try
				thing.process()
			catch(var/exception/e)
				catchException(e, thing)
			SCHECK
		else
			catchBadType(thing)
			processing_diseases.Remove(thing)

/datum/controller/process/diseases/proc/register_diseases()
	for(var/datum/disease/D in world)
		if(!processing_diseases.Find(D))
			D.register()
