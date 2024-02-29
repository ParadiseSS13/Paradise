/datum/configuration_section/asset_cache_configuration
	/// Type of asset transport that will be used for asset delivery.
	/// Available options are "simple" or "webroot".
	var/asset_transport = "simple"
	/// Whether to make server passively send all browser assets to each client in the background
	/// (instead of waiting for them to be needed)
	var/asset_simple_preload = TRUE
	/// Local folder to save assets to.
	/// Assets will be saved in the format of asset.MD5HASH.EXT or in namespaces/hash/
	/// as ASSET_FILE_NAME or asset.MD5HASH.EXT
	var/asset_cdn_webroot = "data/asset-store/"
	/// URL the `asset_cdn_webroot` can be accessed from.
	/// For best results the webserver powering this should return a long cache validity time,
	/// as all assets sent via this transport use hash based urls
	/// if you want to test this locally, you simpily run the `localhost-asset-webroot-server.py` python3 script
	/// to host assets stored in `data/asset-store/` via http://localhost:58715/
	var/asset_cdn_url = "http://localhost:58715/"

/datum/configuration_section/asset_cache_configuration/load_data(list/data)
	CONFIG_LOAD_STR(asset_transport, data["asset_transport"])
	CONFIG_LOAD_BOOL(asset_simple_preload, data["asset_simple_preload"])
	CONFIG_LOAD_STR(asset_cdn_webroot, data["asset_cdn_webroot"])
	CONFIG_LOAD_STR(asset_cdn_url, data["asset_cdn_url"])
