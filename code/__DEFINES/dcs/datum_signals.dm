/**
 * Signals for /datums.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /datum/component

/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of UnlinkComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_PARENT_QDELETING "parent_qdeleting"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"


// /datum/mind

///from base of /datum/mind/proc/transfer_to(mob/living/new_character)
#define COMSIG_MIND_TRANSER_TO "mind_transfer_to"
///called on the mob instead of the mind
#define COMSIG_BODY_TRANSFER_TO "body_transfer_to"
///called when the mind is initialized (called every time the mob logins)
#define COMSIG_MIND_INITIALIZE "mind_initialize"

// Sent from a surgery step when blood is being splashed. (datum/surgery, mob/user, mob/target, zone, obj/item/tool)
#define COMSIG_SURGERY_BLOOD_SPLASH "surgery_blood_splash"
	/// If returned from this signal, will prevent any surgery splashing.
	#define COMPONENT_BLOOD_SPLASH_HANDLED (1<<0)

// /datum/species

///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"
///from /datum/species/proc/spec_hitby()
#define COMSIG_SPECIES_HITBY "species_hitby"


// /datum/song

///sent to the instrument when a song starts playing
#define COMSIG_SONG_START 	"song_start"
///sent to the instrument when a song stops playing
#define COMSIG_SONG_END		"song_end"


// /datum/element/decal

///called on an object to clean it of cleanables.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"
	///Returned by cleanable components when they are cleaned.
	#define COMPONENT_CLEANED (1<<0)


// /datum/component/two_handed

///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"
	#define COMPONENT_TWOHANDED_BLOCK_WIELD (1<<0)
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"
///from base of /datum/component/forces_doors_open/proc/force_open_door(obj/item): (datum/source, mob/user, atom/target)
#define COMSIG_TWOHANDED_WIELDED_TRY_WIELD_INTERACT "twohanded_wielded_try_wield_interact"


// /datum/action

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
/// From /datum/action/Grant(): (mob/grant_to)
#define COMSIG_ACTION_GRANTED "action_grant"
/// From /datum/action/Grant(): (datum/action)
#define COMSIG_MOB_GRANTED_ACTION "mob_action_grant"
/// From /datum/action/Remove(): (mob/removed_from)
#define COMSIG_ACTION_REMOVED "action_removed"
/// From /datum/action/Remove(): (datum/action)
#define COMSIG_MOB_REMOVED_ACTION "mob_action_removed"
/// From /datum/action/apply_button_overlay()
#define COMSIG_ACTION_OVERLAY_APPLY "action_overlay_applied"

// /datum/objective

///from datum/objective/proc/find_target(list/target_blacklist)
#define COMSIG_OBJECTIVE_TARGET_FOUND "objective_target_found"
///from datum/objective/is_invalid_target()
#define COMSIG_OBJECTIVE_CHECK_VALID_TARGET "objective_check_valid_target"
	#define OBJECTIVE_VALID_TARGET		(1<<0)
	#define OBJECTIVE_INVALID_TARGET	(1<<1)

/// /datum/component/defib

/// Called when a defibrillator is first applied to someone. (mob/living/user, mob/living/target, harmful)
#define COMSIG_DEFIB_PADDLES_APPLIED "defib_paddles_applied"
	/// Defib is out of power.
	#define COMPONENT_BLOCK_DEFIB_DEAD (1<<0)
	/// Something else: we won't have a custom message for this and should let the defib handle it.
	#define COMPONENT_BLOCK_DEFIB_MISC (1<<1)
/// Called when a defib has been successfully used, and a shock has been applied. (mob/living/user, mob/living/target, harmful, successful)
#define COMSIG_DEFIB_SHOCK_APPLIED "defib_zap"
/// Called when a defib's cooldown has run its course and it is once again ready. ()
#define COMSIG_DEFIB_READY "defib_ready"


/// /datum/alarm_manager

#define COMSIG_TRIGGERED_ALARM "alarmmanager_triggered"
#define COMSIG_CANCELLED_ALARM "alarmmanager_cancelled"

// other subtypes

///from base of /datum/local_powernet/proc/power_change()
#define COMSIG_POWERNET_POWER_CHANGE "powernet_power_change"

/// Sent when bodies transfer between shades/shards and constructs
/// from base of /datum/component/construct_held_body/proc/transfer_held_body()
#define COMSIG_SHADE_TO_CONSTRUCT_TRANSFER "shade_to_construct_transfer"


/// /datum/component/label
/// Called when a handlabeler is used on an item when off
#define COMSIG_LABEL_REMOVE "label_remove"

// /datum/ruleset

/// from base of /datum/ruleset/proc/can_apply()
#define COMSIG_RULESET_FAILED_SPECIES "failed_species"

#define COMSIGN_TICKET_COUNT_UPDATE "ticket_count_updated"

//spatial grid signals

/// Called from base of /datum/controller/subsystem/spatial_grid/proc/enter_cell: (/atom/movable)
#define SPATIAL_GRID_CELL_ENTERED(contents_type) "spatial_grid_cell_entered_[contents_type]"
/// Called from base of /datum/controller/subsystem/spatial_grid/proc/exit_cell: (/atom/movable)
#define SPATIAL_GRID_CELL_EXITED(contents_type) "spatial_grid_cell_exited_[contents_type]"
