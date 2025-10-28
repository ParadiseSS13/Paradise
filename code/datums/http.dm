/*
	DO NOT FUCK WITH THE DATUMS IN THIS FILE AS THEY ARE ALSO USED BY THE RUSTLIB DIRECTLY
	SEE rust\src\rustlibs_http\mod.rs FOR DETAILS
*/

/**
  * # HTTP Request
  *
  * Holder datum for ingame HTTP requests
  *
  * Holds information regarding to methods used, URL, and response,
  * as well as job IDs and progress tracking for async requests
  */
/datum/http_request
	/// The ID of the request (Only set if it is an async request)
	var/id
	/// Is the request in progress? (Only set if it is an async request)
	var/in_progress = FALSE
	/// HTTP method used
	var/method
	/// Body of the request being sent
	var/body
	/// Request headers being sent
	var/list/headers = list()
	/// URL that the request is being sent to
	var/url
	/// Job error code, if any
	var/error_code
	/// The response for the request
	var/datum/http_response/response_obj
	/// Callback for executing after async requests. Will be called with an argument of [/datum/http_response] as first argument
	var/datum/callback/cb

/*
###########################################################################
THE METHODS IN THIS FILE ARE TO BE USED BY THE SUBSYSTEM AS A MANGEMENT HUB
----------------------- DO NOT MANUALLY INVOKE THEM -----------------------
###########################################################################
*/

/**
  * Preparation handler
  *
  * Call this with relevant parameters to form the request you want to make
  *
  * Arguments:
  * * _method - HTTP Method to use, see code/__DEFINES/rust_g.dm for a full list
  * * _url - The URL to send the request to
  * * _body - The body of the request, if applicable
  * * _headers - Associative list of HTTP headers to send, if applicab;e
  */
/datum/http_request/proc/prepare(_method, _url, _body = "", list/_headers)
	if(istype(_headers))
		headers =_headers

	method = _method
	url = _url
	body = _body

/**
  * Async execution starter
  *
  * Tells the request to start executing inside its own thread inside RUSTG
  * Preferred over blocking, but also requires SShttp to be active
  * As such, you cannot use this for events which may happen at roundstart (EG: IPIntel, BYOND account tracking, etc)
  */
/datum/http_request/proc/begin_async()
	rustlibs_http_send_request(src)

/**
  * Async completion checker
  *
  * Checks if an async request has been complete
  * Has safety checks built in to compensate if you call this on blocking requests,
  * or async requests which have already finished
  */
/datum/http_request/proc/is_complete()
	// If we dont have an ID, were blocking, so assume complete
	if(isnull(id))
		return TRUE

	// If we arent in progress, assume complete
	if(!in_progress)
		return TRUE

	// We got here, so check the status
	var/result = rustlibs_http_check_request(src)

	// If we have no result, were not finished
	if(error_code == RUSTLIBS_JOB_NO_RESULTS_YET)
		return FALSE
	else
		// If we got here, we have a result to parse
		response_obj = result
		return TRUE

/**
  * Response deserializer
  *
  * Takes a HTTP request object, and converts it into a [/datum/http_response]
  * The entire thing is wrapped in try/catch to ensure it doesnt break on invalid requests
  * Can be called on async and blocking requests
  */
/datum/http_request/proc/into_response()
	if(!response_obj)
		CRASH("Called into_response() while response_obj is null")
	return response_obj


/**
  * # HTTP Response
  *
  * Holder datum for HTTP responses
  *
  * Created from calling [/datum/http_request/proc/into_response()]
  * Contains vars about the result of the response
  */
/datum/http_response
	/// The HTTP status code of the response
	var/status_code
	/// The body of the response from the server
	var/body
	/// Associative list of headers sent from the server
	var/list/headers
	/// Has the request errored
	var/errored = FALSE
	/// Raw response if we errored
	var/error
