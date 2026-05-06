/datum/action/cooldown/flock/create_rift
	name = "Spawn Rift"
	desc = "Spawn an rift where you are, and from there, begin."
	button_icon_state = "spawn_egg"

/datum/action/cooldown/flock/create_rift/is_valid_target(atom/cast_on)
	var/turf/T = get_turf(owner)
	if(!is_safe_turf(T))
		to_chat(owner, span_warning("This place is not safe enough for a rift."))
		return FALSE

	if(T.contains_dense_objects())
		to_chat(owner, span_warning("There is not enough room for a rift here."))
		return FALSE

	var/area/A = T.loc
	if(!(A.area_flags & BLOBS_ALLOWED))
		to_chat(owner, span_warning("We cannot create a rift here."))
		return FALSE

	if(!T.can_flock_occupy())
		to_chat(owner, span_warning("There is something blocking this spot."))
		return FALSE

	return TRUE

/datum/action/cooldown/flock/create_rift/Activate(atom/target)
	. = ..()

	var/turf/T = get_turf(owner)
	if(tgui_alert(owner, "Would you like to create the rift on [T]?", "Spawn Rift", list("Yes", "No")) != "Yes")
		return

	var/mob/camera/flock/overmind/ghost_bird = owner
	ghost_bird.spawn_rift(T)

