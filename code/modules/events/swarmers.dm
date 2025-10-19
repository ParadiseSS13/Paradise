/datum/event/swarmers

	name = "swarmer portal"
	/// The name of the notification for dchat
	var/notify_title = "swarmer portal"
	/// The icon of the notification
	var/notify_image = ""
	var/obj/effect/swarmer_portal/TE


/datum/event/swarmers/setup()
	impact_area = findMaintananceEventArea()

/datum/event/swarmers/start()
	if(isnull(impact_area))
		log_debug("No valid event areas could be generated for swarmers.")
	var/list/area_turfs = get_area_turfs(impact_area)
	while(length(area_turfs))
		var/turf/T = pick_n_take(area_turfs)
		if(T.is_blocked_turf())
			continue
		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/animal.dmi', notify_image)
		notify_ghosts("\A [src] is about to spawn in [get_area(T)].", title = notify_title, source = T, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, PROC_REF(spawn_portal), T), 5 SECONDS)

		return

	log_debug("swarmers failed to find a valid turf in [impact_area]")


/datum/event/swarmers/proc/spawn_portal(location)
	TE = new /obj/effect/swarmer_portal(location)

/obj/effect/swarmer_portal
	// Swarmer Portal
	name = "Swarmer Portal"
	desc = "A shimmering portal, crackling and humming with live electricity."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	light_range = 2

	// Mobtype
	var/spawn_max = 0
	var/spawn_total = 0
	var/list/possible_mobs = list(
		/mob/living/basic/swarmer)

/obj/effect/swarmer_portal/Initialize(mapload)
	. = ..()
	log_debug("MAPLOAD PASS")
	spawn_max = max(length(GLOB.crew_list) / 10, 1)
	log_debug("MATH PASS")
	addtimer(CALLBACK(src, PROC_REF(spawn_next_swarmer)), 2 SECONDS)
	log_debug("COOLDOWN TIMER PASS")

/obj/effect/swarmer_portal/proc/spawn_next_swarmer()
	log_debug("+1 SWARMER")
	if(spawn_total < spawn_max)
		make_mob(pick(possible_mobs))
		log_debug("MOB SPAWNING")
		addtimer(CALLBACK(src, PROC_REF(spawn_next_swarmer)), 2 SECONDS)
		log_debug("COOLDOWN TIMER PASS")
	else
		qdel(src)


/obj/effect/swarmer_portal/proc/make_mob(mob_type)
	var/mob/M = new mob_type(get_turf(src))
	log_debug("MOB CREATED")
	M.faction = list("swarmer")
	spawn_total++
	do_sparks(5, TRUE, src)
	step(M, pick(GLOB.cardinal))
	log_debug("MOB MOVED")
