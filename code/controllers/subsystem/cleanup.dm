/**
 * # Cleanup Subsystem
 *
 * For now, all it does is periodically clean the supplied global lists of any null values they may contain.
 *
 * Why is this important?
 *
 * Sometimes, these lists can gain nulls due to errors.
 * For example, when a dead player trasitions from the `dead_mob_list` to the `alive_mob_list`, a null value may get stuck in the dead mob list.
 * This can cause issues when other code tries to do things with the values in the list, but are instead met with null values.
 * These problems are incredibly hard to track down and fix, so this subsystem is a solution to that.
 */
SUBSYSTEM_DEF(cleanup)
	name = "Null cleanup"
	wait = 30 SECONDS
	flags = SS_POST_FIRE_TIMING
	priority = FIRE_PRIORITY_CLEANUP
	init_order = INIT_ORDER_CLEANUP
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "Certain global lists will no longer be cleared of nulls, which may result in runtimes. No immediate action is needed."
	/// A list of global lists we want the subsystem to clean.
	var/list/lists_to_clean

/datum/controller/subsystem/cleanup/Initialize(start_timeofday)
	// If you want this subsystem to clean out nulls from a specific list, add it here.
	lists_to_clean = list(
		GLOB.clients = "clients",
		GLOB.player_list = "player_list",
		GLOB.mob_list = "mob_list",
		GLOB.alive_mob_list = "alive_mob_list",
		GLOB.dead_mob_list = "dead_mob_list",
		GLOB.human_list = "human_list",
		GLOB.carbon_list = "carbon_list"
	)
	return ..()

/datum/controller/subsystem/cleanup/fire(resumed)
	for(var/L in lists_to_clean)
		var/list/_list = L
		var/prev_length = length(_list)
		listclearnulls(_list)

		if(length(_list) < prev_length)
			stack_trace("Found a null value in GLOB.[lists_to_clean[_list]]!")
