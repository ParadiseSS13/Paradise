/// Config holder for all job related things
/datum/configuration_section/job_configuration
	/// Do we want to restrict jobs based on account age
	var/restrict_jobs_on_account_age = FALSE
	/// Allow admins to bypass age-based job restrictions
	var/restrict_jobs_on_account_age_admin_bypass = TRUE
	/// Enable EXP logging and tracking
	var/enable_exp_tracking = FALSE
	/// Lockout jobs based on EXP
	var/enable_exp_restrictions = FALSE
	/// Allow admins to bypass EXP restrictions
	var/enable_exp_admin_bypass = TRUE
	/// Allow non-admins to play as AI
	var/allow_ai = TRUE
	/// Prevent guests from playing high profile roles
	var/guest_job_ban = TRUE
	/// Grant assistants maint access
	var/assistant_maint_access = TRUE
	/// Limit amount of assistants?
	var/assistant_limit = FALSE
	/// If yes to above, ratio of assistants per security officer (IE: 4:1)
	var/assistant_security_ratio = 2
	/// Enable loading of job overrides from the config
	var/enable_job_amount_overrides = TRUE
	/// Map of job:amount for lowpop. key: Job | value: amount
	var/list/lowpop_job_map = list()
	/// Map of job:amount for highpop. key: Job | value: amount
	var/list/highpop_job_map = list()

/datum/configuration_section/job_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(restrict_jobs_on_account_age, data["restrict_jobs_on_account_age"])
	CONFIG_LOAD_BOOL(restrict_jobs_on_account_age_admin_bypass, data["restrict_jobs_on_account_age_admin_bypass"])
	CONFIG_LOAD_BOOL(enable_exp_tracking, data["enable_exp_tracking"])
	CONFIG_LOAD_BOOL(enable_exp_restrictions, data["enable_exp_restrictions"])
	CONFIG_LOAD_BOOL(enable_exp_admin_bypass, data["enable_exp_admin_bypass"])
	CONFIG_LOAD_BOOL(allow_ai, data["allow_ai"])
	CONFIG_LOAD_BOOL(guest_job_ban, data["guest_job_ban"])
	CONFIG_LOAD_BOOL(assistant_maint_access, data["assistant_maint_access"])
	CONFIG_LOAD_BOOL(assistant_limit, data["assistant_limit"])
	CONFIG_LOAD_NUM(assistant_security_ratio, data["assistant_security_ratio"])
	CONFIG_LOAD_BOOL(enable_job_amount_overrides, data["enable_job_amount_overrides"])

	if(enable_job_amount_overrides && islist(data["job_slot_amounts"]))
		lowpop_job_map.Cut()
		highpop_job_map.Cut()
		for(var/kvp in data["job_slot_amounts"])
			if(!isnull(kvp["name"]))
				if(!isnull(kvp["lowpop"]))
					lowpop_job_map[kvp["name"]] = kvp["lowpop"]
				if(!isnull(kvp["highpop"]))
					highpop_job_map[kvp["name"]] = kvp["highpop"]
