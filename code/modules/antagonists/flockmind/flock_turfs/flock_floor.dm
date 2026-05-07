/turf/simulated/floor/flock
	name = "weird floor"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "floor"
	base_icon_state = "floor"

	light_color = "#19b299"
	light_power = 0.4
	light_range = 4

	var/is_on = FALSE

	/// List of mobs flockrunning on this turf, lazylist.
	var/list/mob/living/basic/flock/flockrunning_mobs
	/// List of pylons powering this turf, lazylist.
	var/list/obj/structure/flock/collector/connected_pylons

/turf/simulated/floor/flock/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)

/turf/simulated/floor/flock/Destroy(force)
	REMOVE_TRAIT(src, TRAIT_FLOCK_NODECON, INNATE_TRAIT) // Turfs dont disappear!!!
	qdel(GetComponent(/datum/component/flock_protection))
	connected_pylons = null

	for(var/mob/living/basic/flock/drone/bird in flockrunning_mobs)
		if(HAS_TRAIT(bird, TRAIT_FLOCKPHASE))
			bird.stop_flockphase(TRUE)

	flockrunning_mobs = null
	return ..()

/turf/simulated/floor/flock/get_flock_id()
	return "Conduit"

/turf/simulated/floor/flock/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return FALSE

/turf/simulated/floor/flock/burn_tile()
	return

/turf/simulated/floor/flock/update_icon_state()
	if(broken)
		icon_state = "[base_icon_state]-broken"
	else
		if(is_on)
			icon_state = "[base_icon_state]-on"
		else
			icon_state = base_icon_state
	return ..()

/// Turns the tile on or off depending on what state it should be in.
/turf/simulated/floor/flock/proc/update_power()
	var/should_be_on = FALSE
	if(!broken && (length(connected_pylons) || length(flockrunning_mobs)))
		should_be_on = TRUE

	if(should_be_on == is_on)
		return

	is_on = should_be_on
	if(is_on)
		light_range = 4
	else
		light_range = 0
	update_appearance(UPDATE_ICON_STATE)
