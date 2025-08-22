RESTRICT_TYPE(/datum/ui_module/admin/event_debug)

/datum/ui_module/admin/event_debug
	name = "Event Debug Screen"
	var/list/cached_data
	COOLDOWN_DECLARE(cache_cooldown)

/datum/ui_module/admin/event_debug/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EventDebug", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/admin/event_debug/ui_data(mob/user)
	if(COOLDOWN_FINISHED(src, cache_cooldown))
		update_cached_data()
		COOLDOWN_START(src, cache_cooldown, 1 SECONDS)
	return cached_data

/datum/ui_module/admin/event_debug/proc/update_cached_data()
	var/list/data = list()

	var/resources = get_total_resources()
	for(var/resource in resources)
		data["resources"] += list(list("name" = resource, "amount" = resources[resource]))

	var/net_resources = number_active_with_role()
	for(var/resource in net_resources)
		data["net_resources"] += list(list("name" = resource, "amount" = net_resources[resource]))

	data["containers"] = list()
	for(var/datum/event_container/container in SSevents.event_containers)
		var/list/container_data = list()
		container_data["severity"] = GLOB.severity_to_string[container.severity]
		var/list/events = list()
		for(var/datum/event_meta/meta_event in container.available_events)
			events += list(list("name" = meta_event.skeleton.name, "weight" = meta_event.get_weight(resources)))
		container_data["events"] = events
		data["containers"] += list(container_data)

	cached_data = data

/datum/ui_module/admin/event_debug/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("refresh")
			return TRUE
