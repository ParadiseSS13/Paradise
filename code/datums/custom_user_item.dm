/**
  * # Custom User Item
  *
  * Holder for CUIs
  *
  * This datum is a holder that is essentially a "model" of the `customuseritems`
  * database table, and is used for giving people their CUIs on spawn.
  * It is instanced as part of the client data loading framework on the client.
  *
  */
/datum/custom_user_item
	/// Can this be used on all characters?
	var/all_characters_allowed = FALSE
	/// Name of the character that can have this item.
	var/characer_name
	/// Are all jobs allowed?
	var/all_jobs_allowed = FALSE
	/// List of allowed jobs
	var/list/allowed_jobs = list()
	/// Custom item typepath
	var/object_typepath
	/// Custom item name override
	var/item_name_override
	/// Custom item description override
	var/item_desc_override
	/// Raw job mask
	var/raw_job_mask


/**
  * CUI Info Parser
  *
  * Parses all the raw info into usable stuff, and also does validity checks
  * Returns TRUE if its a valid item, and FALSE if not
  *
  * Arguments:
  * * owning_ckey - Player who owns this item. Used for logging purposes.
  */
/datum/custom_user_item/proc/parse_info(owning_ckey)
	. = FALSE // Setting this here means it will return false even if it runtimes

	// Sort path
	if(!object_typepath || !ispath(object_typepath))
		stack_trace("Incorrect database entry found in table 'customuseritems' path value is [object_typepath ? object_typepath : "(NULL)"], which doesnt exist. Ask the host to look at CUI entries for [owning_ckey]")
		return

	// Sort job mask
	if(raw_job_mask == "*")
		all_jobs_allowed = TRUE
	else
		var/list/local_allowed_jobs = splittext(raw_job_mask, ",")
		for(var/i in 1 to length(local_allowed_jobs))
			if(istext(local_allowed_jobs[i]))
				local_allowed_jobs[i] = trim(local_allowed_jobs[i])

		allowed_jobs = local_allowed_jobs

	// Sort character name
	if(characer_name == "*")
		all_characters_allowed = TRUE

	return TRUE


/datum/custom_user_item/vv_edit_var(var_name, var_value)
	return FALSE // fuck off
