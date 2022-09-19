/proc/find_security_record(field, value)
	return find_record(field, value, GLOB.data_core.security)

/proc/find_record(field, value, list/L)
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R
