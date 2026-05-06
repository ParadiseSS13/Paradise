/datum/ai_controller/flock
	planning_subtrees = list(
		/datum/ai_planning_subtree/goap/flock
	)

	ai_movement = /datum/ai_movement/astar


/datum/ai_controller/flock/drone
	planning_subtrees = list(
		/datum/ai_planning_subtree/goap/flockdrone
	)
