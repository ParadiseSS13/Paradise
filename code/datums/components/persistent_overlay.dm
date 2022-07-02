/datum/component/persistent_overlay
	var/image/persistent_overlay = null

/datum/component/persistent_overlay/Initialize(image_overlay)
	persistent_overlay = image_overlay
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/add_persistent_overlay)
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/remove_persistent_overlay)
	add_persistent_overlay()

/datum/component/persistent_overlay/proc/remove_persistent_overlay(datum/source)
	var/atom/movable/A = parent
	A.cut_overlay(persistent_overlay)
	qdel(src)

/datum/component/persistent_overlay/proc/add_persistent_overlay(datum/source)
	var/atom/movable/A = parent
	A.add_overlay(persistent_overlay)
