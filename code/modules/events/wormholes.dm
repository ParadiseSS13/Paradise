/datum/event/wormholes
	announceWhen 			= 10
	endWhen 				= 60

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 400

/datum/event/wormholes/setup()
	announceWhen = rand(0, 20)
	endWhen = rand(40, 80)

/datum/event/wormholes/start()
	for(var/turf/simulated/floor/T in world)
		if(is_station_level(T.z))
			pick_turfs += T

	for(var/i in 1 to number_of_wormholes)
		var/turf/T = pick(pick_turfs)
		wormholes += new /obj/effect/portal/wormhole(T, null, null, -1)

/datum/event/wormholes/announce()
	GLOB.minor_announcement.Announce("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert", new_sound = 'sound/AI/spanomalies.ogg')

/datum/event/wormholes/tick()
	if(activeFor % shift_frequency == 0)
		for(var/obj/effect/portal/wormhole/O in wormholes)
			var/turf/T = pick(pick_turfs)
			if(T)	O.loc = T

/datum/event/wormholes/end()
	for(var/obj/effect/portal/wormhole/O in wormholes)
		qdel(O)
	wormholes.Cut()

/obj/effect/portal/wormhole
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	failchance = 0

/obj/effect/portal/wormhole/can_teleport(atom/movable/M)
	. = ..()

	if(istype(M, /obj/singularity) || istype(M, /obj/structure/transit_tube_pod))
		. = FALSE

/obj/effect/portal/wormhole/teleport(atom/movable/M)
	if(!can_teleport(M))
		return FALSE

	var/turf/target
	if(GLOB.portals.len)
		var/obj/effect/portal/P = pick(GLOB.portals)
		if(P && isturf(P.loc))
			target = P.loc

	if(!target)
		return FALSE

	if(!do_teleport(M, target, 1, TRUE)) ///You will appear adjacent to the beacon
		return FALSE

	return TRUE
