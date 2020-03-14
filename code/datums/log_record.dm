/datum/log_record
	var/log_type		// Type of log
	var/raw_time		// When did this happen?
	var/what			// What happened
	var/atom/who		// Who did it
	var/target			// Who/what was targeted (can be a string)
	var/turf/where		// Where did it happen

/datum/log_record/New(_log_type, _who, _what, _target, _where, _raw_time)
	log_type = _log_type
	
	who = _who
	what = _what
	target = _target
	if(!_where)
		_where = get_turf(_who)
	where = _where
	if(!_raw_time)
		_raw_time = world.time
	raw_time = _raw_time

/proc/compare_log_record(datum/log_record/A, datum/log_record/B)
	var/time_diff = A.raw_time - B.raw_time
	if(!time_diff) // Same time
		return cmp_text_asc(A.log_type, B.log_type)
	return time_diff
	