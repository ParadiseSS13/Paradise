var/global/datum/controller/process/npcai/npcai_master

/datum/controller/process/npcai
	var/current_cycle
	var/saved_voice = 0

/datum/controller/process/npcai/setup()
	name = "npc ai"
	schedule_interval = 20 // every 2 seconds
	start_delay = 16
	log_startup_progress("NPC ticker starting up.")
	if(npcai_master)
		qdel(npcai_master) //only one mob master
	npcai_master = src

/datum/controller/process/npcai/started()
	..()
	if(!simple_animal_list)
		simple_animal_list = list()
	if(!snpc_list)
		snpc_list = list()

/datum/controller/process/npcai/statProcess()
	..()
	stat(null, "[simple_animal_list.len] simple animals")
	stat(null, "[snpc_list.len] SNPC's")

/datum/controller/process/npcai/doWork()
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

	if(ticker.current_state == GAME_STATE_FINISHED && !saved_voice)
		var/mob/living/carbon/human/interactive/M = pick(snpc_list)
		if(M)
			M.saveVoice()
			saved_voice = 1

	for(last_object in snpc_list)
		var/mob/living/carbon/human/interactive/M = last_object
		if(istype(M) && isnull(M.gcDestroyed))
			try
				if(!M.alternateProcessing || M.forceProcess)
					M.doProcess()
			catch(var/exception/e)
				catchException(e, M)
			SCHECK
		else
			catchBadType(M)
			snpc_list -= M

	current_cycle++