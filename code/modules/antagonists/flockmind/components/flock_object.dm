/datum/component/flock_object

/datum/component/flock_object/Initialize(...)
	. = ..()

	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/flock_object/RegisterWithParent()
	. = ..()
	ADD_TRAIT(parent, TRAIT_FLOCK_THING, INNATE_TRAIT)
	var/static/list/connections = list(
		COMSIG_TURF_CLAIMED_BY_FLOCK = PROC_REF(loc_claimed),
	)

	AddComponent(/datum/component/connect_loc_behalf, parent, connections)

/datum/component/flock_object/UnregisterFromParent()
	. = ..()
	REMOVE_TRAIT(parent, TRAIT_FLOCK_THING, INNATE_TRAIT)

/datum/component/flock_object/proc/loc_claimed(datum/source, datum/flock/flock)
	SIGNAL_HANDLER

	parent.AddComponent(/datum/component/flock_interest, flock)
