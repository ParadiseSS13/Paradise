GLOBAL_LIST_EMPTY(event_trackers)

/datum/component/event_tracker
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Category to list the event thing under
	var/category = ""

/datum/component/event_tracker/Initialize(_category)
	if(!_category)
		category = "misc"
	else
		category = _category
	GLOB.event_trackers["[category]"] += list(src)

/datum/component/event_tracker/Destroy()
	GLOB.event_trackers["[category]"] -= list(src)
	return ..()

/datum/component/event_tracker/proc/event_cost()
	var/atom/thing = parent
	return thing.event_cost()
