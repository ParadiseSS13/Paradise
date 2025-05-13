// Generic blackboard keys.

// Movement

/// The closest we're allowed to / required to get to a target.
#define BB_CURRENT_MIN_MOVE_DISTANCE "BB_min_move_distance"
/// How likely is this mob to move when idle per tick?
#define BB_BASIC_MOB_IDLE_WALK_CHANCE "BB_basic_idle_walk_chance"
/// Flag to set on if you want your mob to STOP running away
#define BB_BASIC_MOB_STOP_FLEEING "BB_basic_stop_fleeing"
/// Key of something we're running away from
#define BB_BASIC_MOB_FLEE_TARGET "BB_basic_flee_target"
/// Key for the current hidden location of something we're running away from
#define BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION "BB_basic_flee_target_hiding_location"
/// Key defining the targeting strategy for things to flee from
#define BB_FLEE_TARGETING_STRATEGY "BB_flee_targeting_strategy"
/// Key defining how far we attempt to get away from something we're fleeing from
#define BB_BASIC_MOB_FLEE_DISTANCE "BB_basic_flee_distance"
#define DEFAULT_BASIC_FLEE_DISTANCE 9

// Searching

/// key holding a range to look for stuff in
#define BB_SEARCH_RANGE "BB_search_range"

// Targeting

/// How close a mob must be for us to select it as a target, if that is less than how far we can maintain it as a target
#define BB_AGGRO_RANGE "BB_aggro_range"
/// Key for our current target.
#define BB_BASIC_MOB_CURRENT_TARGET "BB_basic_current_target"
/// Key for the current hidden location of our target if applicable.
#define BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION "BB_basic_current_target_hiding_location"
/// Key for the type of targeting strategy we will apply.
#define BB_TARGETING_STRATEGY "targeting_strategy"
/// Key for the minimum status at which we want to target mobs (does not need to be specified if CONSCIOUS)
#define BB_TARGET_MINIMUM_STAT "BB_target_minimum_stat"
/// Should we skip the faction check for the targeting strategy?
#define BB_ALWAYS_IGNORE_FACTION "BB_always_ignore_factions"
/// Are we in some kind of temporary state of ignoring factions when targeting? can result in volatile results if multiple behaviours touch this
#define BB_TEMPORARILY_IGNORE_FACTION "BB_temporarily_ignore_factions"
///List of mobs who have damaged us
#define BB_BASIC_MOB_RETALIATE_LIST "BB_basic_mob_shitlist"

//Hunting BB keys

/// Key that holds our current hunting target
#define BB_CURRENT_HUNTING_TARGET "BB_current_hunting_target"
/// Key that holds our less priority hunting target
#define BB_LOW_PRIORITY_HUNTING_TARGET "BB_low_priority_hunting_target"
/// Key that holds the cooldown for our hunting subtree
#define BB_HUNTING_COOLDOWN(type) "BB_HUNTING_COOLDOWN_[type]"

// Food and eating

/// list of foods this mob likes
#define BB_BASIC_FOODS "BB_basic_foods"
/// key holding any food we've found
#define BB_TARGET_FOOD "BB_target_food"
/// key holding emotes we play after eating
#define BB_EAT_EMOTES "BB_eat_emotes"
/// key holding the next time we eat
#define BB_NEXT_FOOD_EAT "BB_next_food_eat"
/// key holding our eating cooldown
#define BB_EAT_FOOD_COOLDOWN "BB_eat_food_cooldown"

// Tipped blackboards

/// Bool that means a basic mob will start reacting to being tipped in its planning
#define BB_BASIC_MOB_TIP_REACTING "BB_basic_tip_reacting"
/// the motherfucker who tipped us
#define BB_BASIC_MOB_TIPPER "BB_basic_tip_tipper"

/// Is there something that scared us into being stationary? If so, hold the reference here
#define BB_STATIONARY_CAUSE "BB_thing_that_made_us_stationary"
///How long should we remain stationary for?
#define BB_STATIONARY_SECONDS "BB_stationary_time_in_seconds"
///Should we move towards the target that triggered us to be stationary?
#define BB_STATIONARY_MOVE_TO_TARGET "BB_stationary_move_to_target"
/// What targets will trigger us to be stationary? Must be a list.
#define BB_STATIONARY_TARGETS "BB_stationary_targets"
/// How often can we get spooked by a target?
#define BB_STATIONARY_COOLDOWN "BB_stationary_cooldown"

// Misc

/// For /datum/ai_behavior/find_potential_targets, what if any field are we using currently
#define BB_FIND_TARGETS_FIELD(type) "bb_find_targets_field_[type]"
