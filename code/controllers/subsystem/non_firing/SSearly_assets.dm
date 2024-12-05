/// Initializes any assets that need to be loaded ASAP.
SUBSYSTEM_DEF(early_assets)
	name = "Early Assets"
	init_order = INIT_ORDER_EARLY_ASSETS
	flags = SS_NO_FIRE

/datum/controller/subsystem/early_assets/Initialize()
	for(var/datum/asset/asset_type as anything in subtypesof(/datum/asset))
		if(asset_type::_abstract == asset_type)
			continue

		if(!asset_type::early)
			continue

		if(!load_asset_datum(asset_type))
			stack_trace("Could not initialize early asset [asset_type]!")

		CHECK_TICK
