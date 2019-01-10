var/global/datum/controller/process/npcai/npcai_master

/datum/controller/process/npcai
	var/current_cycle

/datum/controller/process/npcai/setup()
	name = "npc ai"
	schedule_interval = 20 // every 2 seconds
	start_delay = 16
	log_startup_progress("NPC ticker starting up.")

/datum/controller/process/npcai/started()
	..()
	if(!GLOB.simple_animal_list)
		GLOB.simple_animal_list = list()
	if(!GLOB.snpc_list)
		GLOB.snpc_list = list()

/datum/controller/process/npcai/statProcess()
	..()
	stat(null, "[GLOB.simple_animal_list.len] simple animals")
	stat(null, "[GLOB.snpc_list.len] SNPC's")

/datum/controller/process/npcai/doWork()
	for(last_object in GLOB.simple_animal_list)
		var/mob/living/simple_animal/M = last_object
		if(istype(M) && !QDELETED(M))
			if(!M.client && M.stat == CONSCIOUS)
				try
					M.process_ai()
				catch(var/exception/e)
					catchException(e, M)
				SCHECK
		else
			catchBadType(M)
			GLOB.simple_animal_list -= M

	current_cycle++


DECLARE_GLOBAL_CONTROLLER(npcai, npcai_master)
