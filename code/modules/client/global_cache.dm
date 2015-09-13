//We store a list of all clients, with a list of all file names that the client received.
/var/global/list/client_cache = list()

//List of ALL assets for the above, format is list(filename = asset).
/var/global/list/asset_cache = list()

//This proc sends the asset to the client, but only if it needs it.
/proc/send_asset(var/client/client, var/asset_name)
	var/list/client_list = client_cache[client]
	ASSERT(client_list)

	if(asset_name in client_list)
		return

	//world << "sending a client the asset '[asset_name]'"
	client << browse_rsc(asset_cache[asset_name], asset_name)
	client_list += asset_name
	
/proc/send_asset_list(var/client/client, var/list/asset_list)
	for(var/asset_name in asset_list)
		send_asset(client, asset_name)

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	asset_cache |= asset_name
	asset_cache[asset_name] = asset

//From here on out it's populating the asset cache.
/proc/populate_asset_cache()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()

		A.register()

//These datums are used to populate the asset cache, the proc "register()" does this.
/datum/asset/proc/register()
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
		
//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/simple/spider_os
	assets = list(
		"sos_1.png" = 'icons/spideros_icons/sos_1.png',
		"sos_2.png" = 'icons/spideros_icons/sos_2.png',
		"sos_3.png" = 'icons/spideros_icons/sos_3.png',
		"sos_4.png" = 'icons/spideros_icons/sos_4.png',
		"sos_5.png" = 'icons/spideros_icons/sos_5.png',
		"sos_6.png" = 'icons/spideros_icons/sos_6.png',
		"sos_7.png" = 'icons/spideros_icons/sos_7.png',
		"sos_8.png" = 'icons/spideros_icons/sos_8.png',
		"sos_9.png" = 'icons/spideros_icons/sos_9.png',
		"sos_10.png" = 'icons/spideros_icons/sos_10.png',
		"sos_11.png" = 'icons/spideros_icons/sos_11.png',
		"sos_12.png" = 'icons/spideros_icons/sos_12.png',
		"sos_13.png" = 'icons/spideros_icons/sos_13.png',
		"sos_14.png" = 'icons/spideros_icons/sos_14.png'
	)
	
/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png" = 'icons/paper_icons/large_stamp-clown.png',
		"large_stamp-deny.png" = 'icons/paper_icons/large_stamp-deny.png',
		"large_stamp-ok.png" = 'icons/paper_icons/large_stamp-ok.png',
		"large_stamp-hop.png" = 'icons/paper_icons/large_stamp-hop.png',
		"large_stamp-cmo.png" = 'icons/paper_icons/large_stamp-cmo.png',
		"large_stamp-ce.png" = 'icons/paper_icons/large_stamp-ce.png',
		"large_stamp-hos.png" = 'icons/paper_icons/large_stamp-hos.png',
		"large_stamp-rd.png" = 'icons/paper_icons/large_stamp-rd.png',
		"large_stamp-cap.png" = 'icons/paper_icons/large_stamp-cap.png',
		"large_stamp-qm.png" = 'icons/paper_icons/large_stamp-qm.png',
		"large_stamp-law.png" = 'icons/paper_icons/large_stamp-law.png',
		"large_stamp-cent.png" = 'icons/paper_icons/large_stamp-cent.png',
		"large_stamp-syndicate.png" = 'icons/paper_icons/large_stamp-syndicate.png',
		"talisman.png" = 'icons/paper_icons/talisman.png',
		"ntlogo.png" = 'icons/paper_icons/ntlogo.png'	
	)
