SUBSYSTEM_DEF(http)
	name = "HTTP"
	flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT // Measure in ticks, but also only run if we have the spare CPU.
	wait = 1
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY // All the time
	// Assuming for the worst, since only discord is hooked into this for now, but that may change
	offline_implications = "The server is no longer capable of making async HTTP requests. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	/// List of all async HTTP requests in the processing chain
	var/list/datum/http_request/active_async_requests = list()
	/// Variable to define if logging is enabled or not. Disabled by default since we know the requests the server is making. Enable with VV if you need to debug requests
	var/logging_enabled = FALSE
	/// Total requests the SS has processed in a round
	var/total_requests

/datum/controller/subsystem/http/PreInit()
	. = ..()
	rustlibs_http_start_client() // Open the door

/datum/controller/subsystem/http/get_stat_details()
	return "P: [length(active_async_requests)] | T: [total_requests]"

/datum/controller/subsystem/http/fire(resumed)
	for(var/r in active_async_requests)
		var/datum/http_request/req = r
		// Check if we are complete
		if(req.is_complete())
			// If so, take it out the processing list
			active_async_requests -= req
			var/datum/http_response/res = req.into_response()

			// If the request has a callback, invoke it.Async of course to avoid choking the SS
			if(req.cb)
				req.cb.InvokeAsync(res)

			// And log the result
			if(logging_enabled)
				var/list/log_data = list()
				log_data += "BEGIN ASYNC RESPONSE (ID: [req.id])"
				if(res.errored)
					log_data += "\t ----- RESPONSE ERRROR -----"
					log_data += "\t [res.error]"
				else
					log_data += "\tResponse status code: [res.status_code]"
					log_data += "\tResponse body: [res.body]"
					log_data += "\tResponse headers: [json_encode(res.headers)]"
				log_data += "END ASYNC RESPONSE (ID: [req.id])"
				rustlibs_log_write(GLOB.http_log, log_data.Join("\n[GLOB.log_end]"))

/**
  * Async request creator
  *
  * Generates an async request, and adds it to the subsystem's processing list
  * These should be used as they do not lock the entire DD process up as they execute inside their own thread pool inside RUSTG
  */
/datum/controller/subsystem/http/proc/create_async_request(method, url, body = "", list/headers, datum/callback/proc_callback)
	var/datum/http_request/req = new()
	req.prepare(method, url, body, headers)
	if(proc_callback)
		req.cb = proc_callback

	// Begin it and add it to the SS active list
	req.begin_async()
	active_async_requests += req
	total_requests++

	if(logging_enabled)
		// Create a log holder
		var/list/log_data = list()
		log_data += "BEGIN ASYNC REQUEST (ID: [req.id])"
		log_data += "\t[uppertext(req.method)] [req.url]"
		log_data += "\tRequest body: [req.body]"
		log_data += "\tRequest headers: [req.headers]"
		log_data += "END ASYNC REQUEST (ID: [req.id])"

		// Write the log data
		rustlibs_log_write(GLOB.http_log, log_data.Join("\n[GLOB.log_end]"))

/**
  * Blocking request creator
  *
  * Generates a blocking request, executes it, logs the info then cleanly returns the response
  * Exists as a proof of concept, and should never be used
  */
/datum/controller/subsystem/http/proc/make_blocking_request(method, url, body = "", list/headers)
	CRASH("Attempted use of a blocking HTTP request")
	/*
	var/datum/http_request/req = new()
	req.prepare(method, url, body, headers)
	req.execute_blocking()
	var/datum/http_response/res = req.into_response()

	// Now generate a logfile
	var/list/log_data = list()
	log_data += "NEW BLOCKING REQUEST"
	log_data += "\t[uppertext(req.method)] [req.url]"
	log_data += "\tRequest body: [req.body]"
	log_data += "\tRequest headers: [req.headers]"
	if(res.errored)
		log_data += "\t ----- RESPONSE ERRROR -----"
		log_data += "\t [res.error]"
	else
		log_data += "\tResponse status code: [res.status_code]"
		log_data += "\tResponse body: [res.body]"
		log_data += "\tResponse headers: [json_encode(res.headers)]"
	log_data += "END BLOCKING REQUEST"

	// Write the log data
	rustlibs_log_write(GLOB.http_log, log_data.Join("\n[GLOB.log_end]"))

	return res
	*/

/*

	Example of how to use callbacks properly

/client/verb/testing()
	set name = "Testing"

	var/datum/callback/cb = CALLBACK(src, TYPE_PROC_REF(/client, response), usr)
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, "http://site.domain/page.html", proc_callback=cb)

/client/proc/response(mob/user, datum/http_response/response)
	to_chat(user, "<span class='notice'>Code: [response.status_code] | Content: [response.body]")
*/
