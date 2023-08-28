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
	var/list/stations_z = levels_by_trait(STATION_LEVEL)
	if(!length(stations_z))
		return

	var/list/station_turfs = block(locate(1, 1, stations_z[1]), locate(world.maxx, world.maxy, stations_z[1]))
	for(var/turf/simulated/floor/new_turf in station_turfs)
		pick_turfs |= new_turf

	var/list/temp_turfs = pick_turfs.Copy()
	for(var/i in 1 to number_of_wormholes)
		var/turf/anomaly_turf = pick_n_take(temp_turfs)
		if(anomaly_turf)
			wormholes.Add(new /obj/effect/portal/wormhole(anomaly_turf, null, null, -1, wormholes))


/datum/event/wormholes/announce()
	GLOB.event_announcement.Announce("Зафиксированы пространственно-временные аномалии на борту станции. Дополнительная информация отсутствует.", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.", new_sound = 'sound/AI/spanomalies.ogg')


/datum/event/wormholes/tick()
	if(activeFor % shift_frequency == 0)
		var/list/temp_turfs = pick_turfs.Copy()
		for(var/obj/effect/portal/wormhole/wormhole in wormholes)
			var/turf/anomaly_turf = pick_n_take(temp_turfs)
			if(anomaly_turf)
				wormhole.forceMove(anomaly_turf)


/datum/event/wormholes/end()
	QDEL_LIST(wormholes)


/obj/effect/portal/wormhole
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	failchance = 0
	var/list/linked_portals


/obj/effect/portal/wormhole/New(loc, turf/target, creator = null, lifespan = 300, list/link_portals)
	..()

	linked_portals = link_portals


/obj/effect/portal/wormhole/can_teleport(atom/movable/M)
	. = ..()

	if(istype(M, /obj/singularity))
		. = FALSE


/obj/effect/portal/wormhole/teleport(atom/movable/M)
	if(!can_teleport(M))
		return FALSE

	var/turf/target
	if(length(linked_portals))
		var/obj/effect/portal/P = pick(linked_portals)
		if(P && isturf(P.loc))
			target = P.loc

	if(!target)
		return FALSE

	if(!do_teleport(M, target, 1, TRUE)) ///You will appear adjacent to the beacon
		return FALSE

	return TRUE
