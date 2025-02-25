/**
 * Signals for /area and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /area

/// From obj/machinery/light_switch/Destroy(): ()
#define COMSIG_AREA_LIGHTSWITCH_DELETING "area_lightswitch_deleting"
	/// Stop all area lightswitches from turning back on.
	#define COMSIG_AREA_LIGHTSWITCH_CANCEL (1<<0)
