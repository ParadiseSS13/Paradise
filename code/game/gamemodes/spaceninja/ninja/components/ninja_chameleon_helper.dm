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
	RegisterSignal(parent, list(
		COMSIG_MOB_REGENERATE_ICONS,
//		COMSIG_MOB_UPDATE_ICONS,
		COMSIG_MOB_UPDATE_INV_HANDCUFFED,
		COMSIG_MOB_UPDATE_INV_LEGCUFFED,
		COMSIG_MOB_UPDATE_INV_BACK,
//		COMSIG_MOB_UPDATE_INV_L_HAND,
//		COMSIG_MOB_UPDATE_INV_R_HAND,
		COMSIG_MOB_UPDATE_INV_WEAR_MASK,
		COMSIG_MOB_UPDATE_INV_WEAR_SUIT,
		COMSIG_MOB_UPDATE_INV_W_UNIFORM,
		COMSIG_MOB_UPDATE_INV_BELT,
		COMSIG_MOB_UPDATE_INV_HEAD,
		COMSIG_MOB_UPDATE_INV_GLOVES,
		COMSIG_MOB_UPDATE_INV_NECK,
//		COMSIG_MOB_UPDATE_MUTATIONS,
		COMSIG_MOB_UPDATE_INV_WEAR_ID,
		COMSIG_MOB_UPDATE_INV_SHOES,
		COMSIG_MOB_UPDATE_INV_GLASSES,
		COMSIG_MOB_UPDATE_INV_S_STORE,
		COMSIG_MOB_UPDATE_INV_POCKETS,
		COMSIG_MOB_UPDATE_INV_WEAR_PDA,
		COMSIG_MOB_UPDATE_INV_EARS,
		COMSIG_MOB_UPDATE_TRANSFORM), .proc/restart_chameleon)


/datum/component/ninja_chameleon_helper/UnregisterFromParent()
	UnregisterSignal(parent,  list(
		COMSIG_MOB_REGENERATE_ICONS,
//		COMSIG_MOB_UPDATE_ICONS,
		COMSIG_MOB_UPDATE_INV_HANDCUFFED,
		COMSIG_MOB_UPDATE_INV_LEGCUFFED,
		COMSIG_MOB_UPDATE_INV_BACK,
//		COMSIG_MOB_UPDATE_INV_L_HAND,
//		COMSIG_MOB_UPDATE_INV_R_HAND,
		COMSIG_MOB_UPDATE_INV_WEAR_MASK,
		COMSIG_MOB_UPDATE_INV_WEAR_SUIT,
		COMSIG_MOB_UPDATE_INV_W_UNIFORM,
		COMSIG_MOB_UPDATE_INV_BELT,
		COMSIG_MOB_UPDATE_INV_HEAD,
		COMSIG_MOB_UPDATE_INV_GLOVES,
		COMSIG_MOB_UPDATE_INV_NECK,
//		COMSIG_MOB_UPDATE_MUTATIONS,
		COMSIG_MOB_UPDATE_INV_WEAR_ID,
		COMSIG_MOB_UPDATE_INV_SHOES,
		COMSIG_MOB_UPDATE_INV_GLASSES,
		COMSIG_MOB_UPDATE_INV_S_STORE,
		COMSIG_MOB_UPDATE_INV_POCKETS,
		COMSIG_MOB_UPDATE_INV_WEAR_PDA,
		COMSIG_MOB_UPDATE_INV_EARS,
		COMSIG_MOB_UPDATE_TRANSFORM))

/datum/component/ninja_chameleon_helper/proc/restart_chameleon()
	if(my_suit.disguise_active)
		// Has to cut overlays this way because of a possible bug, that turns ninja invisible, or mess his model up
		// Probably cause cut_overlays operates on a queue. And i here need a strict order of doing those operations or
		// else it messes all up.
		my_suit.affecting.overlays.Cut()
		my_suit.toggle_chameleon(FALSE)
