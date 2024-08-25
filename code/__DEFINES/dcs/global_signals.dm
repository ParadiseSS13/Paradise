/**
 * Signals for globally accessible objects/procs.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
/// job subsystem has spawned and equipped a new mob
#define COMSIG_GLOB_JOB_AFTER_SPAWN "!job_after_spawn"
///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"
///from SSsecurity_level on planning security level change : (previous_level_number, new_level_number)
#define COMSIG_SECURITY_LEVEL_CHANGE_PLANNED "security_level_change_planned"
///from SSsecurity_level when the security level changes : (previous_level_number, new_level_number)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"

/// mob was created somewhere : (mob)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"
/// mob died somewhere : (mob , gibbed)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
/// global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"

/// Called when the round has started, but before GAME_STATE_PLAYING.
#define COMSIG_TICKER_ROUND_STARTING "comsig_ticker_round_starting"

/// Used by admin-tooling to remove radiation
#define COMSIG_ADMIN_DECONTAMINATE "admin_decontaminate"
