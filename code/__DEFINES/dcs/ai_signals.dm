///sent from ai controllers when a behavior is inserted into the queue: (list/new_arguments)
#define AI_CONTROLLER_BEHAVIOR_QUEUED(type) "ai_controller_behavior_queued_[type]"

/// Signal sent when a blackboard key is set to a new value
#define COMSIG_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"

///Signal sent before a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_PRECLEAR(blackboard_key) "ai_blackboard_key_pre_clear_[blackboard_key]"

/// Signal sent when a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"

//from base of atom/attack_basic_mob(): (/mob/user)
#define COMSIG_ATOM_ATTACK_BASIC_MOB "attack_basic_mob"
	#define COMPONENT_BASIC_ATTACK_CANCEL_CHAIN (1<<0)

///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they pick behaviors: (list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
#define COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS "ai_controller_picked_behaviors"
