/**
 * Signals for base types that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /client

/// from base of client/Click(): (atom/target, atom/location, control, params, mob/user)
#define COMSIG_CLIENT_CLICK "atom_client_click"
/// from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
/// from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
/// from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"

/// from base of area/Entered(): (/area)
#define COMSIG_ENTER_AREA "enter_area"
/// from base of area/Exited(): (/area)
#define COMSIG_EXIT_AREA "exit_area"

// /area

/// from base of area/Entered(): (atom/movable/M)
#define COMSIG_AREA_ENTERED "area_entered"
///from base of area/Exited(): (atom/movable/M)
#define COMSIG_AREA_EXITED "area_exited"

// /turf

///from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_CHANGE "turf_change"
///from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"
///from base of turf/New(): (turf/source, direction)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE	"obj_hide"

