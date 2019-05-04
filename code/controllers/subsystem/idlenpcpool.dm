SUBSYSTEM_DEF(idlenpcpool)
	name = "Idling NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_IDLE_NPC
	wait = 60
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/idle_mobs_by_zlevel[][]

/datum/controller/subsystem/idlenpcpool/stat_entry()
	var/list/idlelist = GLOB.simple_animals[AI_IDLE]
	var/list/zlist = GLOB.simple_animals[AI_Z_OFF]
	..("IdleNPCS:[idlelist.len]|Z:[zlist.len]")

/datum/controller/subsystem/idlenpcpool/Initialize(start_timeofday)
	idle_mobs_by_zlevel = new /list(world.maxz,0)
	return ..()

/datum/controller/subsystem/idlenpcpool/fire(resumed = FALSE)
	if(!resumed)
		var/list/idlelist = GLOB.simple_animals[AI_IDLE]
		src.currentrun = idlelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len
		if(!SA)
			GLOB.simple_animals[AI_IDLE] -= SA
			continue

		if(!SA.ckey)
			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.consider_wakeup()
		if(MC_TICK_CHECK)
			return 