/**
 * Signals for /obj and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /obj

///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"


// /obj/structure/cursed_slot_machine

/// from /obj/structure/cursed_slot_machine/handle_status_effect() when someone pulls the handle on the slot machine
#define COMSIG_CURSED_SLOT_MACHINE_USE "cursed_slot_machine_use"
	#define SLOT_MACHINE_USE_CANCEL (1<<0) //! we've used up the number of times we may use this slot machine. womp womp.
	#define SLOT_MACHINE_USE_POSTPONE (1<<1) //! we haven't used up all our attempts to gamble away our life but we should chill for a few seconds
/// from /obj/structure/cursed_slot_machine/determine_victor() when someone loses.
#define COMSIG_CURSED_SLOT_MACHINE_LOST "cursed_slot_machine_lost"
/// from /obj/structure/cursed_slot_machine/determine_victor() when someone finally wins.
#define COMSIG_GLOB_CURSED_SLOT_MACHINE_WON "cursed_slot_machine_won"


// /obj/item/tank/jetpack

/// from /obj/item/tank/jetpack/proc/turn_on() : ()
#define COMSIG_JETPACK_ACTIVATED "jetpack_activated"
	#define JETPACK_ACTIVATION_FAILED (1<<0)
/// from /obj/item/tank/jetpack/proc/turn_off() : ()
#define COMSIG_JETPACK_DEACTIVATED "jetpack_deactivated"

// other subtypes

/// from /datum/component/shelved/UnregisterFromParent(): (parent_uid)
#define COMSIG_SHELF_ITEM_REMOVED "shelf_item_removed"
/// from /datum/component/shelver/add_item(): (obj/item/to_add, placement_idx, list/position_details)
#define COMSIG_SHELF_ITEM_ADDED "shelf_item_added"
/// from Initialize on objects implementing /datum/component/shelved
#define COMSIG_SHELF_ADDED_ON_MAPLOAD "shelf_added_on_mapload"
/// from /datum/component/shelver/shelf_items()
#define COMSIG_SHELF_ATTEMPT_PICKUP "shelf_attempt_pickup"
	#define SHELF_PICKUP_FAILURE (1 << 0)

/// from /datum/component/supermatter_crystal/proc/consume()
/// called on the thing consumed, passes the thing which consumed it
#define COMSIG_SUPERMATTER_CONSUMED "sm_consumed_this"
