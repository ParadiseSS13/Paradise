/atom/movable/screen/alert/augury
	name = "Something interesting!"
	desc = "Click to follow."
	/// The atom being followed
	var/atom/movable/follow_target
	/// The atoms following it
	var/list/followers = list()
	/// Queue of next atoms to follow
	var/list/next_targets = list()
	/// Title for the thing that will be followed.
	var/thing_followed = "debris"
	/// After a followed item is qdeleted, wait this long before switching to the next target, allowing you to see aftermath.
	var/time_between_switches = 1 SECONDS

/**
 * Create a new augury alert.
 *
 * Arguments:
 * * follow_target: The atom to start out following. Can be null, in which case change_targets() should be used at some point.
 * * alert_overlay_override: If follow_target is provided (or not), use this for the alert image.
 */
/atom/movable/screen/alert/augury/Initialize(mapload, atom/movable/follow_target, image/alert_overlay_override)
	. = ..()
	src.follow_target = follow_target

	if(!alert_overlay_override && follow_target)
		var/image/source = image(follow_target)
		var/old_layer = source.layer
		var/old_plane = source.plane
		source.layer = FLOAT_LAYER
		source.plane = FLOAT_PLANE
		overlays += source
		source.layer = old_layer
		source.plane = old_plane
	else if(alert_overlay_override)
		alert_overlay_override.layer = FLOAT_LAYER
		alert_overlay_override.plane = FLOAT_PLANE
		overlays += alert_overlay_override

/atom/movable/screen/alert/augury/Click(location, control, params)
	. = ..()
	if(!usr || !usr.client || !isobserver(usr))
		return
	if(usr in followers)
		to_chat(usr, "<span class='notice'>You will now not auto-follow [thing_followed].</span>")
		remove_follower(usr)
	else
		to_chat(usr, "<span class='notice'>You are now auto-following [thing_followed]. Click again to stop.</span>")
		add_follower(usr)

/atom/movable/screen/alert/augury/Destroy(force)
	for(var/atom/movable/follower in followers)  // in case something was nulled
		follower.stop_orbit()

	followers = null

	for(var/atom/movable/target in next_targets)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	next_targets = null

	if(follow_target)
		UnregisterSignal(follow_target, COMSIG_ATOM_ORBIT_STOP)
		UnregisterSignal(follow_target, COMSIG_PARENT_QDELETING)
	follow_target = null

	return ..()

/// Executed when the parent is deleted.
/// Don't immediately kill ourselves, since it's possible that we might want to move somewhere else
/// (for example, after a meteor strike)
/atom/movable/screen/alert/augury/proc/on_following_qdel(atom/movable/A)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	for(var/atom/movable/follower in followers)
		follower.stop_orbit()

	follow_target = get_next_target()
	if(follow_target)
		if(time_between_switches > 0)
			addtimer(CALLBACK(src, PROC_REF(change_targets), follow_target), time_between_switches)  // add a second so people can see what exploded
		else
			change_targets(follow_target)

/**
 * Change the atom that everyone is currently following, moving everyone to the new object.
 *
 * Arguments:
 * * next_to - The next atom to follow.
 */
/atom/movable/screen/alert/augury/proc/change_targets(atom/movable/next_to)
	// unregister first so we aren't bombarded when changing orbits
	if(isnull(next_to))
		return
	if(follow_target)
		UnregisterSignal(follow_target, COMSIG_ATOM_ORBIT_STOP)
		UnregisterSignal(follow_target, COMSIG_PARENT_QDELETING)
	follow_target = next_to
	RegisterSignal(follow_target, COMSIG_PARENT_QDELETING, PROC_REF(on_following_qdel), override = TRUE)  // override our qdeleting signal
	for(var/atom/movable/M in followers)
		M.orbit(follow_target)

	RegisterSignal(follow_target, COMSIG_ATOM_ORBIT_STOP, PROC_REF(remove_follower_on_stop_orbit))

/atom/movable/screen/alert/augury/proc/add_follower(atom/movable/follower)
	followers |= follower
	follower.orbit(follow_target)

/atom/movable/screen/alert/augury/proc/remove_follower(atom/movable/follower)
	followers -= follower
	follower.stop_orbit()

/atom/movable/screen/alert/augury/proc/get_next_target()
	if(!length(next_targets))
		return

	var/atom/movable/target

	while(QDELETED(target) && length(next_targets))
		target = next_targets[length(next_targets)]  // pop the (hopefully most recent)
		next_targets.Remove(target)

	return target

/// Called when someone stops orbiting our followed object, so they can actually get out of the loop.
/atom/movable/screen/alert/augury/proc/remove_follower_on_stop_orbit(atom/movable/followed, atom/movable/follower)
	SIGNAL_HANDLER  // COMSIG_ATOM_ORBIT_STOP
	if(locateUID(follower.orbiting_uid) != follow_target)
		remove_follower(follower)  // don't try to stop the orbit again

/// Meteor alert.
/// Appears during a meteor storm and allows for auto-following of debris.
/atom/movable/screen/alert/augury/meteor
	name = "Meteors incoming!"
	desc = "Click to automatically follow debris, and click again to stop."

/atom/movable/screen/alert/augury/meteor/Initialize(mapload)
	var/image/meteor_img = image(icon = 'icons/obj/meteor.dmi', icon_state = "flaming")
	. = ..(mapload, alert_overlay_override = meteor_img)
	START_PROCESSING(SSfastprocess, src)

/atom/movable/screen/alert/augury/meteor/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/atom/movable/screen/alert/augury/meteor/process()
	var/overridden = FALSE
	for(var/obj/effect/meteor/M in GLOB.meteor_list)
		if(istype(M, /obj/effect/meteor/fake))
			continue  // Meteor? What meteor?
		if(!is_station_level(M.z))
			continue  // don't worry about endlessly looping
		if(istype(M, /obj/effect/meteor/tunguska) && !overridden)
			if(M != follow_target)  // keep following it, but don't force an orbit change
				change_targets(M)  // TUNGUSKAAAAAAA
			overridden = TRUE
			continue
		if(!(M in next_targets))
			next_targets.Add(M)

	if(QDELETED(follow_target) && length(next_targets) && !overridden)
		change_targets(get_next_target())
