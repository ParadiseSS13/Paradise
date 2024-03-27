/datum/ui_module/botcall
	name = "Access Robot Control"

	var/mob/living/simple_animal/bot/bot
	var/mob/living/silicon/ai/AI
	var/mob/living/silicon/ai/active_AI

/datum/ui_module/botcall/ui_interact(mob/user)
	return GLOB.default_state

/datum/ui_module/botcall/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotCall")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/ui_module/botcall/ui_data(mob/user)
	var/list/data = ..()
	active_AI = user.UID()

	data["bots"] = list()
	for(bot in GLOB.bots_list)
		if(is_ai_allowed(bot.z) && !bot.remote_disabled)
			if(!(bot.model in data["bots"]))
				data["bots"][bot.model] = list()
			data["bots"][bot.model] += bot.get_bot_data()

	return data

/datum/ui_module/botcall/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
	var/selected_UID = params["botref"]
	switch(action)
		if("interface")
			to_chat(world, "interface")
			bot = locateUID(selected_UID)
			if(!bot || bot.remote_disabled || AI.control_disabled)
				return
			bot.attack_ai(usr)
		if("call")
			to_chat(world, "call")
			to_chat(world, "[usr]")
			to_chat(world, "[src]")
			to_chat(world, "[active_AI]")
			bot = locateUID(selected_UID)
			if(!bot || bot.remote_disabled || AI.control_disabled)
				return
			to_chat(world, "call")
			to_chat(world, "[usr]")
			to_chat(world, "[src]")
			to_chat(world, "[active_AI]")
			to_chat(world, "2x")
			active_AI.waypoint_mode = TRUE
			to_chat(active_AI, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")
