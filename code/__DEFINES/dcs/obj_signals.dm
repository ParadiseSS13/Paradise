/**
 * Signals for /obj and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /obj

///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///called in /obj/update_icon()
#define COMSIG_OBJ_UPDATE_ICON "obj_update_icon"


// /obj/projectile (sent to the firer)

///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///from the base of /obj/projectile/proc/fire(): ()
#define COMSIG_PROJECTILE_FIRE "projectile_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///sent when trying to force an embed (mainly for projectiles, only used in the embed element)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"


// /obj/mecha

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"

/// cable was placed or joined somewhere : (turf)
#define COMSIG_GLOB_CABLE_UPDATED "!cable_updated"


// /obj/structure/cursed_slot_machine

/// from /obj/structure/cursed_slot_machine/handle_status_effect() when someone pulls the handle on the slot machine
#define COMSIG_CURSED_SLOT_MACHINE_USE "cursed_slot_machine_use"
	#define SLOT_MACHINE_USE_CANCEL (1<<0) //! we've used up the number of times we may use this slot machine. womp womp.
	#define SLOT_MACHINE_USE_POSTPONE (1<<1) //! we haven't used up all our attempts to gamble away our life but we should chill for a few seconds
/// from /obj/structure/cursed_slot_machine/determine_victor() when someone loses.
#define COMSIG_CURSED_SLOT_MACHINE_LOST "cursed_slot_machine_lost"
/// from /obj/structure/cursed_slot_machine/determine_victor() when someone finally wins.
#define COMSIG_GLOB_CURSED_SLOT_MACHINE_WON "cursed_slot_machine_won"


// other subtypes

///from base of /obj/effect/decal/cleanable/blood/gibs/streak(): (list/directions, list/diseases)
#define COMSIG_GIBS_STREAK "gibs_streak"
