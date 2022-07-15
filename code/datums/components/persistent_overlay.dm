/datum/component/persistent_overlay
	var/image/persistent_overlay = null

/datum/component/persistent_overlay/Initialize(image_overlay, timer)
	persistent_overlay = image_overlay
	if(timer)
		addtimer(CALLBACK(src, .proc/remove_persistent_overlay), timer)
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/remove_persistent_overlay)
	add_persistent_overlay()

/datum/component/persistent_overlay/Destroy()
	persistent_overlay = null
	return ..()

/datum/component/persistent_overlay/proc/remove_persistent_overlay(datum/source)
	var/atom/movable/A = parent
	A.cut_overlay(persistent_overlay, priority = TRUE)
	qdel(src)

/datum/component/persistent_overlay/proc/add_persistent_overlay(datum/source)
	var/atom/movable/A = parent
	A.add_overlay(persistent_overlay, priority = TRUE)
