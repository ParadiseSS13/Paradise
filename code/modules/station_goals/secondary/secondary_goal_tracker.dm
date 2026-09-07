/datum/secondary_goal_tracker
	var/datum/secondary_goal_progress/real_progress
	var/datum/secondary_goal_progress/temporary_progress
	var/datum/station_goal/secondary/goal
	var/registered = FALSE

/datum/secondary_goal_tracker/New(datum/station_goal/secondary/goal_in, datum/secondary_goal_progress/progress)
	goal = goal_in
	real_progress = progress
	temporary_progress = progress.Copy()

/datum/secondary_goal_tracker/proc/reset()
	real_progress = new real_progress.type(goal)
	temporary_progress = real_progress.Copy()
	if(!registered)
		register(SSshuttle.supply)

/datum/secondary_goal_tracker/proc/register(shuttle)
	RegisterSignal(shuttle, COMSIG_CARGO_BEGIN_SCAN,		PROC_REF(reset_tempporary_progress))
	RegisterSignal(shuttle, COMSIG_CARGO_BEGIN_SELL,		PROC_REF(reset_tempporary_progress))
	RegisterSignal(shuttle, COMSIG_CARGO_CHECK_SELL,		PROC_REF(check_for_progress))
	RegisterSignal(shuttle, COMSIG_CARGO_DO_PRIORITY_SELL,	PROC_REF(update_progress))
	RegisterSignal(shuttle, COMSIG_CARGO_SEND_ERROR,		PROC_REF(update_progress))
	RegisterSignal(shuttle, COMSIG_CARGO_END_SELL,			PROC_REF(check_for_completion))
	registered = TRUE

/datum/secondary_goal_tracker/proc/unregister(shuttle)
	UnregisterSignal(shuttle, COMSIG_CARGO_BEGIN_SCAN)
	UnregisterSignal(shuttle, COMSIG_CARGO_BEGIN_SELL)
	UnregisterSignal(shuttle, COMSIG_CARGO_CHECK_SELL)
	UnregisterSignal(shuttle, COMSIG_CARGO_DO_PRIORITY_SELL)
	UnregisterSignal(shuttle, COMSIG_CARGO_SEND_ERROR)
	UnregisterSignal(shuttle, COMSIG_CARGO_END_SELL)
	registered = FALSE

// Resets the temporary porgress to match the real progress.
/datum/secondary_goal_tracker/proc/reset_tempporary_progress(obj/docking_port/mobile/supply/shuttle)
	SIGNAL_HANDLER  // COMSIG_CARGO_BEGIN_SCAN, COMSIG_CARGO_BEGIN_SELL
	temporary_progress = real_progress.Copy()
	real_progress.start_shipment()

// Checks for temporary goal progress when selling a cargo item.
/datum/secondary_goal_tracker/proc/check_for_progress(obj/docking_port/mobile/supply/shuttle, atom/movable/thing)
	SIGNAL_HANDLER  // COMSIG_CARGO_CHECK_SELL
	return temporary_progress.update(thing)

// Update real goal progress when selling a cargo item.
/datum/secondary_goal_tracker/proc/update_progress(obj/docking_port/mobile/supply/shuttle, atom/movable/thing, datum/economy/cargo_shuttle_manifest/manifest)
	SIGNAL_HANDLER  // COMSIG_CARGO_DO_PRIORITY_SELL, COMSIG_CARGO_DO_SELL, COMSIG_CARGO_SEND_ERROR
	. = real_progress.update(thing, manifest)
	if(. & COMSIG_CARGO_SELL_PRIORITY)
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal.name, "items sold"))

/datum/secondary_goal_tracker/proc/check_for_completion(obj/docking_port/mobile/supply/shuttle, datum/economy/cargo_shuttle_manifest/manifest)
	SIGNAL_HANDLER  // COMSIG_CARGO_END_SELL
	if(real_progress.check_complete(manifest))
		goal.completed = TRUE
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal.name, "times completed"))
		unregister(SSshuttle.supply)


/datum/secondary_goal_progress
	var/personal_account
	var/goal_requester
	var/goal_name

/datum/secondary_goal_progress/proc/configure(datum/station_goal/secondary/goal)
	SHOULD_CALL_PARENT(TRUE)
	goal_requester = goal.requester_name
	personal_account = goal.personal_account
	goal_name = goal.name

/datum/secondary_goal_progress/proc/Copy()
	SHOULD_CALL_PARENT(TRUE)
	var/datum/secondary_goal_progress/copy = new type
	copy.personal_account = personal_account
	copy.goal_requester = goal_requester
	copy.goal_name = goal_name
	return copy

// Override for custom shipment start behavior
// (e.g. ampount-per-shipment tracking)
// Only called on the real progress tracker.
/datum/secondary_goal_progress/proc/start_shipment()
	return

// Check the item to see if it belongs to this goal.
// Update the manifest accodingly, if provided.
// Return values from code/__DEFINES/supply_defines.dm.
// Use COMSIG_CARGO_SELL_PRIORITY, not COMSIG_CARGO_SELL_NORMAL.
/datum/secondary_goal_progress/proc/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	return

// Check to see if this goal has been completed.
// Update the manifest accordingly.
// Returns whether the goal was completed.
/datum/secondary_goal_progress/proc/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	return FALSE

/datum/secondary_goal_progress/proc/check_goal_label(atom/movable/AM)
	// Look for a secondary goal label on this atom or anything it's inside.
	var/atom/current_layer = AM
	while(current_layer && isobj(current_layer))
		// If it has a goal label, check the label's owner.
		var/datum/component/label/goal/label = current_layer.GetComponent(/datum/component/label/goal)
		if(istype(label))
			return !goal_requester || label.person == goal_requester

		// Otherwise, move to whatever's holding us, and check again.
		var/datum/component/shelved/shelving = current_layer.GetComponent(/datum/component/shelved)
		var/obj/shelf = locateUID(shelving?.shelf_uid)
		if(istype(shelf))
			current_layer = shelf
		else
			current_layer = current_layer.loc
	return FALSE

/datum/secondary_goal_progress/proc/three_way_reward(datum/economy/cargo_shuttle_manifest/manifest, department, department_account, reward, message)
	SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "payments made"))
	SSblackbox.record_feedback("nested tally", "secondary goals", reward, list(goal_name, "credits"))

	var/datum/economy/line_item/supply_item = new
	supply_item.account = SSeconomy.cargo_account
	supply_item.credits = reward / 3
	supply_item.reason = message
	manifest.line_items += supply_item

	var/datum/economy/line_item/department_item = new
	department_item.account = department_account
	department_item.credits = reward / 3
	department_item.reason = message
	manifest.line_items += department_item

	var/datum/economy/line_item/personal_item = new
	personal_item.account = personal_account || department_account
	personal_item.credits = reward / 3
	personal_item.reason = message
	personal_item.requests_console_department = department
	manifest.line_items += personal_item

