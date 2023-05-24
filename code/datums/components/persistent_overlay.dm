/datum/component/persistent_overlay
	var/image/persistent_overlay = null
	var/atom/target = null

/datum/component/persistent_overlay/Initialize(image_overlay, _target, timer)
	persistent_overlay = image_overlay
	target = _target
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(remove_persistent_overlay)), timer)
	if(target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_persistent_overlay))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_persistent_overlay))
	add_persistent_overlay()

/datum/component/persistent_overlay/Destroy()
	persistent_overlay = null
	target = null
	return ..()

/datum/component/persistent_overlay/proc/remove_persistent_overlay(datum/source)
	var/atom/movable/A
	if(target)
		A = target
	else
		A = parent
	A.cut_overlay(persistent_overlay, priority = TRUE)
	qdel(src)

/datum/component/persistent_overlay/proc/add_persistent_overlay(datum/source)
	var/atom/movable/A
	if(target)
		A = target
	else
		A = parent
	A.add_overlay(persistent_overlay, priority = TRUE)
