SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	flags = SS_NO_FIRE
	/// Contains /datum/asset_cache_item
	var/list/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Initialize(timeofday)
	load_assets()
	apply_configuration()

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload

/datum/controller/subsystem/assets/proc/apply_configuration(initialize_transport = TRUE)
	var/newtransporttype = /datum/asset_transport
	switch(GLOB.configuration.asset_cache.asset_transport)
		if("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if(newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype
	if(newtransport.validate_config())
		transport = newtransport

	if(initialize_transport)
		transport.Initialize(cache)

/datum/controller/subsystem/assets/proc/load_assets()
	for(var/datum/asset/asset_to_load as anything in typesof(/datum/asset))
		if(initial(asset_to_load._abstract))
			continue

		load_asset_datum(type)
