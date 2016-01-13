var/global/datum/controller/process/mob/mob_master

/datum/controller/process/mob
	var/current_cycle

/datum/controller/process/mob/setup()
	name = "mob"
	schedule_interval = 20 // every 2 seconds
	start_delay = 16
	log_startup_progress("Mob ticker starting up.")
	if(mob_master)
		qdel(mob_master) //only one mob master
	mob_master = src

/datum/controller/process/mob/started()
	..()
	if(!mob_list)
		mob_list = list()

/datum/controller/process/mob/statProcess()
	..()
	stat(null, "[mob_list.len] mobs")

/datum/controller/process/mob/doWork()
	for(last_object in mob_list)
		var/mob/M = last_object
		if(istype(M) && isnull(M.gcDestroyed))
			try
				M.Life()
			catch(var/exception/e)
				catchException(e, M)
			SCHECK
		else
			catchBadType(M)
			mob_list -= M
	current_cycle++