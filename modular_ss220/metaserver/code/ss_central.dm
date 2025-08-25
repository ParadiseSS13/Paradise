/datum/server_configuration
	/// Holder for the central configuration datum
	var/datum/configuration_section/central/central

/datum/configuration_section/central
	protection_state = PROTECTION_PRIVATE
	var/api_url = ""
	var/api_token = ""
	var/server_type = ""
	var/force_discord_verification = FALSE

/datum/server_configuration/load_all_sections()
	. = ..()
	central = new()
	safe_load(central, "central_configuration")

/datum/configuration_section/central/load_data(list/data)
	CONFIG_LOAD_STR(api_url, data["api_url"])
	CONFIG_LOAD_STR(api_token, data["api_token"])
	CONFIG_LOAD_STR(server_type, data["server_type"])
	CONFIG_LOAD_BOOL(force_discord_verification, data["force_discord_verification"])

SUBSYSTEM_DEF(central)
	var/list/discord_links = list()
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DBCORE

/datum/controller/subsystem/http
	init_order = INIT_ORDER_DBCORE

/datum/controller/subsystem/central/Initialize()
	if(!(GLOB.configuration.central.api_url && GLOB.configuration.central.api_token))
		return
	load_whitelist()
	// TODO: Preload links

/datum/controller/subsystem/central/stat_entry(msg)
	if(!initialized)
		msg = "OFFLINE"
	else
		msg = "[GLOB.configuration.central.server_type]"
	return ..()

/datum/controller/subsystem/central/proc/load_whitelist()
	var/endpoint = "[GLOB.configuration.central.api_url]/whitelists/ckeys?sever_type=[GLOB.configuration.central.server_type]&active_only=true&page=1&page_size=9999"

	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_GET, endpoint, "", list(), CALLBACK(src, PROC_REF(load_whitelist_callback)))

/datum/controller/subsystem/central/proc/load_whitelist_callback(datum/http_response/response)
	if(response.errored || response.status_code != 200)
		stack_trace("Failed to load whitelist: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	var/list/result = json_decode(response.body)

	log_game("Loading whitelist with [result["total"]] entries")

	var/list/ckeys = result["items"]

	GLOB.configuration.overflow.overflow_whitelist = ckeys

/datum/controller/subsystem/central/proc/get_player_discord_async(client/player)
	var/endpoint = "[GLOB.configuration.central.api_url]/players/ckey/[player.ckey]"

	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_GET, endpoint, "", list(), CALLBACK(src, PROC_REF(get_player_discord_callback), player))

/datum/controller/subsystem/central/proc/get_player_discord_callback(client/player, datum/http_response/response)
	if(response.errored || response.status_code != 200 && response.status_code != 404)
		stack_trace("Failed to get player discord: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	if(response.status_code == 404)
		return

	var/list/data = json_decode(response.body)
	var/discord_id = data["discord_id"]
	var/ckey = data["ckey"]
	discord_links[ckey] = discord_id

	player.prefs.discord_id = discord_id

/datum/controller/subsystem/central/proc/is_player_discord_linked(client/player)
	if(!player)
		return FALSE

	if(player.prefs.discord_id)
		return TRUE

	// If player somehow losed its id. Not sure if needed
	if(SScentral.discord_links[player.ckey])
		player.prefs.discord_id = SScentral.discord_links[player.ckey]
		return TRUE

	// Update the info just in case
	SScentral.get_player_discord_async(player)

	return FALSE

/// WARNING: only semi async - UNTIL based
/datum/controller/subsystem/central/proc/is_player_whitelisted(ckey)
	if(ckey in GLOB.configuration.overflow.overflow_whitelist)
		return TRUE

	var/endpoint = "[GLOB.configuration.central.api_url]/whitelists?sever_type=[GLOB.configuration.central.server_type]&ckey=[ckey]&page=1&page_size=1"
	var/datum/http_response/response = SShttp.make_sync_request(RUSTLIBS_HTTP_METHOD_GET, endpoint, "", list())
	if(response.errored || response.status_code != 200 && response.status_code != 404)
		stack_trace("Failed to check whitelist: HTTP error - [response.error]")
	if(response.status_code == 404)
		return FALSE

	var/result = json_decode(response.body)

	return result["total"]

/datum/controller/subsystem/central/proc/add_to_whitelist(ckey, added_by, duration_days = 0)
	var/endpoint = "[GLOB.configuration.central.api_url]/whitelists"

	var/list/headers = list()
	headers["Authorization"] = "Bearer [GLOB.configuration.central.api_token]"
	var/list/body = list()
	body["player_ckey"] = ckey
	body["admin_ckey"] = added_by
	body["sever_type"] = GLOB.configuration.central.server_type
	body["duration_days"] = duration_days

	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, endpoint, json_encode(body), headers, CALLBACK(src, PROC_REF(add_to_whitelist_callback), ckey))

/datum/controller/subsystem/central/proc/add_to_whitelist_callback(ckey, datum/http_response/response)
	if(response.errored)
		stack_trace("Failed to add to whitelist: HTTP error - [response.error]")

	switch(response.status_code)
		if(201)
			. = . // noop
		if(404)
			message_admins("Не удалось добавить [ckey] в вайтлист: Игрок не найден")
			return

		if(409)
			message_admins("Не удалось добавить [ckey] в вайтлист: Игрок выписан")
			return

		else
			stack_trace("Could not add to whitelist: HTTP status code [response.status_code] - [response.body]")
			return

	log_admin("Игрок [ckey] успешно добавлен в вайтлист")
	GLOB.configuration.overflow.overflow_whitelist |= ckey

/datum/controller/subsystem/central/proc/whitelist_ban_player(player_ckey, admin_ckey, duration_days, reason)
	var/endpoint = "[GLOB.configuration.central.api_url]/whitelist_bans"

	var/list/headers = list()
	headers["Authorization"] = "Bearer [GLOB.configuration.central.api_token]"
	var/list/body = list()
	body["player_ckey"] = player_ckey
	body["admin_ckey"] = admin_ckey
	body["sever_type"] = GLOB.configuration.central.server_type
	body["duration_days"] = duration_days
	body["reason"] = reason

	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, endpoint, json_encode(body), headers, CALLBACK(src, PROC_REF(whitelist_ban_player_callback), player_ckey))

/datum/controller/subsystem/central/proc/whitelist_ban_player_callback(ckey, datum/http_response/response)
	if(response.errored || response.status_code != 201)
		stack_trace("Failed to ban player from whitelist: HTTP status code [response.status_code] - [response.error] - [response.body]")
		message_admins("Не удалось выписать [ckey]. Больше информации в рантаймах.")
		return

	GLOB.configuration.overflow.overflow_whitelist -= ckey

/datum/controller/subsystem/central/proc/update_player_donate_tier_async(client/player)
	var/endpoint = "[GLOB.configuration.central.api_url]/donates?ckey=[player.ckey]&active_only=true&page=1&page_size=1"
	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_GET, endpoint, "", list(), CALLBACK(src, PROC_REF(update_player_donate_tier_callback), player))

/datum/controller/subsystem/central/proc/update_player_donate_tier_callback(client/player, datum/http_response/response)
	if(response.errored || response.status_code != 200)
		stack_trace("Failed to get player donate tier: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	var/list/data = json_decode(response.body)
	player.donator_level = max(player.donator_level, get_max_donation_tier_from_response_data(data))

/datum/controller/subsystem/central/proc/get_player_donate_tier_blocking(client/player)
	var/endpoint = "[GLOB.configuration.central.api_url]/donates?ckey=[player.ckey]&active_only=true&page=1&page_size=1"
	var/datum/http_response/response = SShttp.make_sync_request(RUSTLIBS_HTTP_METHOD_GET, endpoint, "", list())
	if(response.errored || response.status_code != 200)
		stack_trace("Failed to get player donate tier: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return 0

	var/list/data = json_decode(response.body)
	return max(player.donator_level, get_max_donation_tier_from_response_data(data))

/datum/controller/subsystem/central/proc/get_max_donation_tier_from_response_data(list/data)
	if(!length(data["items"]))
		return 0

	var/list/tiers = list()
	for(var/list/item in data["items"])
		tiers += item["tier"]

	return max(tiers)
