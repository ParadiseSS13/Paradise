// DEFINES //

/// Create and start a render job for a map with RUSTG. Take map_path as an argument, and will return the ID of the job
#define RUST_G_START_RENDER_JOB(map_path) call(RUST_G, "start_render_job")(map_path)

/// Checks the status of a running job, and has a return code
#define RUST_G_CHECK_RENDER_JOB(render_id) call(RUST_G, "check_render_job")(render_id)

/// RUSTG job status return code for if a job is still running
#define RUST_G_JOB_NO_RESULTS_YET "NO_RESULTS_YET"

/// RUSTG job status return code for if a job does not exist
#define RUST_G_JOB_NO_SUCH_JOB "NO_SUCH_JOB"

/// RUSTG job status return code for if a job crashed mid exuection
#define RUST_G_JOB_ERROR "JOB_PANICKED"

// Now for the SS //

/*
	Basically this is a replacement for the ancient nanomap rendering code
	The old code took 50 seconds to complete, locked up the entire process, and was so poorly documented no one ever used it
	This now farms jobs off to RUSTG, which can not only render them much faster, but it can do so without blocking the entire game up
	STUFF IN THIS HAS BEEN CODED IN A VERY SPECIFIC WAY. A LOT OF CACHING AND CHECKS HAPPEN TO AVOID RE-RENDERING WHEN YOU DONT NEED TO

	TEST ALL CASES BEFORE YOU MODIFY THIS. PLEASE. -aa
*/

SUBSYSTEM_DEF(nanomap)
	name = "NanoMap"
	init_order = INIT_ORDER_MINIMAP
	flags = SS_NO_FIRE
	/// Is the SS ready (It threads away from Initialize so this needs to be tracked)
	var/ready = FALSE

/**
  * Initialization
  *
  * On SS initialization, the following checks happen
  * If the config option to render maps is enabled, we will first check if a hash savefile exists
  * If that file exists, check its hash with the md5 of the current loaded map file. If the hashes are different, the map has changed, and the nanomap should be re-rendered
  * If that file doesnt exist, check if a previously rendered map exists. If there is no previous render, display an error screen on nanomaps
  * If no generation was required, but an image needed to be loaded, register that image as an asset and send it out to all the clients
  */
/datum/controller/subsystem/nanomap/Initialize(start_timeofday)
	log_startup_progress("Initializing NanoMap...")
	// Check if the server should generate nanomaps at all
	if(config.nanomap_generation)
		// See if our map even exists
		if(fexists("data/nanomaps/[GLOB.using_map.file_name]_nanomap_z1.png"))
			// If theres no map hash stored, we have nothing to compare, so generate
			if(!fexists("data/nanomaps/[GLOB.using_map.file_name].md5"))
				log_startup_progress("No savefile found for [GLOB.using_map.full_name]. Rendering map in new thread...")
				render_map()
			// The file exists, so lets check it here
			else
				// Get the hash of the current loaded map
				var/current_hash = md5(GLOB.using_map.file_path)
				// Get the hash of the savefile on disk
				var/disk_hash = trim(file2text("data/nanomaps/[GLOB.using_map.file_name].md5"))
				// Now see if they are equal
				if(current_hash == disk_hash)
					log_startup_progress("No map changes since last NanoMap render. Using previously generated image...")
					register_asset("nanomap.png", fcopy_rsc("data/nanomaps/[GLOB.using_map.file_name]_nanomap_z1.png"))
				else
					log_startup_progress("NanoMap for [GLOB.using_map.full_name] is out of date. Rendering map in new thread...")
					render_map()
		else
			// The saved image doesnt exist, render anyway
			log_startup_progress("No NanoMap found for [GLOB.using_map.full_name]. Rendering map in new thread...")
			render_map()
	else
		if(fexists("data/nanomaps/[GLOB.using_map.file_name]_nanomap_z1.png"))
			log_startup_progress("NanoMap generation is disabled. Using previously generated image for [GLOB.using_map.full_name].")
			register_asset("nanomap.png", fcopy_rsc("data/nanomaps/[GLOB.using_map.file_name]_nanomap_z1.png"))
		else
			log_startup_progress("NanoMap generation is disabled and there is no previous image for [GLOB.using_map.full_name]. NanoMaps will not be functional.")
			register_asset("nanomap.png", fcopy_rsc("icons/nanomap_error.png"))
		// If we are using an existing image, send it out
		for(var/client/C in GLOB.clients)
			send_asset(C, "nanomap.png")
		ready = TRUE
	return ..()

/**
  * Proc to invoke a map render
  *
  * This proc creates the render job and waits for the result
  * It also updates the md5 hash stored on disk to cache updates
  */
/datum/controller/subsystem/nanomap/proc/render_map()
	// Run async
	set waitfor = FALSE

	// Create a render object and assign the map
	var/datum/rustg_map_render/render = new()
	render.map_path = GLOB.using_map.file_path

	// Start the render job
	var/start_time = start_watch()
	render.begin_async()
	log_startup_progress("Started render of [GLOB.using_map.full_name].")
	// Wait here till the render is complete. This will not lock up the DD process.
	UNTIL(render.is_complete())
	// Stuff broke, go into error handling mode
	if(render.error)
		log_startup_progress("Failed to render NanoMap of [GLOB.using_map.full_name]. Please inform the host or a coder!!!")
		// Revert to fallback
		register_asset("nanomap.png", fcopy_rsc("icons/nanomap_error.png"))
		for(var/client/C in GLOB.clients)
			send_asset(C, "nanomap.png")
		ready = TRUE
		// Cease Operation
		return

	// If we are here, it was a success
	log_startup_progress("Successfully rendered NanoMap of [GLOB.using_map.full_name] in [stop_watch(start_time)]s.")

	// Write the md5 of the current map to disk so it can be cached
	if(fexists("data/nanomaps/[GLOB.using_map.file_name].md5"))
		fdel("data/nanomaps/[GLOB.using_map.file_name].md5")
	text2file(md5(GLOB.using_map.file_path),"data/nanomaps/[GLOB.using_map.file_name].md5")

	// Register the new map and send it out to clients
	register_asset("nanomap.png", fcopy_rsc("data/nanomaps/[GLOB.using_map.file_name]_nanomap_z1.png"))
	for(var/client/C in GLOB.clients)
		send_asset(C, "nanomap.png")

	// Tell new clients that the map is ready to be sent from the asset cache
	ready = TRUE

/**
  * Proc to send the rendered image to clients
  *
  * This is called on client/New() and exists so new clients get the map given to them
  * It checks if the SS is ready first to avoid sending a null image
  */
/datum/controller/subsystem/nanomap/proc/send_image(client/client)
	if(!ready)
		return
	send_asset(client, "nanomap.png")


/**
  * # RUSTG Map Render Holder
  *
  * Contains the information to spawn a render job inside of RUSTG
  */
/datum/rustg_map_render
	/// ID of the job (Starts at 0, counts up. Assigned by RUSTG)
	var/id
	/// Is the job still in progress
	var/in_progress = FALSE
	/// Path of the map to be rendered (Full path, using CWD as basedir)
	var/map_path
	/// Has the job successfully completed
	var/error = FALSE

/**
  * Proc to begin the render operation
  *
  * After some safety checks, this proc sends the job to RUSTG and starts it
  * If RUSTG fails to return a numerical ID (error), the proc is crashed with the RUSTG error message
  */
/datum/rustg_map_render/proc/begin_async()
	if(!map_path)
		CRASH("No map path set")

	if(in_progress)
		CRASH("Attempted to re-use a render object.")

	id = RUST_G_START_RENDER_JOB(map_path)

	if(isnull(text2num(id)))
		CRASH("Proc error: [id]")
	else
		in_progress = TRUE

/**
  * Proc to check if a job has complete
  *
  * When this proc is invoked, it will call to RUSTG to get the status of the job.
  * The string returned (Defined at the top of this file) is the state
  * It will also update the in_progress var once it has complete
  */
/datum/rustg_map_render/proc/is_complete()
	if(isnull(id))
		return TRUE

	if(!in_progress)
		return TRUE

	var/result = RUST_G_CHECK_RENDER_JOB(id)

	if (result == RUST_G_JOB_NO_RESULTS_YET)
		return FALSE
	else
		in_progress = FALSE
		if(result == RUST_G_JOB_ERROR)
			error = TRUE
			CRASH("RUST_G RENDER JOB ERROR")
		return TRUE
