/datum/ui_module/tts_seeds_explorer
	name = "Эксплорер TTS голосов"

/datum/ui_module/tts_seeds_explorer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "TTSSeedsExplorer", name, 350, 700, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/tts_seeds_explorer/ui_data(mob/user)
	var/list/data = list()

	data["selected_seed"] = user.client.prefs.tts_seed

	return data

/datum/ui_module/tts_seeds_explorer/ui_static_data(mob/user)
	var/list/data = list()

	var/list/providers = list()
	for(var/_provider in SStts.tts_providers)
		var/datum/tts_provider/provider = SStts.tts_providers[_provider]
		providers += list(list(
			"name" = provider.name,
			"is_enabled" = provider.is_enabled,
		))
	data["providers"] = providers

	var/list/seeds = list()
	for(var/_seed in SStts.tts_seeds)
		var/datum/tts_seed/seed = SStts.tts_seeds[_seed]
		seeds += list(list(
			"name" = seed.name,
			"value" = seed.value,
			"category" = seed.category,
			"gender" = seed.gender,
			"provider" = initial(seed.provider.name),
		))
	data["seeds"] = seeds

	data["phrases"] = list(
		"Так звучит мой голос.",
		"Так я звучу.",
		"Я.",
		"Поставьте свою подпись.",
		"Пора за работу.",
		"Дело сделано.",
		"Станция Нанотрейзен.",
		"Офицер СБ.",
		"Капитан.",
		"Вульпканин.",
		"Съешь же ещё этих мягких французских булок, да выпей чаю.",
		"Клоун, прекрати разбрасывать банановые кожурки офицерам под ноги!",
		"Капитан, вы уверены что хотите назначить клоуна на должность главы персонала?"
		)

	return data

/datum/ui_module/tts_seeds_explorer/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("listen")
			var/phrase = params["phrase"]
			var/seed = params["seed"]
			INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, usr, phrase, seed, FALSE)
		if("select")
			var/seed = params["seed"]
			usr.client.prefs.tts_seed = seed
		else
			return FALSE

