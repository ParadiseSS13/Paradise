/// The subsystem used to tick [/datum/ai_behavior] instances.
/// Handling the individual actions an AI can take like punching someone in the fucking NUTS
PROCESSING_SUBSYSTEM_DEF(ai_behaviors)
	name = "AI Behavior Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC_ACTIONS
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 1
	/// List of all ai_behavior singletons, key is the typepath while assigned
	/// value is a newly created instance of the typepath. See setup_ai_behaviors().
	var/list/ai_behaviors
	/// List of all targeting_strategy singletons, key is the typepath while assigned
	/// value is a newly created instance of the typepath. See setup_targeting_strats().
	var/list/targeting_strategies

/datum/controller/subsystem/processing/ai_behaviors/Initialize()
	setup_ai_behaviors()
	setup_targeting_strats()

/datum/controller/subsystem/processing/ai_behaviors/proc/setup_ai_behaviors()
	ai_behaviors = list()
	for(var/behavior_type in subtypesof(/datum/ai_behavior))
		var/datum/ai_behavior/ai_behavior = new behavior_type
		ai_behaviors[behavior_type] = ai_behavior

/datum/controller/subsystem/processing/ai_behaviors/proc/setup_targeting_strats()
	targeting_strategies = list()
	for(var/target_type in subtypesof(/datum/targeting_strategy))
		var/datum/targeting_strategy/target_start = new target_type
		targeting_strategies[target_type] = target_start
