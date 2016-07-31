var/global/datum/controller/process/fire/fire_master

/datum/controller/process/fire
	var/list/burning = list()

/datum/controller/process/fire/setup()
	name = "fire"
	schedule_interval = 20 //every 2 seconds
	fire_master = src
	log_startup_progress("Fire process starting up.")

/datum/controller/process/fire/statProcess()
	..()
	stat(null, "[burning.len] burning objects")

/datum/controller/process/fire/doWork()
	for(var/obj/burningobj in burning)
		if(burningobj.burn_state == ON_FIRE)
			if(burningobj.burn_world_time < world.time)
				burningobj.burn()
				SCHECK
		else
			burning.Remove(burningobj)