/datum/component/plastic_explosive
	var/image/plastic_overlay = null

/datum/component/plastic_explosive/Initialize(image_overlay)
	plastic_overlay = image_overlay
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/add_plastic_overlay)

/datum/component/plastic_explosive/proc/add_plastic_overlay(datum/source)
	var/atom/movable/A = parent
	A.add_overlay(plastic_overlay)
