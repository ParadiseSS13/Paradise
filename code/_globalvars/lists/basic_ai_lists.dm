/// All basic AI subtrees
GLOBAL_LIST_EMPTY(ai_subtrees)

/// Basic AI controllers based on status
GLOBAL_LIST_INIT(ai_controllers_by_status, list(
	AI_STATUS_ON = list(),
	AI_STATUS_OFF = list(),
	AI_STATUS_IDLE = list(),
))

/// Basic AI controllers based on their z level
GLOBAL_LIST_EMPTY(ai_controllers_by_zlevel)

/// Basic AI controllers that are currently performing idled behaviors
GLOBAL_LIST_INIT_TYPED(unplanned_controllers, /list/datum/ai_controller, list(
	AI_STATUS_ON = list(),
	AI_STATUS_IDLE = list(),
))
