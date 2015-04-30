/datum/controller/process/mob
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/mob/setup()
	name = "mob"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new
	if(!mob_master)
		mob_master = new
		mob_master.Setup()

/datum/controller/process/mob/started()
	..()
	if(!updateQueueInstance)
		if(!mob_list)
			mob_list = list()
		else if(mob_list.len)
			updateQueueInstance = new

/datum/controller/process/mob/doWork()
	if(updateQueueInstance)
		updateQueueInstance.init(mob_list, "Life")
		updateQueueInstance.Run()
		mob_master.process()

var/global/datum/controller/mob_system/mob_master

/datum/controller/mob_system
	var/current_cycle
	var/starttime

/datum/controller/mob_system/proc/Setup()
	world << "\red Mob ticker starting up."
	starttime = world.timeofday

/datum/controller/mob_system/proc/process()
	current_cycle++