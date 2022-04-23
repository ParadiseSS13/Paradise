// Dimensional Tear - A rift appears randomly on the station, does the following:
// Flickers nearby machines as an early warning.
// After a few seconds, it breaks nearby computers and mirrors.
// A portal appears, then it spawns a few hostile mobs, and a leader one.
// Then the portal deletes itself.

// Event setup
/datum/event/tear
	name = "dimensional tear"
	announceWhen = 6
	endWhen = 10
	var/obj/effect/tear/TE

/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/animal.dmi', "hellhound")
		notify_ghosts("\A [src] is about to open in [get_area(T)].", title = "Dimensional Rift", source = T, alert_overlay = alert_overlay, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, .proc/spawn_tear, T), 4 SECONDS)

		// Energy overload; we mess with machines as an early warning and for extra spookiness.
		for(var/obj/machinery/M in range(8, T))
			INVOKE_ASYNC(M, /atom/.proc/get_spooked)

/datum/event/tear/proc/spawn_tear(location)
	TE = new /obj/effect/tear(location)

/datum/event/tear/announce()
	GLOB.event_announcement.Announce("A tear in the fabric of space and time has opened. Expected location: [impact_area.name].", "Anomaly Alert", 'sound/AI/anomaly.ogg')

/datum/event/tear/end()
	if(TE)
		qdel(TE)

// The portal
/obj/effect/tear
	name = "dimensional tear"
	desc = "A tear in the dimensional fabric of space and time."
	icon = 'icons/effects/tear.dmi'
	icon_state = "tear"
	light_range = 3

	// Huge sprite, we shift it to make it look more natural.
	pixel_x = -106
	pixel_y = -96

/obj/effect/tear/Initialize(mapload)
	. = ..()
	// Sound cue to warn people nearby.
	playsound(get_turf(src), 'sound/magic/drum_heartbeat.ogg', 100)

	// Portal opening animation.
	var/atom/movable/overlay/animation = new(loc)
	animation.pixel_x = pixel_x
	animation.pixel_y = pixel_y
	animation.icon_state = "newtear"
	animation.icon = 'icons/effects/tear.dmi'
	animation.master = src
	QDEL_IN(animation, 1.5 SECONDS)

	// We spawn the minions first, then the boss.
	addtimer(CALLBACK(src, .proc/spawn_mobs), 2 SECONDS)
	addtimer(CALLBACK(src, .proc/spawn_leader), 5 SECONDS)

/obj/effect/tear/proc/spawn_mobs()
	var/list/possible_mobs = list(
		/mob/living/simple_animal/hostile/netherworld,
		/mob/living/simple_animal/hostile/netherworld/migo,
		/mob/living/simple_animal/hostile/faithless)

	// We break some of those flickering consoles from earlier.
	// Mirrors as well, for the extra bad luck.
	for(var/obj/machinery/computer/C in range(6, src))
		C.obj_break()
	for(var/obj/structure/mirror/M in range(6, src))
		M.obj_break()

	// Spawning mobs.
	for(var/i in 1 to 5)
		var/chosen_mob = pick(possible_mobs)
		var/mob/M = new chosen_mob(loc)
		M.faction = list("rift")
		step(M, pick(GLOB.cardinal))

// We spawn a leader mob to make the portal actually dangerous.
/obj/effect/tear/proc/spawn_leader()
	var/mob/M = new /mob/living/simple_animal/hostile/hellhound/tear(get_turf(src))
	playsound(M, 'sound/goonstation/voice/growl2.ogg', 100)
	visible_message("<span class='danger'>With a terrifying growl, \a [M] steps out of the portal!</span>")
