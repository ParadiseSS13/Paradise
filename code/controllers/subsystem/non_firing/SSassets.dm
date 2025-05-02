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



// Debug shite
/client/proc/dump_all_assets()
	set name = "Upload All Assets"
	set category = "Debug"

	if(ckey != "affectedarc07")
		to_chat(usr, "This is only for the host - its a temporary verb lol")
		return

	var/datum/asset_transport/webroot/wat = new() // this stands for webroot asset transport not my confusion I swear


	var/assets_to_process = length(SSassets.cache)
	var/done = 0

	to_chat(usr, "Starting mass asset dump - [assets_to_process] to do")
	var/watch = start_watch()
	for(var/key in SSassets.cache)
		if(TICK_CHECK)
			to_chat(usr, "Sleeping for 1 tick - [done]/[assets_to_process] done")
			CHECK_TICK
		var/datum/asset/A = SSassets.cache[key]
		wat.save_asset_to_webroot(A)
		done++

	to_chat(usr, "Done within [stop_watch(watch)]s")
