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
	var/notify_title = "Dimensional Rift"
	var/notify_image = "hellhound"

	var/obj/effect/tear/TE

/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/animal.dmi', notify_image)
		notify_ghosts("\A [src] is about to open in [get_area(T)].", title = notify_title, source = T, alert_overlay = alert_overlay, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, PROC_REF(spawn_tear), T), 4 SECONDS)

		// Energy overload; we mess with machines as an early warning and for extra spookiness.
		for(var/obj/machinery/M in range(8, T))
			INVOKE_ASYNC(M, TYPE_PROC_REF(/atom, get_spooked))

/datum/event/tear/proc/spawn_tear(location)
	TE = new /obj/effect/tear(location)

/datum/event/tear/announce()
	GLOB.minor_announcement.Announce("A tear in the fabric of space and time has opened. Expected location: [impact_area.name].", "Anomaly Alert", 'sound/AI/anomaly.ogg')

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
	/// What the leader of the dimensional tear will be
	var/leader = /mob/living/simple_animal/hostile/hellhound/tear
	var/list/possible_mobs = list(
		/mob/living/simple_animal/hostile/netherworld,
		/mob/living/simple_animal/hostile/netherworld/migo,
		/mob/living/simple_animal/hostile/faithless)

/obj/effect/tear/Initialize(mapload)
	. = ..()
	// Sound cue to warn people nearby.
	playsound(get_turf(src), 'sound/magic/drum_heartbeat.ogg', 100)

	// We spawn the minions first, then the boss.
	addtimer(CALLBACK(src, PROC_REF(spawn_mobs)), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(spawn_leader)), 5 SECONDS)

/obj/effect/tear/proc/spawn_mobs()
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
	if(!leader)
		return
	var/mob/M = new leader(get_turf(src))
	playsound(M, 'sound/goonstation/voice/growl2.ogg', 100)
	visible_message("<span class='danger'>With a terrifying growl, \a [M] steps out of the portal!</span>")
