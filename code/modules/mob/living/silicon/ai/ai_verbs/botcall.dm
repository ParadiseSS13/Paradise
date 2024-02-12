/datum/ui_module/botcall
	name = "Access Robot Control"
	var/mob/living/simple_animal/bot/Bot
	var/mob/living/silicon/ai/AI

/datum/ui_module/botcall/proc/add_to_list(list_name, iterated)
	list_name += list(list(
	"name" = iterated.bot_name,
	"model" = iterated.model,
	"status" = iterated.mode,
	"location" = get_area(iterated),
	"UID" = iterated.UID()
	))

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
	var/list/secbot = list()
	var/list/medbot = list()
	var/list/cleanbot = list()
	var/list/floorbot = list()
	var/list/mule = list()
	var/list/misc = list()

	for(var/mob/living/simple_animal/bot/iterated in GLOB.bots_list)
		switch(iterated.bot_type)
			if(SEC_BOT)
				secbot += list(list(
					"name" = iterated.bot_name,
					"model" = iterated.model,
					"status" = iterated.mode,
					"location" = get_area(iterated),
					"UID" = iterated.UID()
					))
			if(MED_BOT)
				medbot += list(list(
					"name" = iterated.bot_name,
					"model" = iterated.model,
					"status" = iterated.mode,
					"location" = get_area(iterated),
					"UID" = iterated.UID()
					))
			if(CLEAN_BOT)
				cleanbot += list(list(
					"name" = iterated.bot_name,
					"model" = iterated.model,
					"status" = iterated.mode,
					"location" = get_area(iterated),
					"UID" = iterated.UID()
					))
			if(FLOOR_BOT)
				floorbot += list(list(
					"name" = iterated.bot_name,
					"model" = iterated.model,
					"status" = iterated.mode,
					"location" = get_area(iterated),
					"UID" = iterated.UID()
					))
			if(MULE_BOT)
				mule += list(list(
					"name" = iterated.bot_name,
					"model" = iterated.model,
					"status" = iterated.mode,
					"location" = get_area(iterated),
					"UID" = iterated.UID()
					))
			if(HONK_BOT)
				misc += list(list(
					"name" = iterated.bot_name,
					"model" = iterated.model,
					"status" = iterated.mode,
					"location" = get_area(iterated),
					"UID" = iterated.UID()
					))

	data["secbot"] = secbot
	data["medbot"] = medbot
	data["cleanbot"] = cleanbot
	data["floorbot"] = floorbot
	data["mule"] = mule
	data["misc"] = misc
	return data

/datum/ui_module/botcall/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
	Bot = locateUID(params["botref"])
	if(!Bot || Bot.remote_disabled || AI.control_disabled)
		return
	switch(action)
		if("test_button")
			to_chat(world, "test button")
		if("interface")
			Bot.attack_ai(src)
		if("call")
			AI.waypoint_mode = TRUE
			to_chat(src, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")


//	var/d
//	var/area/bot_area
//	d += "<A HREF=?src=[UID()];botrefresh=\ref[Bot]>Query network status</A><br>"
//	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='20%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"
