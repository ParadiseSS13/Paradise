GLOBAL_DATUM_INIT(gpt220, /datum/gpt220, new())

/// AI Chatbot interface adapter
/datum/gpt220

/datum/gpt220/proc/request_completition(system_message, prompt, datum/callback/callback)
	var/endpoint = GLOB.configuration.gpt.endpoint
	var/list/body = json_encode(list(
		"messages" = list(
			list(
				"role" = "system",
				"content" = system_message
			),
			list(
				"role" = "user",
				"content" = prompt
			)
		),
		"temperature" = 0.1,
		"top_p" = 1,
		"max_tokens" = 100,
		"model" = GLOB.configuration.gpt.model
	))
	var/list/headers = list(
		"content-type" = "application/json",
		"authorization" = "Bearer [GLOB.configuration.gpt.access_token]"
	)

	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, endpoint, body, headers, callback)
