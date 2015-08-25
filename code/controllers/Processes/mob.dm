/datum/controller/process/mob

/datum/controller/process/mob/setup()
	name = "mob"
	schedule_interval = 20 // every 2 seconds
	start_delay = 16
	if(!mob_master)
		mob_master = new
		mob_master.Setup()

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
	mob_master.process()

var/global/datum/controller/mob_system/mob_master

/datum/controller/mob_system
	var/current_cycle
	var/starttime

/datum/controller/mob_system/proc/Setup()
	log_startup_progress("Mob ticker starting up.")
	starttime = world.timeofday

/datum/controller/mob_system/proc/process()
	current_cycle++