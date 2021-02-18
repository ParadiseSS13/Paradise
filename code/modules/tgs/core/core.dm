/world/TgsNew(datum/tgs_event_handler/event_handler, minimum_required_security_level = TGS_SECURITY_ULTRASAFE)
	var/current_api = TGS_READ_GLOBAL(tgs)
	if(current_api)
		TGS_ERROR_LOG("API datum already set (\ref[current_api] ([current_api]))! Was TgsNew() called more than once?")
		return

	if(!(minimum_required_security_level in list(TGS_SECURITY_ULTRASAFE, TGS_SECURITY_SAFE, TGS_SECURITY_TRUSTED)))
		TGS_ERROR_LOG("Invalid minimum_required_security_level: [minimum_required_security_level]!")
		return

#ifdef TGS_V3_API
	if(minimum_required_security_level != TGS_SECURITY_TRUSTED)
		TGS_WARNING_LOG("V3 DMAPI requires trusted security!")
		minimum_required_security_level = TGS_SECURITY_TRUSTED
#endif
	var/raw_parameter = world.params[TGS_VERSION_PARAMETER]
	if(!raw_parameter)
		return

	var/datum/tgs_version/version = new(raw_parameter)
	if(!version.Valid(FALSE))
		TGS_ERROR_LOG("Failed to validate DMAPI version parameter: [raw_parameter]!")
		return

	var/api_datum
	switch(version.suite)
		if(3)
#ifndef TGS_V3_API
			TGS_ERROR_LOG("Detected V3 API but TGS_V3_API isn't defined!")
			return
#else
			switch(version.minor)
				if(2)
					api_datum = /datum/tgs_api/v3210
#endif
		if(4)
			switch(version.minor)
				if(0)
					api_datum = /datum/tgs_api/v4
		if(5)
			api_datum = /datum/tgs_api/v5

	var/datum/tgs_version/max_api_version = TgsMaximumApiVersion();
	if(version.suite != null && version.minor != null && version.patch != null && version.deprecated_patch != null && version.deprefixed_parameter > max_api_version.deprefixed_parameter)
		TGS_ERROR_LOG("Detected unknown API version! Defaulting to latest. Update the DMAPI to fix this problem.")
		api_datum = /datum/tgs_api/latest

	if(!api_datum)
		TGS_ERROR_LOG("Found unsupported API version: [raw_parameter]. If this is a valid version please report this, backporting is done on demand.")
		return

	TGS_INFO_LOG("Activating API for version [version.deprefixed_parameter]")

	if(event_handler && !istype(event_handler))
		TGS_ERROR_LOG("Invalid parameter for event_handler: [event_handler]")
		event_handler = null

	var/datum/tgs_api/new_api = new api_datum(event_handler, version)

	TGS_WRITE_GLOBAL(tgs, new_api)

	var/result = new_api.OnWorldNew(minimum_required_security_level)
	if(!result || result == TGS_UNIMPLEMENTED)
		TGS_WRITE_GLOBAL(tgs, null)
		TGS_ERROR_LOG("Failed to activate API!")

/world/TgsMaximumApiVersion()
	return new /datum/tgs_version("5.x.x")

/world/TgsMinimumApiVersion()
	return new /datum/tgs_version("3.2.x")

/world/TgsInitializationComplete()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.OnInitializationComplete()

/world/proc/TgsTopic(T)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.OnTopic(T)
		if(result != TGS_UNIMPLEMENTED)
			return result

/world/TgsRevision()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.Revision()
		if(result != TGS_UNIMPLEMENTED)
			return result

/world/TgsReboot()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.OnReboot()

/world/TgsAvailable()
	return TGS_READ_GLOBAL(tgs) != null

/world/TgsVersion()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		return api.version

/world/TgsApiVersion()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		return api.ApiVersion()

/world/TgsInstanceName()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.InstanceName()
		if(result != TGS_UNIMPLEMENTED)
			return result

/world/TgsTestMerges()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.TestMerges()
		if(result != TGS_UNIMPLEMENTED)
			return result
	return list()

/world/TgsEndProcess()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.EndProcess()

/world/TgsChatChannelInfo()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.ChatChannelInfo()
		if(result != TGS_UNIMPLEMENTED)
			return result
	return list()

/world/TgsChatBroadcast(message, list/channels)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.ChatBroadcast(message, channels)

/world/TgsTargetedChatBroadcast(message, admin_only)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.ChatTargetedBroadcast(message, admin_only)

/world/TgsChatPrivateMessage(message, datum/tgs_chat_user/user)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.ChatPrivateMessage(message, user)

/world/TgsSecurityLevel()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.SecurityLevel()
