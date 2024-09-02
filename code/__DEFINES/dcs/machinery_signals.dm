/**
 * Signals for /obj/machinery and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from /obj/machinery/obj_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"


// /obj/machinery/camera

#define COMSIG_CAMERA_ON "camera_on"
#define COMSIG_CAMERA_OFF "camera_off"
#define COMSIG_CAMERA_MOVED "camera_moved"


// /obj/machinery/door

#define COMSIG_DOOR_OPEN "door_open"
#define COMSIG_DOOR_CLOSE "door_close"


// /obj/machinery/door/airlock

#define COMSIG_AIRLOCK_OPEN "airlock_open"
#define COMSIG_AIRLOCK_CLOSE "airlock_close"

/// ingame button pressed (/obj/machinery/button/button)
#define COMSIG_GLOB_BUTTON_PRESSED "!button_pressed"
