SUBSYSTEM_DEF(npcpool)
    name = "NPC Pool"
    flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
    priority = FIRE_PRIORITY_NPC
    runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
    offline_implications = "Simple animals will no longer process. Shuttle call recommended."

    var/list/currentrun = list()

/datum/controller/subsystem/npcpool/stat_entry()
    var/list/activelist = GLOB.simple_animals[AI_ON]
    ..("SimpleAnimals:[activelist.len]")

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)

    if(!resumed)
        var/list/activelist = GLOB.simple_animals[AI_ON]
        src.currentrun = activelist.Copy()

    var/list/currentrun = src.currentrun

    while(currentrun.len)
        var/mob/living/simple_animal/SA = currentrun[currentrun.len]
        --currentrun.len
        if(!SA)
            log_debug("npcpool encountered an invalid entry, resumed: [resumed], SA [SA], type of SA [SA?.type], null [SA == null], qdelled [QDELETED(SA)], SA in AI_ON list: [SA in GLOB.simple_animals[AI_ON]]")
            GLOB.simple_animals[AI_ON] -= SA
            continue

        if(!SA.ckey && !SA.notransform)
            if(SA.stat != DEAD)
                SA.handle_automated_movement()
            if(SA.stat != DEAD)
                SA.handle_automated_action()
            if(SA.stat != DEAD)
                SA.handle_automated_speech()
        if(MC_TICK_CHECK)
            return
