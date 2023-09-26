/datum/tts_seed
	var/name = "STUB"
	var/value = "STUB"
	var/category = TTS_CATEGORY_OTHER
	var/gender = TTS_GENDER_ANY
	var/datum/tts_provider/provider = /datum/tts_provider
	var/required_donator_level = 0

/datum/tts_seed/vv_edit_var(var_name, var_value)
	return FALSE
