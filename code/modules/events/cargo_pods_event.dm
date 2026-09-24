/datum/event/cargo_pods
	name = "Cargo Pod Impact"
	role_weights = list(ASSIGNMENT_ENGINEERING = 1)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 1)
	nominal_severity = EVENT_LEVEL_MODERATE

	announceWhen = 1
	/// Areas pods are being dropped to
	var/list/drop_areas = list()
	/// Number of pods to drop
	var/number_of_pods = 3

/datum/event/cargo_pods/announce()
	var/announcement = "Multiple jettisoned cargo pods have been detected on a collision course with the station. Estimated impact zones: "
	for(var/area/A in drop_areas)
		announcement += "\n- [A.name]"
	announcement += "\n\n - A.L.I.C.E."
	GLOB.minor_announcement.Announce(announcement, "Proximity Alert")

/datum/event/cargo_pods/setup()
	number_of_pods = rand(1, 4)
	var/list/possible_areas = findUnrestrictedEventArea()
	for(var/i in 1 to number_of_pods)
		var/area/drop_area = pick(possible_areas)
		drop_areas += drop_area

/datum/event/cargo_pods/start()
	for(var/area/drop_area in drop_areas)
		var/list/possible_turfs = get_area_turfs(drop_area)
		var/turf/T = null
		for(var/i in 1 to length(possible_turfs))
			T = pick_n_take(possible_turfs)
			if(!T.is_blocked_turf())
				break
		var/pack_selected = FALSE
		var/pack_name
		var/datum/supply_packs/pack_to_drop
		while(!pack_selected)
			pack_name = pick(SSeconomy.supply_packs)
			pack_to_drop = SSeconomy.supply_packs[pack_name]
			if(!istype(pack_to_drop, /datum/supply_packs/abstract))
				pack_selected = TRUE
		log_debug("Cargo Pod Dropped - [pack_name]")
		new /obj/effect/temp_visual/cargo_drop_pod(T)
		addtimer(CALLBACK(src, PROC_REF(drop_pod), T, pack_to_drop), rand(5 SECONDS, 8 SECONDS))

/datum/event/cargo_pods/proc/drop_pod(turf/T, datum/supply_packs/pack_to_drop)
	explosion(T, 0, 2, 4, 6, cause = "Cargo Pod Event")
	sleep(1)
	for(var/I in pack_to_drop.contains)
		var/list/possible_spawn_turfs = view(4, T)
		shuffle(possible_spawn_turfs)
		var/turf/spawn_turf = T
		for(var/turf/possible_spawn_turf in possible_spawn_turfs)
			if(!possible_spawn_turf.is_blocked_turf())
				spawn_turf = possible_spawn_turf
				break
		new I(spawn_turf)
