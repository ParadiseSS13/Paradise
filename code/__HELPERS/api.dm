// This file contains procs for interacting with the internal API

/**
  * Internal API Caller
  *
  * Makes calls to the internal Paradise API and returns a [/datum/http_response].
  *
  * Arguments:
  * * method - The relevant HTTP method to use
  * * path - The path of the API call. DO NOT USE A LEADING SLASH
  * * body - The request body, if applicable
  */
/proc/MakeAPICall(method, path, body)
	if(!method || !path)
		// Needs valid params
		return null
	if(!GLOB.configuration.system.api_host || !GLOB.configuration.system.api_key)
		// Needs these set in config
		return null

	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, "<span class='boldannounceooc'>API interaction blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to interact with the internal API via advanced proc-call")
		log_admin("[key_name(usr)] attempted to interact with the internal API via advanced proc-call")
		return

	var/datum/http_request/req = new()
	var/target_url = "[GLOB.configuration.system.api_host]/[path]"
	// You may be asking, "Hey AA, why is the above a var instead of just using it directly?"
	// Ill tell you why. This lets you breakpoint it in the debugger to see if the URL is
	// what you wanted or not, given how slashes and stuff can break it.
	req.prepare(method, target_url, body, list("AuthKey" = GLOB.configuration.system.api_key))
	req.begin_async()
	// Check if we are complete
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()

	return res

