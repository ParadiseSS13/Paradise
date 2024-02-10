/datum/ui_module/botcall/
	name = "Access Robot Control"
	var/mob/living/simple_animal/bot/Bot
	var/mob/living/silicon/ai/AI


/datum/ui_module/botcall/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BotCall", 700, 480, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/ui_module/botcall/ui_data(mob/user)
	var/list/data = ..()
	// Secbot
	var/list/secbot = list("name" = list(), "status" = list(), "location" = list())
	var/list/medbot = list("name" = list(), "status" = list(), "location" = list())
	var/list/cleanbot = list("name" = list(), "status" = list(), "location" = list())
	var/list/floorbot = list("name" = list(), "status" = list(), "location" = list())
	var/list/mule = list("name" = list(), "status" = list(), "location" = list())
	var/list/misc = list("name" = list(), "status" = list(), "location" = list())

	for(var/mob/living/simple_animal/bot/iterated in GLOB.bots_list)
		switch(iterated.type)
			if(/mob/living/simple_animal/bot/secbot, /mob/living/simple_animal/bot/ed209)
				secbot["name"] +=iterated.bot_name
				secbot["status"] += iterated.mode
				secbot["location"] += get_area(iterated)
			if(/mob/living/simple_animal/bot/medbot)
				medbot["name"] +=iterated.bot_name
				medbot["status"] += iterated.mode
				medbot["location"] += get_area(iterated)
			if(/mob/living/simple_animal/bot/cleanbot)
				cleanbot["name"] +=iterated.bot_name
				cleanbot["status"] += iterated.mode
				cleanbot["location"] += get_area(iterated)
			if(/mob/living/simple_animal/bot/floorbot)
				floorbot["name"] +=iterated.bot_name
				floorbot["status"] += iterated.mode
				floorbot["location"] += get_area(iterated)
			if(/mob/living/simple_animal/bot/mulebot)
				mule["name"] +=iterated.bot_name
				mule["status"] += iterated.mode
				mule["location"] += get_area(iterated)
			else
				misc["name"] +=iterated.bot_name
				misc["status"] += iterated.mode
				misc["location"] += get_area(iterated)

	data["secbot"] = list(
		"name" = secbot["name"],
		"status" = secbot["status"],
		"location" = secbot["location"],
	)
	data["medbot"] = list(
		"name" = medbot["name"],
		"status" = medbot["status"],
		"location" = medbot["location"],
	)
	data["cleanbot"] = list(
		"name" = cleanbot["name"],
		"status" = cleanbot["status"],
		"location" = cleanbot["location"],
	)
	data["floorbot"] = list(
		"name" = floorbot["name"],
		"status" = floorbot["status"],
		"location" = floorbot["location"],
	)
	data["mule"] = list(
		"name" = mule["name"],
		"status" = mule["status"],
		"location" = mule["location"],
	)
	data["misc"] = list(
		"name" = misc["name"],
		"status" = misc["status"],
		"location" = misc["location"],
	)
	return data

/datum/ui_module/botcall/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return
	if(AI.check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
	switch(action)
		if("interface")
			Bot = locate(params["interface"]) in GLOB.bots_list
			if(Bot)
				Bot.attack_ai(src)
		if("call")
			Bot = locate(params["call"]) in GLOB.bots_list
			if(!Bot || Bot.remote_disabled || AI.control_disabled)
				AI.waypoint_mode = TRUE
				to_chat(src, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")


//	var/d
//	var/area/bot_area
//	d += "<A HREF=?src=[UID()];botrefresh=\ref[Bot]>Query network status</A><br>"
//	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='20%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"
