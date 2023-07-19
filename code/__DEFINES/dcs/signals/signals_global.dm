// Global signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice


/// called after a successful area creation by a mob: (area/created_area, list/area/old_areas, mob/creator)
#define COMSIG_AREA_CREATED "!mob_created_area"
///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// sent after world.maxx and/or world.maxy are expanded: (has_exapnded_world_maxx, has_expanded_world_maxy)
#define COMSIG_GLOB_EXPANDED_WORLD_BOUNDS "!expanded_world_bounds"
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
/// Called from base of /mob/Initialise : (mob)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"
/// mob died somewhere : (mob/living, gibbed)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
/// global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"
/// called by datum/cinematic/play() : (datum/cinematic/new_cinematic)
#define COMSIG_GLOB_PLAY_CINEMATIC "!play_cinematic"
	#define COMPONENT_GLOB_BLOCK_CINEMATIC (1<<0)
/// ingame button pressed (/obj/machinery/button/button)
#define COMSIG_GLOB_BUTTON_PRESSED "!button_pressed"
/// job subsystem has spawned and equipped a new mob
#define COMSIG_GLOB_JOB_AFTER_SPAWN "!job_after_spawn"
/// job datum has been called to deal with the aftermath of a latejoin spawn
#define COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN "!job_after_latejoin_spawn"
/// crewmember joined the game (mob/living, rank)
#define COMSIG_GLOB_CREWMEMBER_JOINED "!crewmember_joined"
/// Random event is trying to roll. (/datum/round_event_control/random_event)
/// Called by (/datum/round_event_control/preRunEvent).
#define COMSIG_GLOB_PRE_RANDOM_EVENT "!pre_random_event"
	/// Do not allow this random event to continue.
	#define CANCEL_PRE_RANDOM_EVENT (1<<0)
/// Called by (/datum/round_event_control/run_event).
#define COMSIG_GLOB_RANDOM_EVENT "!random_event"
	/// Do not allow this random event to continue.
	#define CANCEL_RANDOM_EVENT (1<<0)
/// a person somewhere has thrown something : (mob/living/carbon/carbon_thrower, target)
#define COMSIG_GLOB_CARBON_THROW_THING	"!throw_thing"
/// a trapdoor remote has sent out a signal to link with a trapdoor
#define COMSIG_GLOB_TRAPDOOR_LINK "!trapdoor_link"
	///successfully linked to a trapdoor!
	#define LINKED_UP (1<<0)
/// an obj/item is created! (obj/item/created_item)
#define COMSIG_GLOB_NEW_ITEM "!new_item"
/// an obj/machinery is created! (obj/machinery/created_machine)
#define COMSIG_GLOB_NEW_MACHINE "!new_machine"
/// a client (re)connected, after all /client/New() checks have passed : (client/connected_client)
#define COMSIG_GLOB_CLIENT_CONNECT "!client_connect"
/// a weather event of some kind occured
#define COMSIG_WEATHER_TELEGRAPH(event_type) "!weather_telegraph [event_type]"
#define COMSIG_WEATHER_START(event_type) "!weather_start [event_type]"
#define COMSIG_WEATHER_WINDDOWN(event_type) "!weather_winddown [event_type]"
#define COMSIG_WEATHER_END(event_type) "!weather_end [event_type]"
/// An alarm of some form was sent (datum/alarm_handler/source, alarm_type, area/source_area)
#define COMSIG_GLOB_ALARM_FIRE(alarm_type) "!alarm_fire [alarm_type]"
/// An alarm of some form was cleared (datum/alarm_handler/source, alarm_type, area/source_area)
#define COMSIG_GLOB_ALARM_CLEAR(alarm_type) "!alarm_clear [alarm_type]"
///global mob logged in signal! (/mob/added_player)
#define COMSIG_GLOB_MOB_LOGGED_IN "!mob_logged_in"

/// global signal sent when a nuclear device is armed (/obj/machinery/nuclearbomb/nuke/exploding_nuke)
#define COMSIG_GLOB_NUKE_DEVICE_ARMED "!nuclear_device_armed"
/// global signal sent when a nuclear device is disarmed (/obj/machinery/nuclearbomb/nuke/disarmed_nuke)
#define COMSIG_GLOB_NUKE_DEVICE_DISARMED "!nuclear_device_disarmed"

/// Global signal sent when a light mechanism is completed (try_id)
#define COMSIG_GLOB_LIGHT_MECHANISM_COMPLETED "!light_mechanism_completed"

/// Global signal called after the station changes its name.
/// (new_name, old_name)
#define COMSIG_GLOB_STATION_NAME_CHANGED "!station_name_changed"

/// global signal when a global nullrod type is picked
#define COMSIG_GLOB_NULLROD_PICKED "!nullrod_picked"
