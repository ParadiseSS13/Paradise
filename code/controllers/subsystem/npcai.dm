SUBSYSTEM_DEF(npcai)
    name = "NPC AI" // Simple AI controller, isolated from the SNPC one (NPCPool). As of this comment, NPCAI on Para is closer to NPCPool on Tg than NPCpool on para, because we didn't remove SNPC
    flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
    priority = FIRE_PRIORITY_NPC
    runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

    var/list/currentrun = list()

/datum/controller/subsystem/npcai/stat_entry()
    var/list/activelist = GLOB.simple_animals[AI_ON]
    ..("SimpleAnimals:[activelist.len]")

/datum/controller/subsystem/npcai/fire(resumed = FALSE)

    if(!resumed)
        var/list/activelist = GLOB.simple_animals[AI_ON]
        src.currentrun = activelist.Copy()

    var/list/currentrun = src.currentrun

    while(currentrun.len)
        var/mob/living/simple_animal/SA = currentrun[currentrun.len]
        --currentrun.len

        if(!SA.client && SA.stat == CONSCIOUS)
            SA.process_ai() 
        if(MC_TICK_CHECK)
            return