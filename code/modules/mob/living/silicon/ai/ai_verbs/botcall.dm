/datum/ui_module/botcall
	name = "Access Robot Control"

	var/mob/living/simple_animal/bot/bot
	var/mob/living/silicon/ai/AI

	var/list/secbot = list()
	var/list/medbot = list()
	var/list/cleanbot = list()
	var/list/floorbot = list()
	var/list/mule = list()
	var/list/misc = list()

/datum/ui_module/botcall/proc/bot_sort()
	for(bot in GLOB.bots_list)
		switch(bot.bot_type)
			if(SEC_BOT)
				secbot += bot.get_bot_data(bot)
			if(MED_BOT)
				medbot += bot.get_bot_data(bot)
			if(CLEAN_BOT)
				cleanbot += bot.get_bot_data(bot)
			if(FLOOR_BOT)
				floorbot += bot.get_bot_data(bot)
			if(MULE_BOT)
				mule += bot.get_bot_data(bot)
			if(HONK_BOT)
				misc += bot.get_bot_data(bot)
			else
				misc += bot.get_bot_data(bot)

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

/*
	bot_sort()
	data["Securitron"] = secbot
	data["Medibot"] = medbot
	data["Cleanbot"] = cleanbot
	data["Floorbot"] = floorbot
	data["MULE"] = mule
	data["Misc"] = misc
*/
	data["bots"] = list()
	for(bot in GLOB.bots_list)
		if(!(bot.model in data["bots"]))
			data["bots"][bot.model] = list()
		data["bots"][bot.model] += bot.get_bot_data()

	return data

/datum/ui_module/botcall/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
	bot = locateUID(params["botref"])
	if(!bot || bot.remote_disabled || AI.control_disabled)
		return
	switch(action)
		if("test_button")
			to_chat(world, "test button")
		if("interface")
			bot.attack_ai(src)
		if("call")
			AI.waypoint_mode = TRUE
			to_chat(src, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")


//	var/d
//	var/area/bot_area
//	d += "<A HREF=?src=[UID()];botrefresh=\ref[Bot]>Query network status</A><br>"
//	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='20%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"
