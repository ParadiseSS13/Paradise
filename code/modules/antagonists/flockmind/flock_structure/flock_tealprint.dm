/obj/structure/flock/tealprint
	name = "weird lookin ghost building"
	desc = "It's some weird looking ghost building. Seems like its under construction, You can see faint strands of material floating in it."

	density = FALSE
	no_flock_decon = TRUE

	flock_id = "Construction Tealprint" // if you change this update Flockpanel.tsx!!!!!

	var/datum/point_holder/tealprint/substrate

	var/obj/structure/flock/building_type = null

/obj/structure/flock/tealprint/Initialize(mapload, datum/flock/join_flock, obj/structure/flock/desired_type)
	. = ..()
	var/turf/T = loc
	if(!T.can_flock_occupy(src))
		return INITIALIZE_HINT_QDEL

	SET_TRACKING(type)

	building_type = desired_type
	icon = initial(building_type.icon)
	icon_state = initial(building_type.icon_state)
	alpha = 104

	substrate = new()
	substrate.set_max_points(initial(desired_type.resource_cost))
	substrate.owner = src

/obj/structure/flock/tealprint/Destroy()
	UNSET_TRACKING(type)
	QDEL_NULL(substrate)
	return ..()

/obj/structure/flock/tealprint/update_info_tag()
	info_tag?.set_text("Substrate: [substrate.has_points()] / [substrate.get_max_points()]")

/obj/structure/flock/tealprint/flock_structure_examine(mob/user)
	return list(
		span_flocksay("<b>Construction Percentage:</b> [floor(substrate.has_points() / substrate.get_max_points() * 100)]"),
		span_flocksay("<b>Construction Progress:</b> [substrate.has_points()] added, [substrate.get_max_points()] needed")
	)

/// Complete the structure.
/obj/structure/flock/tealprint/proc/complete_structure()
	var/obj/structure/flock/structure = new building_type(get_turf(src))
	flock_talk(src, "Tealprint for [structure.flock_id] realized.", flock, involuntary = TRUE)
	qdel(src)

/// Attempt to cancel the construction, spitting out the substrate. Some structures cannot be cancelled.
/obj/structure/flock/tealprint/proc/try_cancel_structure()
	if(!initial(building_type.cancellable))
		return FALSE

	if(substrate.has_points())
		var/obj/item/flock_cube/cube = new(drop_location())
		cube.substrate = substrate.has_points()

	flock_talk(src, "Tealprint dematerializing", flock, involuntary = TRUE)
	playsound(src, 'goon/sounds/flockmind/flockdrone_door_deny.ogg', 30, TRUE, extrarange = -10)
	qdel(src)
	return TRUE

/datum/point_holder/tealprint
	var/obj/structure/flock/tealprint/owner

/datum/point_holder/tealprint/Destroy(force, ...)
	owner = null
	return ..()

/datum/point_holder/tealprint/add_points(num)
	. = ..()
	if(.)
		if(is_full())
			owner.complete_structure()
		else
			owner.update_info_tag()
