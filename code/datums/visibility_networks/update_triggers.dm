//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	if(ticker)
		updateVisibilityNetworks(src)

/turf/simulated/Del()
	visibilityChanged()
	..()

/turf/simulated/New()
	..()
	visibilityChanged()



// STRUCTURES

/obj/structure/Del()
	if(ticker)
		updateVisibilityNetworks(src)
	..()

/obj/structure/New()
	..()
	if(ticker)
		updateVisibilityNetworks(src)

// EFFECTS

/obj/effect/Del()
	if(ticker)
		updateVisibilityNetworks(src)
	..()

/obj/effect/New()
	..()
	if(ticker)
		updateVisibilityNetworks(src)


// DOORS

// Simply updates the visibility of the area when it opens/closes/destroyed.
/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)

	if(!glass)
		updateVisibilityNetworks(src,0)

	if(!air_master)
		return 0

	for(var/turf/simulated/turf in locs)
		update_heat_protection(turf)
		air_master.mark_for_update(turf)

	return 1



#define UPDATE_VISIBILITY_NETWORK_BUFFER 30

/mob
	var/datum/visibility_network/list/visibilityNetworks=list()
	var/updatingVisibilityNetworks=FALSE

/mob/Move(n,direct)
	var/oldLoc = src.loc
	//. = ..()
	if(..(n,direct))
		if(src.visibilityNetworks.len)
			if(!src.updatingVisibilityNetworks)
				src.updatingVisibilityNetworks = 1
				spawn(UPDATE_VISIBILITY_NETWORK_BUFFER)
					if(oldLoc != src.loc)
						for (var/datum/visibility_network/currentNetwork in src.visibilityNetworks)
							currentNetwork.updateMob(src)
					src.updatingVisibilityNetworks = 0
	return .

/mob/proc/addToVisibilityNetwork(var/datum/visibility_network/network)
	if(network)
		src.visibilityNetworks+=network

/mob/proc/removeFromVisibilityNetwork(var/datum/visibility_network/network)
	if(network)
		src.visibilityNetworks|=network

#undef UPDATE_VISIBILITY_NETWORK_BUFFER