/**
 * Dimensional tear event.
 *
 * On triggering, nearby machines and lights flicker. After a few seconds,
 * nearby machines and lights break. A [/obj/effect/tear] appears, spawning up
 * to 10 random hell mobs including a guaranteed tear hellhound, then disappears.
 */
/datum/event/tear
	name = "dimensional tear"
	announceWhen = 6
	endWhen = 14
	var/notify_title = "Dimensional Rift"
	var/notify_image = "hellhound"

	var/obj/effect/tear/TE

/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/start()
	if(isnull(impact_area))
		log_debug("No valid event areas could be generated for dimensional tear.")
	var/list/area_turfs = get_area_turfs(impact_area)
	while(length(area_turfs))
		var/turf/T = pick_n_take(area_turfs)
		if(T.is_blocked_turf())
			continue

		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/animal.dmi', notify_image)
		notify_ghosts("\A [src] is about to open in [get_area(T)].", title = notify_title, source = T, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, PROC_REF(spawn_tear), T), 4 SECONDS)

		// Energy overload; we mess with machines as an early warning and for extra spookiness.
		for(var/obj/machinery/M in range(8, T))
			INVOKE_ASYNC(M, TYPE_PROC_REF(/atom, get_spooked))

		return

	log_debug("dimensional tear failed to find a valid turf in [impact_area]")

/datum/event/tear/proc/spawn_tear(location)
	TE = new /obj/effect/tear(location)

/datum/event/tear/announce(false_alarm)
	var/area/target_area = impact_area
	if(!target_area)
		if(false_alarm)
			target_area = findEventArea()
			if(isnull(target_area))
				log_debug("Tried to announce a false-alarm tear without a valid area!")
				kill()
		else
			log_debug("Tried to announce a tear without a valid area!")
			kill()
			return

	GLOB.minor_announcement.Announce("A tear in the fabric of space and time has opened. Expected location: [target_area.name].", "Anomaly Alert", 'sound/AI/anomaly.ogg')

/datum/event/tear/end()
	if(TE)
		qdel(TE)

/// The portal used in the [/datum/event/tear] midround.
/obj/effect/tear
	name = "dimensional tear"
	desc = "A tear in the dimensional fabric of space and time."
	icon = 'icons/effects/tear.dmi'
	icon_state = "tear"
	light_range = 3

	// Huge sprite, we shift it to make it look more natural.
	pixel_x = -106
	pixel_y = -96
	/// What the leader of the dimensional tear will be
	var/leader = /mob/living/basic/hellhound/tear
	var/spawn_max = 0
	var/spawn_total = 0
	var/list/possible_mobs = list(
		/mob/living/basic/hellhound,
		/mob/living/basic/skeleton,
		/mob/living/basic/netherworld/,
		/mob/living/basic/netherworld/migo,
		/mob/living/basic/netherworld/faithless)

/obj/effect/tear/Initialize(mapload)
	. = ..()
	spawn_max = roll(6) + 3
	warn_environment()
	addtimer(CALLBACK(src, PROC_REF(spawn_next_mob)), 2 SECONDS)

/obj/effect/tear/proc/warn_environment()
	// Sound cue to warn people nearby.
	playsound(get_turf(src), 'sound/magic/drum_heartbeat.ogg', 100)

	// We break some of those flickering consoles from earlier.
	// Mirrors as well, for the extra bad luck.
	for(var/obj/machinery/computer/C in range(6, src))
		C.obj_break()
	for(var/obj/structure/mirror/M in range(6, src))
		M.obj_break()
	for(var/obj/machinery/light/L in range(4, src))
		L.break_light_tube()

// We spawn a leader mob to make the portal actually dangerous.
/obj/effect/tear/proc/spawn_leader()
	if(!leader)
		return
	var/mob/M = new leader(get_turf(src))
	M.faction = list("rift")
	playsound(M, 'sound/goonstation/voice/growl2.ogg', 100)
	visible_message("<span class='danger'>With a terrifying growl, \a [M] steps out of the portal!</span>")

/obj/effect/tear/proc/spawn_next_mob()
	spawn_total++

	if(spawn_total < spawn_max)
		make_mob(pick(possible_mobs))
		addtimer(CALLBACK(src, PROC_REF(spawn_next_mob)), 2 SECONDS)
	else
		spawn_leader()

/obj/effect/tear/proc/make_mob(mob_type)
	var/mob/M = new mob_type(get_turf(src))
	M.faction = list("rift")
	step(M, pick(GLOB.cardinal))
	if(prob(30))
		visible_message("<span class='danger'>[M] steps out of the portal!</span>")
