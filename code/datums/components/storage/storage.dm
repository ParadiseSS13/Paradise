
/datum/component/storage
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/storage/concrete

/datum/component/storage/Initialize(datum/component/storage/concrete/master)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/show_to_ghost)

/datum/component/storage/proc/show_to_ghost(datum/source, mob/dead/observer/M)
	var/obj/item/storage/s = parent
	if(istype(s))
		return s.show_to(M)

