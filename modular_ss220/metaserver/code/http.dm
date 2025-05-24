/**
 * Blocking request creator
 *
 * Generates a blocking request, executes it, logs the info then cleanly returns the response
 * Uses UNTIL, so is VERY dangerous to use.
 */
/datum/controller/subsystem/http/proc/make_sync_request(method, url, body = "", list/headers)
	var/datum/http_request/req = new()
	req.prepare(method, url, body, headers)
	req.begin_async()
	active_async_requests += req
	total_requests++
	log_request(req)

	UNTIL(req.is_complete())
	active_async_requests -= req
	var/datum/http_response/res = req.into_response()
	log_response(res, req.id)
	return res

/datum/controller/subsystem/http/proc/log_request(datum/http_request/req, type = "ASYNC")
	if(!logging_enabled)
		return

	var/list/log_data = list()
	log_data += "REQUEST (ID: [req.id]) ([type])"
	log_data += "\t[uppertext(req.method)] [req.url]"
	log_data += "\tRequest body: [req.body]"
	log_data += "\tRequest headers: [req.headers]"
	rustlibs_log_write(GLOB.http_log, log_data.Join("\n[GLOB.log_end]"))

/datum/controller/subsystem/http/proc/log_response(datum/http_response/res, id)
	if(!logging_enabled)
		return

	var/list/log_data = list()
	log_data += "RESPONSE (ID: [id])"
	if(res.errored)
		log_data += "\t ----- RESPONSE ERROR -----"
		log_data += "\t [res.error]"
	else
		log_data += "\tResponse status code: [res.status_code]"
		log_data += "\tResponse body: [res.body]"
		log_data += "\tResponse headers: [json_encode(res.headers)]"
	rustlibs_log_write(GLOB.http_log, log_data.Join("\n[GLOB.log_end]"))


/datum/http_request/into_response()
	. = ..()
	var/datum/http_response/R = .
	if(!R.errored)
		return R
	// Handle the 4xx and 5xx codes. BS version is much better because saves the body
	var/static/regex/status_code_detector = new(@": status code (\d{3})$")
	var/actually_errored = status_code_detector.Find(R.error) == 0

	if(actually_errored)
		return R

	R.status_code = text2num(status_code_detector.group[1])
	R.errored = FALSE
	R.error = null

	return R
