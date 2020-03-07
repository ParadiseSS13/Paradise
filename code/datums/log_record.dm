/datum/log_record
	var/log_type		// Type of log
	var/time_stamp		// When did this happen?
	var/what			// What happened
	var/atom/who		// Who did it
	var/atom/target		// Who/what was targeted
	var/turf/where		// Where did it happen

/datum/log_record/New(_log_type, _who, _what, _target, _where, _time_stamp)
	log_type = _log_type
	
	who = _who
	what = _what
	target = _target
	if(!_where)
		_where = get_turf(_who)
	where = _where
	if(!_time_stamp)
		_time_stamp = gameTimestamp()
	time_stamp = _time_stamp
