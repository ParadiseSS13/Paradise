SUBSYSTEM_DEF(logging)
	name = "Logging"
	priority = INIT_ORDER_LOGGING
	flags = SS_NO_FIRE
	var/list/datum/log_record/logs = list()	// Assoc list of assoc lists (ckey, (log_type, list/logs))

/datum/controller/subsystem/logging/proc/add_log(ckey, datum/log_record/log)
	if(!ckey)
		log_debug("SSLogging.add_log called with an invalid ckey")
		return

	if(!logs[ckey])
		logs[ckey] = list()

	var/list/log_types_list = logs[ckey]

	if(!log_types_list[log.log_type])
		log_types_list[log.log_type] = list()

	var/list/datum/log_record/log_records = log_types_list[log.log_type]
	log_records.Add(log)

/datum/controller/subsystem/logging/proc/get_ckeys_logged()
	var/list/ckeys = list()
	for(var/ckey in logs)
		ckeys.Add(ckey)
	return ckeys

/* Returns the logs of a given ckey and log_type
 * If no logs exist it will return an empty list
*/
/datum/controller/subsystem/logging/proc/get_logs_by_type(ckey, log_type)
	if(!ckey)
		log_debug("SSLogging.get_logs_by_type called with an invalid ckey")
		return
	if(!log_type || !(log_type in ALL_LOGS))
		log_debug("SSLogging.get_logs_by_type called with an invalid log_type '[log_type]'")
		return

	var/list/log_types_list = logs[ckey]
	// Check if logs exist for the ckey
	if(!log_types_list?.len)
		return list()

	var/list/datum/log_record/log_records = log_types_list[log_type]

	// Check if logs exist for this type
	if(!log_records)
		return list()
	return log_records
