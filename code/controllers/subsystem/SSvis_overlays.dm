/**
  * # SSvis_overlays
  *
  * This subsystem handles visual overlays for objects in the game world.
  *
  * It manages the creation, caching, and removal of visual overlays, allowing for dynamic visual effects
  * associated with various atoms. Overlays can be reused if they are not unique, and they are automatically
  * cleaned up if they go unused for a specified duration.
  */
SUBSYSTEM_DEF(vis_overlays)
	name = "Vis contents overlays"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_VIS
	init_order = INIT_ORDER_VIS

	/// Cache for visual overlays
	var/list/vis_overlay_cache
	/// List of currently processed overlays during a run
	var/list/currentrun

/datum/controller/subsystem/vis_overlays/Initialize()
	vis_overlay_cache = list()

/datum/controller/subsystem/vis_overlays/fire(resumed = FALSE)
	if(!resumed)
		currentrun = vis_overlay_cache.Copy()
	var/list/current_run = currentrun

	while(length(current_run))
		var/key = current_run[current_run.len]
		var/obj/effect/overlay/vis/overlay = current_run[key]
		current_run.len--
		if(!overlay.unused && !length(overlay.vis_locs))
			overlay.unused = world.time
		else if(overlay.unused && overlay.unused + overlay.cache_expiration < world.time)
			vis_overlay_cache -= key
			qdel(overlay)
		if(MC_TICK_CHECK)
			return

/**
  * Adds a visual overlay to a given atom.
  *
  * This procedure creates and adds a visual overlay to the specified object. It can either create a unique
  * overlay or reuse an existing one based on the provided parameters.
  *
  * Arguments:
  * * thing - The atom to which the overlay will be added. The "thing" var can be anything with vis_contents which includes images
  * * icon - The icon to display for the overlay.
  * * iconstate - The state of the icon.
  * * layer - The layer on which the overlay will be rendered.
  * * plane - The plane for the overlay.
  * * dir - The direction the overlay faces.
  * * alpha - The transparency level of the overlay (default is 255).
  * * add_appearance_flags - Additional flags for overlay appearance (default is NONE).
  * * unique - A boolean indicating if the overlay should be unique (default is FALSE).
  *
  * Returns the overlay that was added.
  */
/datum/controller/subsystem/vis_overlays/proc/add_vis_overlay(atom/movable/thing, icon, iconstate, layer, plane, dir, alpha = 255, add_appearance_flags = NONE, unique = FALSE)
	var/obj/effect/overlay/vis/overlay
	if(!unique)
		. = "[icon]|[iconstate]|[layer]|[plane]|[dir]|[alpha]|[add_appearance_flags]"
		overlay = vis_overlay_cache[.]
		if(!overlay)
			overlay = _create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, add_appearance_flags)
			vis_overlay_cache[.] = overlay
		else
			overlay.unused = 0
	else
		overlay = _create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, add_appearance_flags)
		overlay.cache_expiration = -1
		var/cache_id = "[text_ref(overlay)]@{[world.time]}"
		vis_overlay_cache[cache_id] = overlay
		. = overlay
	thing.vis_contents += overlay

	if(!isatom(thing)) // Automatic rotation is not supported on non atoms
		return overlay

	if(!thing.managed_vis_overlays)
		thing.managed_vis_overlays = list(overlay)
	else
		thing.managed_vis_overlays += overlay
	return overlay

/**
  * Creates a new visual overlay with the specified parameters.
  *
  * This procedure initializes a new visual overlay object with the given attributes.
  *
  * Arguments:
  * * icon - The icon to display for the overlay.
  * * iconstate - The state of the icon.
  * * layer - The layer on which the overlay will be rendered.
  * * plane - The plane for the overlay.
  * * dir - The direction the overlay faces.
  * * alpha - The transparency level of the overlay.
  * * add_appearance_flags - Additional flags for overlay appearance.
  *
  * Returns the newly created overlay.
  */
/datum/controller/subsystem/vis_overlays/proc/_create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, add_appearance_flags)
	var/obj/effect/overlay/vis/overlay = new
	overlay.icon = icon
	overlay.icon_state = iconstate
	overlay.layer = layer
	overlay.plane = plane
	overlay.dir = dir
	overlay.alpha = alpha
	overlay.appearance_flags |= add_appearance_flags
	return overlay

/**
  * Removes specified visual overlays from an atom.
  *
  * This procedure removes the given overlays from the atom's visual contents and also updates the
  * managed overlays list if applicable.
  *
  * Arguments:
  * * thing - The atom from which the overlays will be removed.
  * * overlays - A list of overlays to remove.
  */
/datum/controller/subsystem/vis_overlays/proc/remove_vis_overlay(atom/movable/thing, list/overlays)
	thing.vis_contents -= overlays
	if(!isatom(thing))
		return
	thing.managed_vis_overlays -= overlays
	if(!length(thing.managed_vis_overlays))
		thing.managed_vis_overlays = null
