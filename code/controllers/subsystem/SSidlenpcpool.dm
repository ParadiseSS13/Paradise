SUBSYSTEM_DEF(idlenpcpool)
	name = "Idling NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_IDLE_NPC
	wait = 60
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_IDLENPCS // MUST be after SSmapping since it tracks max Zs
	offline_implications = "Idle simple animals will no longer process. Shuttle call recommended."

	var/list/currentrun = list()
	var/static/list/idle_mobs_by_zlevel[][]

/datum/controller/subsystem/idlenpcpool/get_stat_details()
	return "IdleNPCS:[length(GLOB.simple_animals[AI_IDLE])]|Z:[length(GLOB.simple_animals[AI_Z_OFF])]"

/datum/controller/subsystem/idlenpcpool/Initialize()
	idle_mobs_by_zlevel = new /list(world.maxz, 0)

/datum/controller/subsystem/idlenpcpool/fire(resumed = FALSE)
	if(!resumed)
		var/list/idlelist = GLOB.simple_animals[AI_IDLE]
		src.currentrun = idlelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/mob/living/simple_animal/SA = currentrun[length(currentrun)]
		--currentrun.len
		if(!SA)
			log_debug("idlenpcpool encountered an invalid entry, resumed: [resumed], SA [SA], type of SA [SA?.type], null [SA == null], qdelled [QDELETED(SA)], SA in AI_IDLE list: [SA in GLOB.simple_animals[AI_IDLE]]")
			GLOB.simple_animals[AI_IDLE] -= SA
			continue

		if(!SA.ckey)
			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.consider_wakeup()
		if(MC_TICK_CHECK)
			return
