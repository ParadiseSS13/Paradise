var/global/datum/controller/process/animal/animal_master

/datum/controller/process/animal
	var/current_cycle

/datum/controller/process/animal/setup()
	name = "animal"
	schedule_interval = 20 // every 2 seconds
	start_delay = 16
	log_startup_progress("Simple animal ticker starting up.")
	if(animal_master)
		qdel(animal_master) //only one mob master
	animal_master = src

/datum/controller/process/animal/started()
	..()
	if(!simple_animal_list)
		simple_animal_list = list()

/datum/controller/process/animal/statProcess()
	..()
	stat(null, "[simple_animal_list.len] simple animals")

/datum/controller/process/animal/doWork()
	for(last_object in simple_animal_list)
		var/mob/living/simple_animal/M = last_object
		if(istype(M) && isnull(M.gcDestroyed))
			if(!M.client && M.stat == CONSCIOUS)
				try
					M.process_ai()
				catch(var/exception/e)
					catchException(e, M)
				SCHECK
		else
			catchBadType(M)
			simple_animal_list -= M
	current_cycle++