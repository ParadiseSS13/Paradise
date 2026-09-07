/datum/configuration_section/tgui_configuration
	// How many chunks a TGUI request can be divided into at most
	var/max_chunks = 32

/datum/configuration_section/tgui_configuration/load_data(list/data)
	CONFIG_LOAD_NUM(max_chunks, data["max_chunk_count"])
