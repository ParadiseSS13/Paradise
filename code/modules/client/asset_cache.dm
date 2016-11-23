/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//List of ALL assets for the above, format is list(filename = asset).
/var/global/list/asset_cache = list()

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(asset_cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if(client)
			client.cache += asset_name
		return 1
	if(!client)
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	if(unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	for(var/asset in unreceived)
		if(asset in asset_cache)
			client << browse_rsc(asset_cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if(client)
			client.cache += unreceived
		return 1
	if(!client)
		return 0
	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	for(var/file in files)
		if(!client)
			break
		if(register_asset)
			register_asset(file,files[file])
		send_asset(client,file)
		sleep(-1) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	asset_cache[asset_name] = asset

//From here on out it's populating the asset cache.
/proc/populate_asset_cache()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in clients)
		//doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps
		spawn(10)
			getFilesSlow(C, asset_cache, FALSE)

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
/var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if(!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)


//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png"     = 'icons/paper_icons/large_stamp-clown.png',
		"large_stamp-deny.png"      = 'icons/paper_icons/large_stamp-deny.png',
		"large_stamp-ok.png"        = 'icons/paper_icons/large_stamp-ok.png',
		"large_stamp-hop.png"       = 'icons/paper_icons/large_stamp-hop.png',
		"large_stamp-cmo.png"       = 'icons/paper_icons/large_stamp-cmo.png',
		"large_stamp-ce.png"        = 'icons/paper_icons/large_stamp-ce.png',
		"large_stamp-hos.png"       = 'icons/paper_icons/large_stamp-hos.png',
		"large_stamp-rd.png"        = 'icons/paper_icons/large_stamp-rd.png',
		"large_stamp-cap.png"       = 'icons/paper_icons/large_stamp-cap.png',
		"large_stamp-qm.png"        = 'icons/paper_icons/large_stamp-qm.png',
		"large_stamp-law.png"       = 'icons/paper_icons/large_stamp-law.png',
		"large_stamp-cent.png"      = 'icons/paper_icons/large_stamp-cent.png',
		"large_stamp-syndicate.png" = 'icons/paper_icons/large_stamp-syndicate.png',
		"talisman.png"              = 'icons/paper_icons/talisman.png',
		"ntlogo.png"                = 'icons/paper_icons/ntlogo.png'
	)

/datum/asset/simple/chess
	assets = list(
		"bishop_black.png"			= 'icons/chess_pieces/bishop_black.png',
		"bishop_white.png"			= 'icons/chess_pieces/bishop_white.png',
		"king_black.png"			= 'icons/chess_pieces/king_black.png',
		"king_white.png"			= 'icons/chess_pieces/king_white.png',
		"knight_black.png"			= 'icons/chess_pieces/knight_black.png',
		"knight_white.png"			= 'icons/chess_pieces/knight_white.png',
		"pawn_black.png"			= 'icons/chess_pieces/pawn_black.png',
		"pawn_white.png"			= 'icons/chess_pieces/pawn_white.png',
		"queen_black.png"			= 'icons/chess_pieces/queen_black.png',
		"queen_white.png"			= 'icons/chess_pieces/queen_white.png',
		"rook_black.png"			= 'icons/chess_pieces/rook_black.png',
		"rook_white.png"			= 'icons/chess_pieces/rook_white.png',
		"sprites.png"			    = 'icons/chess_pieces/sprites.png',
		"blank.gif"                 = 'icons/chess_pieces/blank.gif',
		"background.png"            = 'nano/images/uiBackground.png',
		"garbochess.js"             = 'html/browser/garbochess.js',
		"boardui.js"                = 'html/browser/boardui.js'
	)

/datum/asset/nanoui
	var/list/common = list()

	var/list/common_dirs = list(
		"nano/assets/",
		"nano/codemirror/",
		"nano/images/",
		"nano/layouts/"
	)
	var/list/uncommon_dirs = list(
		"nano/templates/"
	)

/datum/asset/nanoui/register()
	// Crawl the directories to find files.
	for(var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])
	for(var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset(filename, fcopy_rsc(path + filename))

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon)
	send_asset_list(client, common)

/datum/asset/chem_master
	var/assets = list()
	var/verify = FALSE

/datum/asset/chem_master/register()
	for(var/i = 1 to 20)
		assets["pill[i].png"] = icon('icons/obj/chemical.dmi', "pill[i]")
	for(var/i in list("bottle", "small_bottle", "wide_bottle", "round_bottle"))
		assets["[i].png"] = icon('icons/obj/chemical.dmi', "[i]")
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/chem_master/send(client)
	send_asset_list(client,assets,verify)