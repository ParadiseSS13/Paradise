/**
 * Signals for globally accessible objects/procs.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (name, linkage, list/traits, transition_tag, level_type, zlevel)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
/// job subsystem has spawned and equipped a new mob
#define COMSIG_GLOB_JOB_AFTER_SPAWN "!job_after_spawn"
///from SSsecurity_level on planning security level change : (previous_level_number, new_level_number)
#define COMSIG_SECURITY_LEVEL_CHANGE_PLANNED "security_level_change_planned"
///from SSsecurity_level when the security level changes : (previous_level_number, new_level_number)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"
/// cable was placed or joined somewhere : (turf)
#define COMSIG_GLOB_CABLE_UPDATED "!cable_updated"

/// Called when the round has started, but before GAME_STATE_PLAYING.
#define COMSIG_TICKER_ROUND_STARTING "comsig_ticker_round_starting"

/// Used by admin-tooling to remove radiation
#define COMSIG_ADMIN_DECONTAMINATE "admin_decontaminate"

/// Used when a shelter capsule deploys
#define COMSIG_GLOB_SHELTER_PLACED "!shelter_placed"

/// sent after world.maxx and/or world.maxy are expanded: (has_expanded_world_maxx, has_expanded_world_maxy)
#define COMSIG_GLOB_EXPANDED_WORLD_BOUNDS "!expanded_world_bounds"
