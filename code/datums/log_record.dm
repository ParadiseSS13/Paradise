/datum/log_record
	var/log_type		// Type of log
	var/raw_time		// When did this happen?
	var/what			// What happened
	var/who				// Who did it
	var/target			// Who/what was targeted
	var/where			// Where did it happen

/datum/log_record/New(_log_type, _who, _what, _target, _where, _raw_time)
	log_type = _log_type

	who = get_subject_text(_who, _log_type)
	what = _what
	target = get_subject_text(_target, _log_type)
	if(!istext(_where) && !isturf(_where))
		_where = get_turf(_who)
	if(isturf(_where))
		var/turf/T = _where
		where = ADMIN_COORDJMP(T)
	else
		where = _where
	if(!_raw_time)
		_raw_time = world.time
	raw_time = _raw_time

/datum/log_record/proc/get_subject_text(subject, log_type)
	if(ismob(subject) || isclient(subject) || istype(subject, /datum/mind))
		. = key_name_admin(subject)
		if(should_log_health(log_type) && isliving(subject))
			. += get_health_string(subject)
	else if(isatom(subject))
		var/atom/A = subject
		. = A.name
	else if(istype(subject, /datum))
		var/datum/D = subject
		return D.type
	else
		. = subject

/datum/log_record/proc/get_health_string(mob/living/L)
	var/OX = L.getOxyLoss() > 50 	? 	"<b>[L.getOxyLoss()]</b>" 		: L.getOxyLoss()
	var/TX = L.getToxLoss() > 50 	? 	"<b>[L.getToxLoss()]</b>" 		: L.getToxLoss()
	var/BU = L.getFireLoss() > 50 	? 	"<b>[L.getFireLoss()]</b>" 		: L.getFireLoss()
	var/BR = L.getBruteLoss() > 50 	? 	"<b>[L.getBruteLoss()]</b>" 	: L.getBruteLoss()
	var/ST = L.getStaminaLoss() > 50 	? 	"<b>[L.getStaminaLoss()]</b>" 	: L.getStaminaLoss()
	return " ([L.health]: <font color='deepskyblue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font> - <font color='cyan'>[ST]</font>)"

/datum/log_record/proc/should_log_health(log_type)
	if(log_type == ATTACK_LOG || log_type == DEFENSE_LOG)
		return TRUE
	return FALSE

/proc/compare_log_record(datum/log_record/A, datum/log_record/B)
	var/time_diff = A.raw_time - B.raw_time
	if(!time_diff) // Same time
		return cmp_text_asc(A.log_type, B.log_type)
	return time_diff
