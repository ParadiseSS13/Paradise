/datum/game_mode/can_start()
	var/latest_gamemode = get_latest_gamemode()
	var/list/non_repeatable_gamemodes = GLOB.configuration.gamemode.non_repeatable_gamemodes
	if((type in non_repeatable_gamemodes) && (latest_gamemode in non_repeatable_gamemodes))
		return FALSE
	return ..()

/// Returns type of the last gamemode played.
/datum/game_mode/proc/get_latest_gamemode()
	var/static/latest_gamemode
	if(!isnull(latest_gamemode))
		return latest_gamemode

	if(!SSdbcore.IsConnected())
		return null

	var/datum/db_query/query_latest_gamemode = SSdbcore.NewQuery(
		"SELECT game_mode \
		FROM round \
		WHERE server_id = :server_id \
			AND id < :round_id \
			AND game_mode IS NOT NULL \
		ORDER BY id DESC \
		LIMIT 1",
		list(
			"server_id" = GLOB.configuration.system.instance_id,
			"round_id" = GLOB.round_id
		)
	)
	if(!query_latest_gamemode.warn_execute() || !query_latest_gamemode.NextRow())
		qdel(query_latest_gamemode)
		return null

	var/latest_gamemode_name = query_latest_gamemode.item[1]
	qdel(query_latest_gamemode)
	latest_gamemode = GLOB.configuration.gamemode.get_mode_by_name(latest_gamemode_name)
	return latest_gamemode
