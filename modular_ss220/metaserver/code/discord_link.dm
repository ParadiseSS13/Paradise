/datum/preferences
	var/discord_id

/datum/preferences/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, discord_id))
		return FALSE
	return ..()

/client/New()
	. = ..()
	SScentral.get_player_discord_async(src)

/client/verb/verify_in_discord_central()
	set category = "Special Verbs"
	set name = "Привязать Discord"
	set desc = "Привязка аккаунта Discord к BYOND"

	if(!SScentral.initialized)
		to_chat(src, span_warning("Привязка Discord сейчас недоступна."))
		return

	if(SScentral.is_player_discord_linked(src))
		to_chat(src, span_warning("Вы уже привязали свою учетную запись Discord."))
		return

	to_chat(src, span_notice("Пытаемся получить токен для входа в Discord..."))
	SScentral.verify_in_discord(src)

/datum/controller/subsystem/central/proc/verify_in_discord(client/player)
	var/endpoint = "[GLOB.configuration.central.api_url]/oauth/token?ckey=[player.ckey]"
	var/list/headers = list(
		"Authorization" = "Bearer [GLOB.configuration.central.api_token]"
	)
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, endpoint, "", headers, CALLBACK(SScentral, PROC_REF(verify_in_discord_callback), player))

/datum/controller/subsystem/central/proc/verify_in_discord_callback(client/player, datum/http_response/response)
	if(response.errored || response.status_code != 201)
		stack_trace("Failed to get discord verification token: HTTP status code [response.status_code] - [response.error]")
		return

	var/list/data = json_decode(response.body)
	var/login_endpoint = "[GLOB.configuration.central.api_url]/oauth/login?token=[data]"

	to_chat(player, chat_box_regular("Авторизуйтесь в открывшемся окне и ожидайте 30 секунд.<br/>Если окно не открывается, можете открыть ссылку в браузере самостоятельно:<br/><a href='[login_endpoint]'>Привязать дискорд.</a>."))
	player << link(login_endpoint)
	SScentral.get_player_discord_async(player)
	addtimer(CALLBACK(SScentral, TYPE_PROC_REF(/datum/controller/subsystem/central, get_player_discord_async), player), 30 SECONDS)
