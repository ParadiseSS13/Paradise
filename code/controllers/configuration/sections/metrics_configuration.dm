/// Config holder for stuff relating to metrics management
/datum/configuration_section/metrics_configuration
	// NO EDITS OR READS TO THIS EVER
	protection_state = PROTECTION_PRIVATE
	/// Are metrics enabled or disabled
	var/enable_metrics = FALSE
	/// Endpoint to send metrics to, including protocol
	var/metrics_endpoint = null
	/// Endpoint authorisation API key
	var/metrics_api_token = null

/datum/configuration_section/metrics_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enable_metrics, data["enable_metrics"])

	CONFIG_LOAD_STR(metrics_endpoint, data["metrics_endpoint"])
	CONFIG_LOAD_STR(metrics_api_token, data["metrics_api_token"])
