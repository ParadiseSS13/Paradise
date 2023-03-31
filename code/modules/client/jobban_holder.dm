/// Holder for job bans
/datum/job_ban_holder
	/// Assoc list of job banned:ban holder
	var/list/datum/job_ban/job_bans = list()

// Get us a query
/datum/job_ban_holder/proc/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT bantime, bantype, reason, job, duration, expiration_time, a_ckey FROM ban
		WHERE ckey LIKE :ckey AND ((bantype LIKE 'JOB_TEMPBAN' AND expiration_time > NOW()) OR (bantype LIKE 'JOB_PERMABAN')) AND ISNULL(unbanned)
		ORDER BY bantime DESC LIMIT 100"}, // If someone has 100 job bans we have bigger problems
		list("ckey" = C.ckey)
	)
	return query

// Uses the query from above
/datum/job_ban_holder/proc/process_query(datum/db_query/Q)
	while(Q.NextRow())
		var/datum/job_ban/JB = new()
		JB.bantime = Q.item[1]
		JB.bantype  = Q.item[2]
		JB.reason = Q.item[3]
		JB.job = Q.item[4]
		JB.duration = Q.item[5]
		JB.expiration_time = Q.item[6]
		JB.a_ckey = Q.item[7]
		job_bans[JB.job] = JB // Save it assoc

// Check if someone is job banned
/datum/job_ban_holder/proc/is_banned(job)
	if(job in job_bans)
		return TRUE
	return FALSE

// Reload the job bans
/datum/job_ban_holder/proc/reload_jobbans(client/C)
	var/datum/db_query/data = get_query(C)
	if(!data.warn_execute())
		qdel(data)
		return

	job_bans.Cut() // Empty it
	process_query(data)
	qdel(data)

// dont mess with this
/datum/job_ban_holder/vv_edit_var(var_name, var_value)
	return FALSE

/datum/job_ban_holder/CanProcCall(procname)
	return FALSE

// Job ban data "model"
/datum/job_ban
	/// Time of ban
	var/bantime
	/// Type of ban
	var/bantype
	/// Reason for ban
	var/reason
	/// Job banned itself
	var/job
	/// Duration (if temp)
	var/duration
	/// Expiry time (if temp)
	var/expiration_time
	/// Admin who did it
	var/a_ckey

// or this
/datum/job_ban/vv_edit_var(var_name, var_value)
	return FALSE
