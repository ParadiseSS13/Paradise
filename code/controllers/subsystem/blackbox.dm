SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 6000
	flags = SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX

	var/list/msg_common = list()
	var/list/msg_science = list()
	var/list/msg_command = list()
	var/list/msg_medical = list()
	var/list/msg_engineering = list()
	var/list/msg_security = list()
	var/list/msg_deathsquad = list()
	var/list/msg_syndicate = list()
	var/list/msg_syndteam = list()
	var/list/msg_service = list()
	var/list/msg_cargo = list()
	var/list/msg_other = list()

	var/list/feedback = list()	//list of datum/feedback_variable

//poll population
/datum/controller/subsystem/blackbox/fire()
	if(!SSdbcore.Connect())
		return
	var/playercount = 0
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			playercount += 1
	var/admincount = GLOB.admins.len
	var/datum/DBQuery/query_record_playercount = SSdbcore.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time) VALUES ([playercount], [admincount], '[SQLtime()]')")
	query_record_playercount.Execute()

/datum/controller/subsystem/blackbox/Recover()
	msg_common = SSblackbox.msg_common
	msg_science = SSblackbox.msg_science
	msg_command = SSblackbox.msg_command
	msg_medical = SSblackbox.msg_medical
	msg_engineering = SSblackbox.msg_engineering
	msg_security = SSblackbox.msg_security
	msg_deathsquad = SSblackbox.msg_deathsquad
	msg_syndicate = SSblackbox.msg_syndicate
	msg_syndteam = SSblackbox.msg_syndteam
	msg_service = SSblackbox.msg_service
	msg_cargo = SSblackbox.msg_cargo
	msg_other = SSblackbox.msg_other
	
	feedback = SSblackbox.feedback

//no touchie
/datum/controller/subsystem/blackbox/can_vv_get(var_name)
	if(var_name == "feedback")
		return FALSE
	return ..()

/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	return FALSE

/datum/controller/subsystem/blackbox/Shutdown()
	var/pda_msg_amt = 0
	var/rc_msg_amt = 0

	for (var/obj/machinery/message_server/MS in message_servers)
		if(MS.pda_msgs.len > pda_msg_amt)
			pda_msg_amt = MS.pda_msgs.len
		if(MS.rc_msgs.len > rc_msg_amt)
			rc_msg_amt = MS.rc_msgs.len

	set_details("radio_usage","")
	add_details("radio_usage", "COM-[msg_common.len]")
	add_details("radio_usage", "SCI-[msg_science.len]")
	add_details("radio_usage", "HEA-[msg_command.len]")
	add_details("radio_usage", "MED-[msg_medical.len]")
	add_details("radio_usage", "ENG-[msg_engineering.len]")
	add_details("radio_usage", "SEC-[msg_security.len]")
	add_details("radio_usage", "DTH-[msg_deathsquad.len]")
	add_details("radio_usage", "SYN-[msg_syndicate.len]")
	add_details("radio_usage", "SYT-[msg_syndteam.len]")
	add_details("radio_usage", "SRV-[msg_service.len]")
	add_details("radio_usage", "CAR-[msg_cargo.len]")
	add_details("radio_usage", "OTH-[msg_other.len]")
	add_details("radio_usage", "PDA-[pda_msg_amt]")
	add_details("radio_usage", "RC-[rc_msg_amt]")

	if(!SSdbcore.Connect())
		return

	var/round_id

	var/datum/DBQuery/query_feedback_max_id = SSdbcore.NewQuery("SELECT MAX(round_id) AS round_id FROM [format_table_name("feedback")]")
	if(!query_feedback_max_id.Execute())
		return
	while (query_feedback_max_id.NextRow())
		round_id = query_feedback_max_id.item[1]

	if(!isnum(round_id))
		round_id = text2num(round_id)
	round_id++

	var/sqlrowlist = ""

	for (var/datum/feedback_variable/FV in feedback)
		if(sqlrowlist != "")
			sqlrowlist += ", " //a comma (,) at the start of the first row to insert will trigger a SQL error

		sqlrowlist += "(null, Now(), [round_id], \"[sanitizeSQL(FV.get_variable())]\", [FV.get_value()], \"[sanitizeSQL(FV.get_details())]\")"

	if(sqlrowlist == "")
		return

	var/datum/DBQuery/query_feedback_save = SSdbcore.NewQuery("INSERT DELAYED IGNORE INTO [format_table_name("feedback")] VALUES " + sqlrowlist)
	query_feedback_save.Execute()

/datum/controller/subsystem/blackbox/proc/LogBroadcast(blackbox_msg, freq)
	switch(freq)
		if(PUB_FREQ)
			msg_common += blackbox_msg
		if(SCI_FREQ)
			msg_science += blackbox_msg
		if(COMM_FREQ)
			msg_command += blackbox_msg
		if(MED_FREQ)
			msg_medical += blackbox_msg
		if(ENG_FREQ)
			msg_engineering += blackbox_msg
		if(SEC_FREQ)
			msg_security += blackbox_msg
		if(DTH_FREQ)
			msg_deathsquad += blackbox_msg
		if(SYND_FREQ)
			msg_syndicate += blackbox_msg
		if(SYNDTEAM_FREQ)
			msg_syndteam += blackbox_msg
		if(SUP_FREQ)
			msg_cargo += blackbox_msg
		if(SRV_FREQ)
			msg_service += blackbox_msg
		else
			msg_other += blackbox_msg

/datum/controller/subsystem/blackbox/proc/find_feedback_datum(variable)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.get_variable() == variable)
			return FV

	var/datum/feedback_variable/FV = new(variable)
	feedback += FV
	return FV

/datum/controller/subsystem/blackbox/proc/set_val(variable, value)
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.set_value(value)

/datum/controller/subsystem/blackbox/proc/inc(variable, value)
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.inc(value)

/datum/controller/subsystem/blackbox/proc/dec(variable,value)
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.dec(value)

/datum/controller/subsystem/blackbox/proc/set_details(variable,details)
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.set_details(details)

/datum/controller/subsystem/blackbox/proc/add_details(variable,details)
	var/datum/feedback_variable/FV = find_feedback_datum(variable)
	FV.add_details(details)

/datum/controller/subsystem/blackbox/proc/ReportDeath(mob/living/L)
	if(!SSdbcore.Connect())
		return
	if(!L || !L.key || !L.mind)
		return
	var/turf/T = get_turf(L)
	var/area/placeofdeath = get_area(T.loc)
	var/sqlname = sanitizeSQL(L.real_name)
	var/sqlkey = sanitizeSQL(L.ckey)
	var/sqljob = sanitizeSQL(L.mind.assigned_role)
	var/sqlspecial = sanitizeSQL(L.mind.special_role)
	var/sqlpod = sanitizeSQL(placeofdeath.name)
	var/laname
	var/lakey
	if(L.lastattacker && ismob(L.lastattacker))
		var/mob/LA = L.lastattacker
		laname = sanitizeSQL(LA.real_name)
		lakey = sanitizeSQL(LA.key)
	var/sqlgender = sanitizeSQL(L.gender)
	var/sqlbrute = sanitizeSQL(L.getBruteLoss())
	var/sqlfire = sanitizeSQL(L.getFireLoss())
	var/sqlbrain = sanitizeSQL(L.getBrainLoss())
	var/sqloxy = sanitizeSQL(L.getOxyLoss())
	var/coord = sanitizeSQL("[L.x], [L.y], [L.z]")
	var/datum/DBQuery/query_report_death = SSdbcore.NewQuery("INSERT INTO [format_table_name("death")] \
(name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, coord) \
VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[SQLtime()]', '[laname]', '[lakey]', '[sqlgender]', \
[sqlbrute], [sqlfire], [sqlbrain], [sqloxy], '[coord]')")
	query_report_death.Execute()


//feedback variable datum, for storing all kinds of data
/datum/feedback_variable
	var/variable
	var/value
	var/details

/datum/feedback_variable/New(param_variable, param_value = 0)
	variable = param_variable
	value = param_value

/datum/feedback_variable/proc/inc(num = 1)
	if(isnum(value))
		value += num
	else
		value = text2num(value)
		if(isnum(value))
			value += num
		else
			value = num

/datum/feedback_variable/proc/dec(num = 1)
	if(isnum(value))
		value -= num
	else
		value = text2num(value)
		if(isnum(value))
			value -= num
		else
			value = -num

/datum/feedback_variable/proc/set_value(num)
	if(isnum(num))
		value = num

/datum/feedback_variable/proc/get_value()
	if(!isnum(value))
		return 0
	return value

/datum/feedback_variable/proc/get_variable()
	return variable

/datum/feedback_variable/proc/set_details(text)
	if(istext(text))
		details = text

/datum/feedback_variable/proc/add_details(text)
	if(istext(text))
		text = replacetext(text, " ", "_")
		if(!details)
			details = text
		else
			details += " [text]"

/datum/feedback_variable/proc/get_details()
	return details

/datum/feedback_variable/proc/get_parsed()
	return list(variable, value, details)
