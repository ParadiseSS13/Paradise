/**
	Ninja Chameleon Helper

	This component is used to rerender chameleon disguise on a ninja if icon rerendering occurs
 */
/datum/component/ninja_chameleon_helper
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// the suit reference
	var/obj/item/clothing/suit/space/space_ninja/my_suit

/datum/component/ninja_chameleon_helper/Initialize(ninja_suit)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(!istype(ninja_suit, /obj/item/clothing/suit/space/space_ninja))
		return COMPONENT_INCOMPATIBLE
	my_suit = ninja_suit

/datum/component/ninja_chameleon_helper/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_APPLY_OVERLAY, .proc/restart_chameleon)


/datum/component/ninja_chameleon_helper/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HUMAN_APPLY_OVERLAY)

/datum/component/ninja_chameleon_helper/proc/restart_chameleon()
	if(my_suit.disguise_active)
		// Has to cut overlays this way because of a possible bug, that turns ninja invisible, or mess his model up
		// Probably cause cut_overlays operates on a queue. And i here need a strict order of doing those operations or
		// else it messes all up.
		my_suit.affecting.overlays.Cut()
		my_suit.toggle_chameleon(FALSE)
