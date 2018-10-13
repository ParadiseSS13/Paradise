SUBSYSTEM_DEF(npcai)
    name = "NPC AI" // Simple AI controller, isolated from the SNPC one (NPCPool).
    flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
    priority = FIRE_PRIORITY_NPC
    runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
    var/list/simple_animal_list = list()

/datum/controller/subsystem/npcai/stat_entry()
	..("SimAnimals:[simple_animal_list.len]")

/datum/controller/subsystem/npcai/fire(resumed = FALSE)
    if(!resumed)
        src.simple_animal_list = simple_animal_list.Copy()
    for(var/mob/living/simple_animal/M in simple_animal_list)
        if(istype(M) && !QDELETED(M))
            if(!M.client && M.stat == CONSCIOUS)
                M.process_ai() 
            if(MC_TICK_CHECK)
                return
        else
            simple_animal_list -= M

/datum/controller/subsystem/npcai/Recover()
    simple_animal_list = SSnpcai.simple_animal_list