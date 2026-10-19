/datum/ert_response_manager
	var/name = "ERT Response"
	var/survey_timer_duration_ds = 30 SECONDS
	var/survey_timer_id

	var/list/players = list()
	var/list/gender_prefs = list()
	var/list/species_prefs = list()
	var/list/role_prefs = list()

/datum/ert_response_manager/proc/add_candidate(mob/M)
	players |= M
	RegisterSignal(M, COMSIG_PARENT_QDELETING, PROC_REF(remove_candidate), TRUE)

/datum/ert_response_manager/proc/remove_candidate(mob/M)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	players -= M

/datum/ert_response_manager/proc/send_surveys()
	for(var/mob/player in players)
		gender_prefs[player] = "Random"
		species_prefs[player] = "Random"
		role_prefs[player] = GLOB.active_team.get_slot_list()
		ui_interact(player)

	// why the hell do only stoppable timers get IDs
	survey_timer_id = addtimer(
		CALLBACK(src, PROC_REF(finalize_surveys)), survey_timer_duration_ds, TIMER_STOPPABLE)

/datum/ert_response_manager/proc/finalize_surveys()
	for(var/mob/player in players)
		var/datum/tgui/ui = SStgui.get_open_ui(player, src)
		if(istype(ui))
			ui.close()

	perform_dispatch()

/datum/ert_response_manager/proc/get_time_remaining()
	return get_timer_remaining(survey_timer_id)

/datum/ert_response_manager/proc/perform_dispatch()
	var/spawn_index = 1

	for(var/i = 1, i <= length(players), i++)
		var/mob/player = players[i]
		if(spawn_index > length(GLOB.emergencyresponseteamspawn))
			break
		if(!length(GLOB.active_team.get_slot_list()))
			break

		if(!player || !player.client)
			continue
		if(player.client.is_afk())
			continue

		var/gender_pref = gender_prefs[player]
		var/species_pref = species_prefs[player]
		var/role_pref = role_prefs[player]

		for(var/role in role_pref)
			if(GLOB.active_team.check_slot_available(role))
				var/mob/living/new_commando = player.client.create_response_team_part_1(gender_pref, species_pref, role, GLOB.emergencyresponseteamspawn[spawn_index])
				GLOB.active_team.reduceSlots(role)
				spawn_index++
				if(!player || !new_commando)
					break
				new_commando.mind.key = player.key
				new_commando.key = player.key
				dust_if_respawnable(player)
				new_commando.update_icons()
				break

	GLOB.send_emergency_team = FALSE

	if(GLOB.active_team.count)
		GLOB.active_team.announce_team()
		reset()
		return
	// Everyone who said yes was afk
	GLOB.active_team.cannot_send_team()

	reset()

/datum/ert_response_manager/proc/reset()
	players.Cut()
	gender_prefs.Cut()
	species_prefs.Cut()
	role_prefs.Cut()
	survey_timer_id = null

/datum/ert_response_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ERTResponseForm", name)
		ui.open()

/datum/ert_response_manager/ui_data(mob/user)
	. = list()

	.["available_genders"] = list("Random", "Male", "Female", "Genderless")
	.["available_species"] = list("Random", "Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Skkulakin")
	.["chosen_gender"] = gender_prefs[user]
	.["chosen_species"] = species_prefs[user]
	.["ranked_roles"] = role_prefs[user]
	.["time_remaining_secs"] = floor(get_time_remaining() / 10)

/datum/ert_response_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("set_gender")
			gender_prefs[ui.user] = params["value"]
		if("set_species")
			species_prefs[ui.user] = params["value"]
		if("set_roles")
			role_prefs[ui.user] = params["items"]
		if("submit_prefs")
			ui.close()

	return TRUE
