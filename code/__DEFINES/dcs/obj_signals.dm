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
