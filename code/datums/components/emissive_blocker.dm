/datum/component/emissive_blocker
	/// Stores either the mutable_appearance or a list of them
	var/stored_blocker

/datum/component/emissive_blocker/Initialize(_stored_blocker)
	var/atom/movable/A = parent
	stored_blocker = _stored_blocker
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(update_generic_block))
	A.add_overlay(stored_blocker)

/datum/component/emissive_blocker/Destroy()
	stored_blocker = null
	return ..()

/// Updates the generic blocker when the icon_state is changed
/datum/component/emissive_blocker/proc/update_generic_block(datum/source)
	var/atom/movable/A = parent
	if(!A.blocks_emissive && stored_blocker)
		A.cut_overlay(stored_blocker)
		stored_blocker = null
		return
	if(!A.blocks_emissive)
		return
	var/mutable_appearance/gen_emissive_blocker = emissive_blocker(A.icon, A.icon_state, alpha = A.alpha, appearance_flags = A.appearance_flags)
	gen_emissive_blocker.dir = A.dir
	if(gen_emissive_blocker != stored_blocker || !A.overlays)
		A.cut_overlay(stored_blocker)
		stored_blocker = gen_emissive_blocker
		A.add_overlay(stored_blocker)
