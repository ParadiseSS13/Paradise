// Generic blackboard keys.

// Movement

/// The closest we're allowed to / required to get to a target.
#define BB_CURRENT_MIN_MOVE_DISTANCE "BB_MIN_MOVE_DISTANCE"
/// How likely is this mob to move when idle per tick?
#define BB_BASIC_MOB_IDLE_WALK_CHANCE "BB_BASIC_IDLE_WALK_CHANCE"
/// Flag to set on if you want your mob to STOP running away
#define BB_BASIC_MOB_STOP_FLEEING "BB_BASIC_STOP_FLEEING"
/// Key of something we're running away from
#define BB_BASIC_MOB_FLEE_TARGET "BB_BASIC_FLEE_TARGET"
/// Key for the current hidden location of something we're running away from
#define BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION "BB_BASIC_FLEE_TARGET_HIDING_LOCATION"
/// Key defining the targeting strategy for things to flee from
#define BB_FLEE_TARGETING_STRATEGY "BB_FLEE_TARGETING_STRATEGY"
/// Key defining how far we attempt to get away from something we're fleeing from
#define BB_BASIC_MOB_FLEE_DISTANCE "BB_BASIC_FLEE_DISTANCE"
#define DEFAULT_BASIC_FLEE_DISTANCE 9

// Searching

/// key holding a range to look for stuff in
#define BB_SEARCH_RANGE "BB_SEARCH_RANGE"

// Targeting

/// Generic key for a non-specific targeted action
#define BB_TARGETED_ACTION "BB_TARGETED_ACTION"
/// Generic key for a non-specific action
#define BB_GENERIC_ACTION "BB_GENERIC_ACTION"
/// How close a mob must be for us to select it as a target, if that is less than how far we can maintain it as a target
#define BB_AGGRO_RANGE "BB_AGGRO_RANGE"
/// Key for our current target.
#define BB_BASIC_MOB_CURRENT_TARGET "BB_BASIC_CURRENT_TARGET"
/// Key for the current hidden location of our target if applicable.
#define BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION "BB_BASIC_CURRENT_TARGET_HIDING_LOCATION"
/// Key for the type of targeting strategy we will apply.
#define BB_TARGETING_STRATEGY "BB_TARGETING_STRATEGY"
/// Key for the minimum status at which we want to target mobs (does not need to be specified if CONSCIOUS)
#define BB_TARGET_MINIMUM_STAT "BB_TARGET_MINIMUM_STAT"
/// Should we skip the faction check for the targeting strategy?
#define BB_ALWAYS_IGNORE_FACTION "BB_ALWAYS_IGNORE_FACTIONS"
/// Are we in some kind of temporary state of ignoring factions when targeting? can result in volatile results if multiple behaviours touch this
#define BB_TEMPORARILY_IGNORE_FACTION "BB_TEMPORARILY_IGNORE_FACTIONS"
///List of mobs who have damaged us
#define BB_BASIC_MOB_RETALIATE_LIST "BB_BASIC_MOB_SHITLIST"

//Hunting BB keys

/// Key that holds our current hunting target
#define BB_CURRENT_HUNTING_TARGET "BB_CURRENT_HUNTING_TARGET"
/// Key that holds our less priority hunting target
#define BB_LOW_PRIORITY_HUNTING_TARGET "BB_LOW_PRIORITY_HUNTING_TARGET"
/// Key that holds the cooldown for our hunting subtree
#define BB_HUNTING_COOLDOWN(type) "BB_HUNTING_COOLDOWN_[type]"

// Food and eating

/// list of foods this mob likes
#define BB_BASIC_FOODS "BB_BASIC_FOODS"
/// key holding any food we've found
#define BB_TARGET_FOOD "BB_TARGET_FOOD"
/// key holding emotes we play after eating
#define BB_EAT_EMOTES "BB_EAT_EMOTES"
/// key holding the next time we eat
#define BB_NEXT_FOOD_EAT "BB_NEXT_FOOD_EAT"
/// key holding our eating cooldown
#define BB_EAT_FOOD_COOLDOWN "BB_EAT_FOOD_COOLDOWN"

// Ventcrawling

/// key holding the turf we will move to
#define BB_VENTCRAWL_FINAL_TARGET "BB_VENTCRAWL_FINAL_TARGET"
/// key holding the vent we will move to
#define BB_VENTCRAWL_ENTRANCE "BB_VENTCRAWL_ENTRANCE"
/// key holding the vent we will ventcrawl to
#define BB_VENTCRAWL_EXIT "BB_VENTCRAWL_EXIT"
/// key holding a boolean value if we're entering into a vent
#define BB_VENTCRAWL_IS_ENTERING "BB_VENTCRAWL_IS_ENTERING"
/// key holding the amount of delay between steps in a vent (recommended: 1)
#define BB_VENTCRAWL_DELAY "BB_VENTCRAWL_DELAY"
/// key holding a range to look for vents (recommended: 10)
#define BB_VENT_SEARCH_RANGE "BB_VENT_SEARCH_RANGE"

// Tipped blackboards

/// Bool that means a basic mob will start reacting to being tipped in its planning
#define BB_BASIC_MOB_TIP_REACTING "BB_BASIC_TIP_REACTING"
/// the motherfucker who tipped us
#define BB_BASIC_MOB_TIPPER "BB_BASIC_TIP_TIPPER"

/// Is there something that scared us into being stationary? If so, hold the reference here
#define BB_STATIONARY_CAUSE "BB_THING_THAT_MADE_US_STATIONARY"
///How long should we remain stationary for?
#define BB_STATIONARY_SECONDS "BB_STATIONARY_TIME_IN_SECONDS"
///Should we move towards the target that triggered us to be stationary?
#define BB_STATIONARY_MOVE_TO_TARGET "BB_STATIONARY_MOVE_TO_TARGET"
/// What targets will trigger us to be stationary? Must be a list.
#define BB_STATIONARY_TARGETS "BB_STATIONARY_TARGETS"
/// How often can we get spooked by a target?
#define BB_STATIONARY_COOLDOWN "BB_STATIONARY_COOLDOWN"

// minebot keys
/// key that stores our toggle light ability
#define BB_MINEBOT_LIGHT_ABILITY "BB_MINEBOT_LIGHT_ABILITY"
/// key that stores our dump ore ability
#define BB_MINEBOT_DUMP_ABILITY "BB_MINEBOT_DUMP_ABILITY"
/// key that stores our target turf
#define BB_TARGET_MINERAL_TURF "BB_TARGET_MINERAL_TURF"
/// key that stores list of the turfs we ignore
#define BB_BLACKLIST_MINERAL_TURFS "BLACKLIST_MINERAL_TURFS"
/// key that stores the previous blocked wall
#define BB_PREVIOUS_UNREACHABLE_WALL "BB_PREVIOUS_UNREACHABLE_WALL"
/// key that stores our mining mode
#define BB_AUTOMATED_MINING "BB_AUTOMATED_MINING"
/// key that stores the nearest dead human
#define BB_NEARBY_DEAD_MINER "BB_NEARBY_DEAD_MINER"
/// key that holds the drone we defend
#define BB_DRONE_DEFEND "BB_DEFEND_DRONE"
/// key that holds the minimum distance before we flee
#define BB_MINIMUM_SHOOTING_DISTANCE "BB_MINIMUM_SHOOTING_DISTANCE"
/// key that holds the miner we must befriend
#define BB_MINER_FRIEND "BB_MINER_FRIEND"
/// should we auto protect?
#define BB_MINEBOT_AUTO_DEFEND "BB_MINEBOT_AUTO_DEFEND"
/// gibtonite wall we need to run away from
#define BB_MINEBOT_GIBTONITE_RUN "BB_MINEBOT_GIBTONITE_RUN"

/// Blackboard field for the most recent command the pet was given
#define BB_ACTIVE_PET_COMMAND "BB_ACTIVE_PET_COMMAND"

/// Blackboard field for what we actually want the pet to target
#define BB_CURRENT_PET_TARGET "BB_CURRENT_PET_TARGET"
/// Blackboard field for how we target things, as usually we want to be more permissive than normal
#define BB_PET_TARGETING_STRATEGY "BB_PET_TARGETING"
/// List of UIDs to mobs this mob is friends with, will follow their instructions and won't attack them
#define BB_FRIENDS_LIST "BB_FRIENDS_LIST"
/// List of strings we might say to encourage someone to make better choices.
#define BB_OWNER_SELF_HARM_RESPONSES "BB_SELF_HARM_RESPONSES"
/// List of strings used to apologize for attacking friends.
#define BB_OWNER_FRIENDLY_FIRE_APOLOGIES "BB_FF_APOLOGIES"


// Misc

/// For /datum/ai_behavior/find_potential_targets, what if any field are we using currently
#define BB_FIND_TARGETS_FIELD(type) "bb_find_targets_field_[type]"

/// key that tells the wall we will mine
#define BB_TARGET_MINERAL_WALL "BB_TARGET_MINERAL_WALL"
/// key that holds the ore we will eat
#define BB_ORE_TARGET "BB_ORE_TARGET"
/// which ore types we will not eat
#define BB_ORE_IGNORE_TYPES "BB_ORE_IGNORE_TYPES"
