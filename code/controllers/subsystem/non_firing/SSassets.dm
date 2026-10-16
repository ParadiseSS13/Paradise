SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	flags = SS_NO_FIRE
	/// Contains /datum/asset_cache_item
	var/list/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Initialize(timeofday)
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

/// Builds every asset that isn't built yet, so the first person to open an interface mid-round doesn't hold the whole server up while its spritesheet gets made.
/// It's a couple of seconds of work in all, so the MC calls this once the server is done starting up.
/datum/controller/subsystem/assets/proc/load_assets()
	set waitfor = FALSE
	for(var/datum/asset/asset_to_load as anything in typesof(/datum/asset))
		if(asset_to_load::_abstract == asset_to_load)
			continue

		load_asset_datum(asset_to_load)
		CHECK_TICK
