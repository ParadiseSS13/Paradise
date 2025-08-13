/datum/server_configuration
	/// Holder for the tts configuration datum
	var/datum/configuration_section/tts_configuration/tts

/datum/server_configuration/load_all_sections()
	. = ..()
	tts = new()
	safe_load(tts, "tts_configuration")

/datum/configuration_section/tts_configuration
	protection_state = PROTECTION_PRIVATE
	/// Is TTS enabled
	var/tts_enabled = FALSE
	/// TTS API token for silero provider
	var/tts_token_silero = ""
	/// TTS API url for silero provide
	var/tts_api_url_silero = "http://s2.ss220.club:9999/voice"
	/// Should oggs be cached
	var/tts_cache_enabled = FALSE
	/// What cpu threads should ffmpeg use
	var/ffmpeg_cpuaffinity

/datum/configuration_section/tts_configuration/load_data(list/data)
	CONFIG_LOAD_BOOL(tts_enabled, data["tts_enabled"])
	CONFIG_LOAD_STR(tts_token_silero, data["tts_token_silero"])
	CONFIG_LOAD_BOOL(tts_cache_enabled, data["tts_cache_enabled"])
	CONFIG_LOAD_STR(ffmpeg_cpuaffinity, data["ffmpeg_cpuaffinity"])
	CONFIG_LOAD_STR(tts_api_url_silero, data["tts_api_url_silero"])

	tts_enabled = tts_token_silero && tts_enabled
	var/sanitized = regex(@"[^0-9,-]", "g").Replace(ffmpeg_cpuaffinity, "")
	if(ffmpeg_cpuaffinity != sanitized)
		log_config("Wrong value for ffmpeg_cpuaffinity. Check out taskset man page.")

/datum/http_request/vv_get_var(var_name)
	if(var_name == "body")
		return FALSE

/datum/configuration_section/tts_configuration/vv_get_var(var_name, var_value)
	if(var_name == "tts_api_url_silero")
		return FALSE
