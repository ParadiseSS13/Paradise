// Loosely inspired by the /tg/ augury subsystem, without the need for a full subsystem

// Creates the thing
/datum/augury
	/// The atom being followed
	var/atom/movable/follow_target
	/// The atoms following it
	var/list/followers
	var/alert_UID


/datum/augury/New(atom/movable/follow_target, list/starting_followers = null)
	. = ..()
	followers = starting_followers
	src.follow_target = follow_target
	change_targets(follow_target)

	for(var/mob/dead/observer/O in GLOB.player_list)

/datum/augury/Destroy(force, ...)
	for(var/atom/movable/follower in followers)  // in case something was nulled
		follower.stop_orbit()

	followers = null
	if(follow_target)
		UnregisterSignal(follow_target, COMSIG_ATOM_ORBIT_STOP)
	follow_target = null

	return ..()

/// Executed when the parent is deleted.
/// Don't immediately kill ourselves, since it's possible that we might want to move somewhere else
/// (for example, after a meteor strike)
/datum/augury/proc/on_following_qdel(atom/movable/A)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	for(var/atom/movable/follower in followers)
		follower.stop_orbit()

	follow_target = null

/datum/augury/proc/change_targets(atom/movable/next_to)
	// unregister first so we aren't bombarded when changing orbits
	if(follow_target)
		UnregisterSignal(follow_target, COMSIG_ATOM_ORBIT_STOP)
	follow_target = next_to
	RegisterSignal(follow_target, COMSIG_ATOM_ORBIT_STOP, PROC_REF(remove_follower_on_stop_orbit))
	for(var/atom/movable/M in followers)
		M.orbit(follow_target)

/datum/augury/proc/add_follower(atom/movable/follower)
	followers |= follower
	follower.orbit(follow_target)

/datum/augury/proc/remove_follower(atom/movable/follower)
	followers -= follower
	follower.stop_orbit()

/// Called when someone stops orbiting our followed object, so they can actually escape
/datum/augury/proc/remove_follower_on_stop_orbit(atom/movable/followed, atom/movable/follower)
	SIGNAL_HANDLER  // COMSIG_ATOM_ORBIT_STOP
	remove_follower(follower)


/// The alert for following
/obj/screen/alert/augury
	title = "Something interesting"
	desc = "Click to follow"
	var/datum/augury/source


/obj/screen/alert/augury/Initialize(mapload, title, desc, datum/augury/source, image/alert_overlay, timeout)
	. = ..()
	src.source = source
	src.title = title
	src.desc = desc

	if(!alert_overlay)
		var/old_layer = source.layer
		var/old_plane = source.plane
		source.layer = FLOAT_LAYER
		source.plane = FLOAT_PLANE
		A.overlays += source
		source.layer = old_layer
		source.plane = old_plane
	else
		alert_overlay.layer = FLOAT_LAYER
		alert_overlay.plane = FLOAT_PLANE
		A.overlays += alert_overlay

/obj/screen/alert/augury/Click(location, control, params)
	. = ..()
	if(!usr || !usr.client || !isobserver(usr))
		return

	owner.add_follower(usr)

