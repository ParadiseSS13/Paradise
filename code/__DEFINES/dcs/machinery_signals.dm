/**
 * Signals for /obj/machinery and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */


// /obj/machinery/camera

/// called on cameras after activation: (mob/user, display_message)
#define COMSIG_CAMERA_ON "camera_on"
/// called on cameras after deactivation: (mob/user, display_message, emped)
#define COMSIG_CAMERA_OFF "camera_off"
/// called on cameras when moved, such as ones inside helmets: (turf/prev_turf)
#define COMSIG_CAMERA_MOVED "camera_moved"


// /obj/machinery/door

/// called on doors when opened: ()
#define COMSIG_DOOR_OPEN "door_open"
/// called on doors when closed: ()
#define COMSIG_DOOR_CLOSE "door_close"


// /obj/machinery/door/airlock

/// called on airlocks when opened: ()
#define COMSIG_AIRLOCK_OPEN "airlock_open"
/// called on airlocks when closed: ()
#define COMSIG_AIRLOCK_CLOSE "airlock_close"

// /obj/machinery

/// Used to represent that an arbitrary success event has occurred as a result
/// of the machine's use. If that success event has resulted in the creation of
/// atoms the handler may want to know about, they are passed in `list/created`.
/// You could add an argument for created reagents too but that feels esoteric
/// and harder to manipulate properly with no other context.
#define COMSIG_MACHINE_PROCESS_COMPLETE "machine_process_complete" // (list/created)
