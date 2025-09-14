/**
 * Signals for /atom and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /atom

//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization and has a loc
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON "atom_init_success_on"
// from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"
///from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
///from base of atom/examine(): (examining_user, examine_list)
#define COMSIG_PARENT_EXAMINE "atom_examine"
///from base of atom/examine_more(): (examining_user, examine_list)
#define COMSIG_PARENT_EXAMINE_MORE "atom_examine_more"
///from base of [/atom/proc/update_appearance]: (updates)
#define COMSIG_ATOM_UPDATE_APPEARANCE "atom_update_appearance"
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its name.
	#define COMSIG_ATOM_NO_UPDATE_NAME UPDATE_NAME
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its desc.
	#define COMSIG_ATOM_NO_UPDATE_DESC UPDATE_DESC
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its icon.
	#define COMSIG_ATOM_NO_UPDATE_ICON UPDATE_ICON
///from base of [/atom/proc/update_name]: (updates)
#define COMSIG_ATOM_UPDATE_NAME "atom_update_name"
///from base of [/atom/proc/update_desc]: (updates)
#define COMSIG_ATOM_UPDATE_DESC "atom_update_desc"
///from base of [/atom/proc/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its icon state.
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE UPDATE_ICON_STATE
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its overlays.
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS UPDATE_OVERLAYS
///Sent after [/atom/proc/update_icon_state] is called by [/atom/proc/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON_STATE "atom_update_icon_state"
///Sent after [/atom/proc/update_overlays] is called by [/atom/proc/update_icon]: (list/new_overlays)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"
///from base of [/atom/proc/update_icon]: (signalOut, did_anything)
#define COMSIG_ATOM_UPDATED_ICON "atom_updated_icon"
///from base of atom/Entered(): (atom/movable/entered, /atom)
#define COMSIG_ATOM_ENTERED "atom_entered"
///from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
#define COMSIG_ATOM_EXIT "atom_exit"
	#define COMPONENT_ATOM_BLOCK_EXIT (1<<0)
///from base of atom/Exited(): (atom/movable/exiting, direction)
#define COMSIG_ATOM_EXITED "atom_exited"
///from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
///from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
///from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
///from base of atom/bullet_act(): (/obj/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
///from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
///from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
///from base of atom/emag_act(): (/mob/user)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"
///from base of atom/rad_act(intensity, emission_type)
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"
///from base of turf/irradiate(/datum/radiation_wave)
#define COMSIG_TURF_IRRADIATE
///from base of atom/singularity_pull(): (S, current_size)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
///from base of atom/set_light(): (l_range, l_power, l_color)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"
/// from base of atom/set_opacity(): (new_opacity)
#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"
///from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
///from [/datum/controller/subsystem/processing/dcs/proc/rotate_decals]: (list/datum/element/decal/rotating)
#define COMSIG_ATOM_DECALS_ROTATING "atom_decals_rotating"
///from base of atom/has_gravity(): (turf/location, list/forced_gravities)
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"
///from proc/get_rad_contents(): ()
#define COMSIG_ATOM_RAD_PROBE "atom_rad_probe"
	#define COMPONENT_BLOCK_RADIATION (1<<0)
///from base of datum/radiation_wave/radiate(): (strength)
#define COMSIG_ATOM_RAD_CONTAMINATING "atom_rad_contam"
	#define COMPONENT_BLOCK_CONTAMINATION (1<<0)
///from base of datum/radiation_wave/check_obstructions(): (datum/radiation_wave, width)
#define COMSIG_ATOM_RAD_WAVE_PASSING "atom_rad_wave_pass"
	#define COMPONENT_RAD_WAVE_HANDLED (1<<0)
///called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"
///called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"
/// called on an atom who has stopped orbiting another atom (atom/orbiter, atom/formerly_orbited)
#define COMSIG_ATOM_ORBITER_STOP "atom_orbiter_stop"
///from base of atom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_HITBY "atom_hitby"
/// Called when an atom is sharpened or dulled.
#define COMSIG_ATOM_UPDATE_SHARPNESS "atom_update_sharpness"
///from base of atom/atom_prehit(obj/item/projectile/P):
#define COMSIG_ATOM_PREHIT "atom_prehit"
	#define ATOM_PREHIT_SUCCESS (1<<0)
	#define ATOM_PREHIT_FAILURE (1<<1)
///from relay_attackers element: (atom/attacker, attack_flags)
#define COMSIG_ATOM_ATTACK_ANIMAL "atom_attack_animal"
#define COMSIG_ATOM_WAS_ATTACKED "atom_was_attacked"
	///The damage type of the weapon projectile is non-lethal stamina
	#define ATTACKER_STAMINA_ATTACK (1<<0)
	///the attacker is shoving the source
	#define ATTACKER_SHOVING (1<<1)
	/// The attack is a damaging-type attack
	#define ATTACKER_DAMAGING_ATTACK (1<<2)

/// Called from atom/Initialize() of target: (atom/target)
#define COMSIG_ATOM_INITIALIZED_ON "atom_initialized_on"

///from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_paw(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
	#define COMPONENT_NO_ATTACK_HAND (1<<0)								//works on all 3.
//This signal return value bitflags can be found in __DEFINES/misc.dm

///called on /living, when pull is attempted, but before it completes, from base of [/mob/living/proc/start_pulling]: (atom/movable/thing, force)
#define COMSIG_LIVING_TRY_PULL "living_try_pull"
	#define COMSIG_LIVING_CANCEL_PULL (1 << 0)
#define COMSIG_ATOM_PULLED "atom_pulled"

///from base of atom/Bumped(atom/bumped_atom)
#define COMSIG_ATOM_BUMPED "atom_bumped"

///from base of atom/expose_reagents(): (/list, /datum/reagents, chemholder, volume_modifier)
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"

///from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK "atom_click"
///from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_SHIFT "shift_click"
	#define COMPONENT_ALLOW_EXAMINATE (1<<0) 							//Allows the user to examinate regardless of client.eye.
///from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"
///from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"
	/// Cancel the alt-click, since this isn't properly part of the attack chain
	#define COMPONENT_CANCEL_ALTCLICK (1<<0)
///from base of atom/CtrlShiftClick(/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"
///from base of atom/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_NO_MOUSEDROP (1<<0)
///from base of atom/MouseDrop_T: (/atom/from, /mob/user)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"

/// Called on the atom being hit, from /datum/component/anti_magic/on_attack() : (obj/item/weapon, mob/user, antimagic_flags)
#define COMSIG_ATOM_HOLY_ATTACK "atom_holyattacked"
/// On a ranged attack: base of mob/living/carbon/human/RangedAttack (/mob/living/carbon/human)
#define COMSIG_ATOM_RANGED_ATTACKED "atom_range_attacked"

// Smithing signals
/// When using a bit on an item that can accept a bit
#define COMSIG_BIT_ATTACH "bit_attach"
/// When using a lens on an item that can accept a lens
#define COMSIG_LENS_ATTACH "lens_attach"
/// When using an insert on an item that can accept an insert
#define COMSIG_INSERT_ATTACH "insert_attach"
#define COMSIG_MINE_EXPOSE_GIBTONITE "mine_expose_gibtonite"
