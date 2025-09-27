/datum/ui_module/ai_controller_debugger
	name = "AI Controller Debugger"
	var/datum/ai_controller/controller
	var/paused = FALSE
	var/list/data = list()

/datum/ui_module/ai_controller_debugger/New(datum/ai_controller/controller_)
	..()
	if(!istype(controller_))
		stack_trace("Attempted to create an AI controller debugger on an invalid target!")
		qdel(src)
		return

	controller = controller_

/datum/ui_module/ai_controller_debugger/ui_state(mob/user)
	return GLOB.default_state

/datum/ui_module/ai_controller_debugger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AIControllerDebugger", name)
		ui_data(user)
		ui.open()

/datum/ui_module/ai_controller_debugger/ui_data(mob/user)
	data["paused"] = paused
	if(paused)
		return data

	data["controller"] = list(
		"type" = "[controller.type]",
		"current_behaviors" = list(),
		"planned_behaviors" = list(),
		"blackboard" = list(),
	)
	if(controller.pawn)
		data["controller"]["pawn"] = list(
			"name" = "[controller.pawn]",
			"uid" = controller.pawn.UID(),
		)
	data["controller"]["type"] = "[controller.type]"
	data["controller"]["idle_behavior"] = "[controller.idle_behavior]"
	data["controller"]["movement"] = "[controller.ai_movement]"
	var/datum/movement_target = controller.current_movement_target
	if(istype(movement_target))
		data["controller"]["movement_target"] = list(
			"name" = "[movement_target]",
			"uid" = "[movement_target.UID()]",
			"source" = "[controller.movement_target_source]",
		)
	if(LAZYLEN(controller.current_behaviors))
		for(var/datum/ai_behavior/behavior in controller.current_behaviors)
			data["controller"]["current_behaviors"] += "[behavior.type]"

	if(LAZYLEN(controller.planned_behaviors))
		for(var/datum/ai_behavior/behavior in controller.planned_behaviors)
			data["controller"]["planned_behaviors"] += "[behavior.type]"

	for(var/name in controller.blackboard)
		var/value = controller.blackboard[name]

		var/list/item = list(
			"name" = name,
			"value" = "[value]",
		)
		var/datum/valid_uid = locateUID(value)
		if(istype(valid_uid))
			item["uid"] = value
		if(isdatum(value))
			var/datum/D = value
			item["uid"] = D.UID()
		if(islist(value))
			item["value"] = json_encode(value)
		data["controller"]["blackboard"] += list(item)
	return data

/datum/ui_module/ai_controller_debugger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("vv")
			ui.user.client.debug_variables(locateUID(params["uid"]))
		if("flw")
			ghost_follow_uid(ui.user, params["uid"])

	return TRUE
