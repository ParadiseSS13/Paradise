/datum/event/paradox_clone
	var/spawncount

/datum/event/paradox_clone/setup()
	spawncount = (round(length(get_living_players(exclude_nonhuman = FALSE, exclude_offstation = TRUE)) / 40))
	spawncount += rand(0, spawncount)

/datum/event/paradox_clone/proc/abort()
	var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
	EC.next_event_time = world.time + 60 SECONDS // Fire again in a minute

/datum/event/paradox_clone/start()
	INVOKE_ASYNC(src, PROC_REF(wrapped_start))

/datum/event/paradox_clone/proc/wrapped_start()
	if(!spawncount) //if lower than 40 playas...
		message_admins("Not enough players for Paradox Clone event: [length(get_living_players(exclude_nonhuman = FALSE, exclude_offstation = TRUE))]/40! Aborting. Choosing another moderate event.")
		abort()
		return

	var/wait_time = 20 SECONDS
	var/mob/living/carbon/human/chosen
	var/list/possible_chosen = list()
	var/station_z = level_name_to_num(MAIN_STATION) // idk why GDN removed this, who wants to be a paradox clone of miner or explorer??!?!?!

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind && H.key && H.z == station_z && H.stat == CONSCIOUS && !istype(get_area(H), /area/station/public/sleep) && H.mind.assigned_role != null && !H.mind.offstation_role && !is_paradox_clone(H))
			possible_chosen += H

	if(!length(possible_chosen))
		message_admins("No suitable humans for Paradox Clone event!")
		abort()
		return

	for(var/countd in 1 to spawncount)
		chosen = pick(possible_chosen) // not pick n take to have at least very LOW chance to create an interesting situation like one clone need to protect someone, and second clone need to kill them lol

		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a paradox clone of [chosen.real_name], the [chosen.mind.assigned_role]?", ROLE_PARADOX_CLONE, TRUE, wait_time, source = chosen)

		if(!length(candidates))
			return

		var/list/restricted_spawns = list()

		for(var/area/station/ai_monitored/AI in GLOB.all_areas)
			restricted_spawns += AI

		for(var/area/station/aisat/AI2 in GLOB.all_areas)
			restricted_spawns += AI2

		for(var/area/station/turret_protected/TC in GLOB.all_areas)
			restricted_spawns += TC

		var/list/possible_spawns = list()

		for(var/area/station/S in GLOB.all_areas)
			if(S.valid_territory)
				possible_spawns += S

		for(var/area/A as anything in restricted_spawns)
			if(locate(A) in possible_spawns)
				possible_spawns -= A

		var/turf/T = pick(possible_spawns)

		var/mob/lucky_one = pick_n_take(candidates)
		var/mob/camera/paradox/P = new /mob/camera/paradox(T)
		addtimer(CALLBACK(P, TYPE_PROC_REF(/mob/camera/paradox, expire)), 40 SECONDS, TIMER_STOPPABLE)
		addtimer(CALLBACK(P, TYPE_PROC_REF(/mob/camera/paradox, warning)), 30 SECONDS, TIMER_STOPPABLE)
		P.the_original = chosen
		P.key = lucky_one.key
		SEND_SOUND(P, sound('sound/ambience/antag/paradox_camera_alert.ogg'))
		do_sparks(rand(1, 2), FALSE, P)
		sleep(wait_time + 0.2 SECONDS)
