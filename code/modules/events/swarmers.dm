/datum/event/swarmers
	name = "Swarmer Infestation"
	nominal_severity = EVENT_LEVEL_MAJOR
	role_weights = list(ASSIGNMENT_ENGINEERING = 5, ASSIGNMENT_SECURITY = 3, ASSIGNMENT_CREW = 0.8)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 1, ASSIGNMENT_SECURITY = 1, ASSIGNMENT_CREW = 20)
	/// The name of the notification for dchat
	var/notify_title = "swarmer portal"

/datum/event/swarmers/setup()
	impact_area = findMaintananceEventArea()

/datum/event/swarmers/start()
	if(isnull(impact_area))
		log_debug("No valid event areas could be generated for swarmers.")
		return
	var/list/area_turfs = get_area_turfs(impact_area)
	for(var/i in 1 to length(area_turfs))
		var/turf/T = pick_n_take(area_turfs)
		if(T.is_blocked_turf())
			shuffle(area_turfs)
			continue
		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/swarmer.dmi', "ui_replicate")
		notify_ghosts("\A [src] is about to spawn in [get_area(T)].", title = notify_title, source = T, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, PROC_REF(spawn_portal), T), 5 SECONDS)
		return

	log_debug("swarmers failed to find a valid turf in [impact_area]")

/datum/event/swarmers/proc/spawn_portal(location)
	new /obj/effect/swarmer_portal(location)

/obj/effect/swarmer_portal
	// Swarmer Portal
	name = "Swarmer Portal"
	desc = "A shimmering portal, crackling and humming with live electricity."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	light_range = 4

	/// How many can we spawn
	var/spawn_max = 1
	/// How many have spawned?
	var/spawn_total = 0

/obj/effect/swarmer_portal/Initialize(mapload)
	. = ..()
	spawn_max = max(length(GLOB.crew_list) / 10, 1)
	addtimer(CALLBACK(src, PROC_REF(spawn_next_swarmer)), 2 SECONDS)

/obj/effect/swarmer_portal/proc/spawn_next_swarmer()
	if(spawn_total < spawn_max)
		make_mob(/mob/living/basic/swarmer)
		addtimer(CALLBACK(src, PROC_REF(spawn_next_swarmer)), 2 SECONDS)
	else
		qdel(src)

/obj/effect/swarmer_portal/proc/make_mob(mob_type)
	var/mob/M = new mob_type(get_turf(src))
	M.faction = list("swarmer")
	spawn_total++
	do_sparks(5, TRUE, src)
	step(M, pick(GLOB.cardinal))
