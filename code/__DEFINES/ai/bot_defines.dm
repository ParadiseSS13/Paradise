// bot keys
/// The first beacon we find
#define BB_BEACON_TARGET "beacon_target"
/// The last beacon we found, we will use its codes to find the next beacon
#define BB_PREVIOUS_BEACON_TARGET "previous_beacon_target"
/// Location of whoever summoned us
#define BB_BOT_SUMMON_TARGET "bot_summon_target"
/// Salute messages to beepsky
#define BB_SALUTE_MESSAGES "salute_messages"
/// The beepsky we will salute
#define BB_SALUTE_TARGET "salute_target"
/// Our announcement ability
#define BB_ANNOUNCE_ABILITY "announce_ability"
/// List of our radio channels
#define BB_RADIO_CHANNEL "radio_channel"
/// List of unreachable things we will temporarily ignore
#define BB_TEMPORARY_IGNORE_LIST "temporary_ignore_list"
/// Penalty cooldown if we are unable to path to any beacons
#define BB_BOT_BEACON_COOLDOWN "bot_beacon_cooldown"

// firebot keys
/// things we can extinguish
#define BB_FIREBOT_CAN_EXTINGUISH "can_extinguish"
/// the target we will extinguish
#define BB_FIREBOT_EXTINGUISH_TARGET "extinguish_target"
/// lines we say when we detect a fire
#define BB_FIREBOT_FIRE_DETECTED_LINES "fire_detected_lines"
/// lines we say when we are idle
#define BB_FIREBOT_IDLE_LINES "idle_lines"
/// lines we say when we are emagged
#define BB_FIREBOT_EMAGGED_LINES "emagged_lines"

// medbot keys
/// The patient we must heal
#define BB_PATIENT_TARGET "patient_target"
/// List holding our wait dialogue
#define BB_WAIT_SPEECH "wait_speech"
/// What we will say to our patient after we heal them
#define BB_AFTERHEAL_SPEECH "afterheal_speech"
/// Things we will say when we are bored
#define BB_IDLE_SPEECH "idle_speech"
/// Speech unlocked after being emagged
#define BB_EMAGGED_SPEECH "emagged_speech"
/// Speech when we are tipped
#define BB_WORRIED_ANNOUNCEMENTS "worried_announcements"
/// Speech when our patient is near death
#define BB_NEAR_DEATH_SPEECH "near_death_speech"
/// In crit patient we must alert medbay about
#define BB_PATIENT_IN_CRIT "patient_in_crit"
/// How much time interval before we clear list
#define BB_UNREACHABLE_LIST_COOLDOWN "unreachable_list_cooldown"
/// Can we clear the list now
#define	BB_CLEAR_LIST_READY "clear_list_ready"

// cleanbots
/// Key that holds the foaming ability
#define BB_CLEANBOT_FOAM "cleanbot_foam"
/// Key that holds decals we hunt
#define BB_CLEANABLE_DECALS "cleanable_decals"
/// Key that holds blood we hunt
#define BB_CLEANABLE_BLOOD "cleanable_blood"
/// Key that holds pests we hunt
#define BB_HUNTABLE_PESTS "huntable_pests"
/// Key that holds emagged speech
#define BB_CLEANBOT_EMAGGED_PHRASES "emagged_phrases"
/// Key that holds drawings we hunt
#define BB_CLEANABLE_DRAWINGS "cleanable_drawings"
/// Key that holds the janitor we will befriend
#define BB_FRIENDLY_JANITOR "friendly_janitor"
/// Key that holds the victim we will spray
#define BB_ACID_SPRAY_TARGET "acid_spray_target"
/// Key that holds trash we will burn
#define BB_HUNTABLE_TRASH "huntable_trash"
/// key that holds cooldown after we finish cleaning something, so we dont immediately run off to patrol
#define BB_POST_CLEAN_COOLDOWN "post_clean_cooldown"

// Secbots
/// Threat of our current target
#define BB_CURRENT_CRIMINAL_ASSESSMENT "current_criminal_assessment"

// Honkbots
/// Key that holds all possible clown friends
#define BB_CLOWNS_LIST "clowns_list"
/// Key that holds the clown we play with
#define BB_CLOWN_FRIEND "clown_friend"
/// Key that holds the list of slippery items
#define BB_SLIPPERY_ITEMS "slippery_items"
/// Key that holds list of types we will attempt to slip
#define BB_SLIP_LIST "slip_list"
/// Key that holds the slippery item we will drag people too
#define BB_SLIPPERY_TARGET "slippery_target"
/// Key that holds the victim we will slip
#define BB_SLIP_TARGET "slip_target"
/// Key that holds our honk ability
#define BB_HONK_ABILITY "honk_ability"

// Repairbots
/// Key that holds the floor we should tile over
#define BB_TILELESS_FLOOR "tileless_floor"
/// Key that holds the turf we should place a girder over
#define BB_GIRDER_TARGET "girder_target"
/// Key that holds the girder we should place a wall over
#define BB_GIRDER_TO_WALL_TARGET "girder_to_wall"
/// Key that holds the grille we must fix
#define BB_WINDOW_FRAMETARGET "grille_target"
/// Key that holds the machinery we repair with a welder
#define BB_WELDER_TARGET "welder_target"
/// Our wall girder ability
#define BB_GIRDER_BUILD_ABILITY "girder_build_ability"
/// Key that holds breached floors we should repair
#define BB_BREACHED_FLOOR "breached_floor"
/// Key that holds our emagged speech
#define BB_REPAIRBOT_EMAGGED_SPEECH "emagged_speech"
/// Key that holds our normal speech
#define BB_REPAIRBOT_NORMAL_SPEECH "normal_speech"
/// Key that holds the thing we should deconstruct
#define BB_DECONSTRUCT_TARGET "deconstruct_target"
/// Key that holds our speech timer
#define BB_REPAIRBOT_SPEECH_COOLDOWN "speech_cooldown"
/// Key that holds our target borg
#define BB_ROBOT_TARGET "robot_target"
/// Key that holds materials we can refill
#define BB_REFILLABLE_TARGET "refillable_target"

/// key that holds our delivery destination's name
#define BB_MULEBOT_DESTINATION_BEACON "mulebot_destination"
/// key that holds our home port's name
#define BB_MULEBOT_HOME_BEACON "mulebot_home_beacon"
/// key that holds our current delivery target atom
#define BB_MULEBOT_TRAVEL_TARGET "mulebot_travel_target"
