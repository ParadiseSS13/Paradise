/datum/preferences
	var/static/list/explorer_users = list()

/datum/preferences/New(client/C, datum/db_query/Q)
	. = ..()
	volume_mixer |= (list(
		"[CHANNEL_TTS_RADIO]" = 20, // CHANNEL_TTS_RADIO
		"[CHANNEL_TTS_LOCAL]" = 50, // CHANNEL_TTS_LOCAL
	))

/datum/character_save
	var/tts_seed

/datum/character_save/copy_to(mob/living/carbon/human/character)
	. = ..()
	if(tts_seed)
		var/datum/tts_seed/new_tts_seed = SStts220.tts_seeds[tts_seed]
		character.AddComponent(/datum/component/tts_component, new_tts_seed)
		character.dna.tts_seed_dna = new_tts_seed

/datum/ui_module/tts_seeds_explorer
	name = "Эксплорер TTS голосов"
	var/phrases = TTS_PHRASES

/datum/ui_module/tts_seeds_explorer/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/tts_seeds_explorer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TTSSeedsExplorer", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/tts_seeds_explorer/ui_data(mob/user)
	var/list/data = list()
	data["selected_seed"] = user.client.prefs.active_character.tts_seed
	data["donator_level"] = user.client.donator_level
	data["character_gender"] = user.client.prefs.active_character.gender

	return data

/datum/ui_module/tts_seeds_explorer/ui_static_data(mob/user)
	var/list/data = list()

	var/list/providers = list()
	for(var/_provider in SStts220.tts_providers)
		var/datum/tts_provider/provider = SStts220.tts_providers[_provider]
		providers += list(list(
			"name" = provider.name,
			"is_enabled" = provider.is_enabled,
		))
	data["providers"] = providers

	var/list/seeds = list()
	for(var/_seed in SStts220.tts_seeds)
		var/datum/tts_seed/seed = SStts220.tts_seeds[_seed]
		seeds += list(list(
			"name" = seed.name,
			"value" = seed.value,
			"category" = seed.category,
			"gender" = seed.gender,
			"provider" = initial(seed.provider.name),
			"required_donator_level" = seed.required_donator_level,
		))
	data["seeds"] = seeds
	data["phrases"] = phrases

	return data

/datum/ui_module/tts_seeds_explorer/ui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("listen")
			var/phrase = params["phrase"]
			var/seed_name = params["seed"]

			if(!(phrase in phrases))
				return
			if(!(seed_name in SStts220.tts_seeds))
				return

			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, usr, phrase, SStts220.tts_seeds[seed_name], FALSE)
		if("select")
			var/seed_name = params["seed"]

			if(!(seed_name in SStts220.tts_seeds))
				return
			var/datum/tts_seed/seed = SStts220.tts_seeds[seed_name]
			if(usr.client.donator_level < seed.required_donator_level)
				return

			usr.client.prefs.active_character.tts_seed = seed_name
		else
			return FALSE

/mob/new_player/proc/check_tts_seed_ready()
	if(GLOB.configuration.tts.tts_enabled)
		if(!client.prefs.active_character.tts_seed)
			to_chat(usr, span_danger("Вам необходимо настроить голос персонажа! Не забудьте сохранить настройки."))
			client.prefs.ShowChoices(src)
			return FALSE
		var/datum/tts_seed/seed = SStts220.tts_seeds[client.prefs.active_character.tts_seed]
		if(!seed)
			to_chat(usr, span_danger("Выбранный голос персонажа недоступен!"))
			client.prefs.ShowChoices(src)
			return FALSE

		switch(client.donator_level)
			if(LITTLE_WORKER_TIER)
				if(LITTLE_WORKER_TTS_LEVEL >= seed.required_donator_level)
					return TRUE
			if(BIG_WORKER_TIER)
				if(BIG_WORKER_TTS_LEVEL >= seed.required_donator_level)
					return TRUE

		if(client.donator_level < seed.required_donator_level || client.donator_level > DONATOR_LEVEL_MAX)
			to_chat(usr, span_danger("Выбранный голос персонажа более недоступен на текущем уровне подписки!"))
			client.prefs.ShowChoices(src)
			return FALSE
	return TRUE
