/**
 * Signals for /atom/movable and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from base of atom/movable/Moved(): (/atom)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE (1<<0)
///from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_MOVED "movable_moved"
///from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CHECK_CROSS "movable_cross"
	#define COMPONENT_BLOCK_CROSS (1<<0)
///from base of atom/movable/Move(): (/atom/movable)
#define COMSIG_MOVABLE_CHECK_CROSS_OVER "movable_cross_over"
///from base of atom/movable/Uncross(): (/atom/movable)
#define COMSIG_MOVABLE_UNCROSS "movable_uncross"
	#define COMPONENT_MOVABLE_BLOCK_UNCROSS (1<<0)
///from base of atom/movable/Bump(): (/atom)
#define COMSIG_MOVABLE_BUMP "movable_bump"
	#define COMPONENT_INTERCEPT_BUMPED (1<<0)
///from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT "movable_impact"
	#define COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH (1<<0)				//if true, flip if the impact will push what it hits
	#define COMPONENT_MOVABLE_IMPACT_NEVERMIND (1<<1)					//return true if you destroyed whatever it was you're impacting and there won't be anything for hitby() to run on
///from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"
///from /atom/movable/proc/buckle_mob(): (mob/living/M, force, check_loc, buckle_mob_flags)
#define COMSIG_MOVABLE_PREBUCKLE "prebuckle" // this is the last chance to interrupt and block a buckle before it finishes
	#define COMPONENT_BLOCK_BUCKLE (1<<0)
///from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_BUCKLE "buckle"
///from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
///from /obj/vehicle/proc/driver_move, caught by the riding component to check and execute the driver trying to drive the vehicle
#define COMSIG_RIDDEN_DRIVER_MOVE "driver_move"
	#define COMPONENT_DRIVER_BLOCK_MOVE (1<<0)
///from base of atom/movable/throw_at(): (datum/thrownthing, spin)
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"
///from base of datum/thrownthing/finalize(): (obj/thrown_object, datum/thrownthing) used for when a throw is finished
#define COMSIG_MOVABLE_THROW_LANDED "movable_throw_landed"
///from base of atom/movable/shove_impact(): (mob/living/target, mob/living/attacker)
#define COMSIG_MOVABLE_SHOVE_IMPACT "movable_shove_impact"
///from base of atom/movable/on_changed_z_level(): (turf/old_turf, turf/new_turf)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"

/// Called just before something gets untilted
#define COMSIG_MOVABLE_TRY_UNTILT "movable_try_untilt"
	/// Return this to block an untilt attempt
	#define COMPONENT_BLOCK_UNTILT (1<<0)
/// Called when something gets untilted, from /datum/element/tilted/proc/do_untilt(atom/movable/source, mob/user)
#define COMSIG_MOVABLE_UNTILTED "movable_untilted"

///called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"
///called when the movable is removed from a disposal holder object: /obj/structure/disposalpipe/proc/expel(): (obj/structure/disposalholder/H, turf/T, direction)
#define COMSIG_MOVABLE_EXIT_DISPOSALS "movable_exit_disposals"

/// from base of atom/movable/Process_Spacemove(): (movement_dir, continuous_move)
#define COMSIG_MOVABLE_SPACEMOVE "spacemove"
	#define COMSIG_MOVABLE_STOP_SPACEMOVE (1<<0)

// Note that this is only defined for actions because this could be a good bit expensive otherwise
/// From base of /atom/movable/screen/movable/action_button/MouseWheel(src, delta_x, delta_y, location, control, params)
#define COMSIG_ACTION_SCROLLED "action_scrolled"

/// Called before a movable is being teleported from multiple sources: (destination)
#define COMSIG_MOVABLE_TELEPORTING "movable_teleporting"
/// Called when blocking a teleport
#define COMSIG_ATOM_INTERCEPT_TELEPORTED "intercept_teleported"
	#define COMPONENT_BLOCK_TELEPORT (1<<0)
///from base of atom/movable/newtonian_move(): (inertia_direction, start_delay)
#define COMSIG_MOVABLE_NEWTONIAN_MOVE "movable_newtonian_move"
	#define COMPONENT_MOVABLE_NEWTONIAN_BLOCK (1<<0)

///from datum/component/drift/apply_initial_visuals(): ()
#define COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT "movable_drift_visual_attempt"
	#define DRIFT_VISUAL_FAILED (1<<0)
///from datum/component/drift/allow_final_movement(): ()
#define COMSIG_MOVABLE_DRIFT_BLOCK_INPUT "movable_drift_block_input"
	#define DRIFT_ALLOW_INPUT (1<<0)

///called after the movable's glide size is updated: (old_glide_size)
#define COMSIG_MOVABLE_UPDATED_GLIDE_SIZE "movable_glide_size"

///signal sent out by an atom when it is no longer pulling something : (atom/pulling)
#define COMSIG_ATOM_NO_LONGER_PULLING "movable_no_longer_pulling"

///from base of /atom/movable/point_at: (atom/A, obj/effect/temp_visual/point/point)
#define COMSIG_MOVABLE_POINTED "movable_pointed"

///signal sent out by /datum/component/tether when durability/line of sight fails : (atom/tethered)
#define COMSIG_TETHER_DESTROYED "tether_snap"
///a signal sent to /datum/component/tether by the tethered object to stop the tethering : (atom/tethered)
#define COMSIG_TETHER_STOP "tether_stop"
