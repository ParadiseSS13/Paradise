var/global/datum/controller/process/feedback/feedback_controller

/datum/feedback_variable
	var/variable
	var/value
	var/details

/datum/controller/process/feedback
	var/list/messages = list()		//Stores messages of non-standard frequencies
	var/list/messages_admin = list()

	var/list/msg_common = list()
	var/list/msg_science = list()
	var/list/msg_command = list()
	var/list/msg_medical = list()
	var/list/msg_engineering = list()
	var/list/msg_security = list()
	var/list/msg_deathsquad = list()
	var/list/msg_syndicate = list()
	var/list/msg_syndteam = list()
	var/list/msg_mining = list()
	var/list/msg_cargo = list()
	var/list/msg_service = list()

	var/list/datum/feedback_variable/feedback_variables = new()


/datum/controller/process/feedback/setup()
	name = "feedback"
	schedule_interval = 10 MINUTES//only used for counting player and admin numbers currently

DECLARE_GLOBAL_CONTROLLER(feedback, feedback_controller)

/datum/controller/process/feedback/doWork()
	pollPlayerAndAdminCount()

/datum/controller/process/feedback/proc/pollPlayerAndAdminCount()
	if(!config.sql_enabled)
		return

	var/admincount = admins.len

	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount += 1

	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during player polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (admincount, playercount, time) VALUES ([admincount], [playercount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during player polling. Error : \[[err]\]\n")

//execute at round end
/datum/controller/process/feedback/proc/sql_commit_feedback()
	if(!feedback_variables.len)
		log_game("Round ended without any feedback. Something went wrong, probably.")
		return

	var/pda_msg_amt = 0
	var/rc_msg_amt = 0

	for(var/obj/machinery/message_server/MS in machines)
		if(MS.pda_msgs.len > pda_msg_amt)
			pda_msg_amt = MS.pda_msgs.len
		if(MS.rc_msgs.len > rc_msg_amt)
			rc_msg_amt = MS.rc_msgs.len

	feedback_report("radio_usage","COM-[msg_common.len]")
	feedback_report("radio_usage","SCI-[msg_science.len]")
	feedback_report("radio_usage","HEA-[msg_command.len]")
	feedback_report("radio_usage","MED-[msg_medical.len]")
	feedback_report("radio_usage","ENG-[msg_engineering.len]")
	feedback_report("radio_usage","SEC-[msg_security.len]")
	feedback_report("radio_usage","DTH-[msg_deathsquad.len]")
	feedback_report("radio_usage","SYN-[msg_syndicate.len]")
	feedback_report("radio_usage","SYT-[msg_syndteam.len]")
	feedback_report("radio_usage","MIN-[msg_mining.len]")
	feedback_report("radio_usage","CAR-[msg_cargo.len]")
	feedback_report("radio_usage","SRV-[msg_service.len]")
	feedback_report("radio_usage","OTH-[messages.len]")
	feedback_report("radio_usage","PDA-[pda_msg_amt]")
	feedback_report("radio_usage","RC-[rc_msg_amt]")


	feedback_report("round_end","[time2text(world.realtime)]")

	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during feedback reporting. Failed to connect.")
	else

		var/DBQuery/max_query = dbcon.NewQuery("SELECT MAX(roundid) AS max_round_id FROM [format_table_name("feedback")]")
		max_query.Execute()

		var/newroundid

		while(max_query.NextRow())
			newroundid = max_query.item[1]

		if(!(isnum(newroundid)))
			newroundid = text2num(newroundid)

		if(isnum(newroundid))
			newroundid++
		else
			newroundid = 1

		for(var/datum/feedback_variable/item in feedback_variables)
			var/variable = item.variable
			var/value = item.value
			var/details = item.details

			var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("feedback")] (id, round_id, time, var_name, var_value, details) VALUES (null, [newroundid], Now(), '[variable]', '[value]', '[details]')")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during feedback reporting. Error : \[[err]\]\n")

//the proc used for ALL feedback. First argument is the type of feedback: "Traitor item bought", second one is its specifics: "Holoparasite injector"
//use 'amount' to log the adequate amount of times an action was done. The amount will stack with other uses that shift, so don't use if the number is important by itself
/proc/feedback_report(var/new_variable, var/new_details, var/amount = 1)
	if(!feedback_controller)
		return

	new_variable = sanitizeSQL(new_variable)
	new_details = sanitizeSQL(new_details)

	for(var/datum/feedback_variable/FV in feedback_controller.feedback_variables)
		if(FV.variable == new_variable && FV.details == new_details)//just iterate the value if a variable exists already
			FV.value += amount
			return

	var/datum/feedback_variable/FV = new()
	FV.variable = new_variable
	FV.details = new_details
	FV.value = amount
	feedback_controller.feedback_variables += FV

// ======= ORPHANED PROCS =======
// for the sake of keeping it all in one file, these procs don't do things directly with the controller

/proc/sql_report_death(mob/living/carbon/human/H)
	if(!config.sql_enabled)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/area/placeofdeath = get_area(H.loc)
	var/podname = "Unknown"
	if(placeofdeath)
		podname = sanitizeSQL(placeofdeath.name)

	var/sqlname = sanitizeSQL(H.real_name)
	var/sqlkey = sanitizeSQL(H.key)
	var/sqlpod = sanitizeSQL(podname)
	var/sqlspecial = sanitizeSQL(H.mind.special_role)
	var/sqljob = sanitizeSQL(H.mind.assigned_role)
	var/laname
	var/lakey
	if(H.lastattacker)
		laname = sanitizeSQL(H.lastattacker:real_name)
		lakey = sanitizeSQL(H.lastattacker:key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"
//	to_chat(world, "INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.bruteloss], [H.getFireLoss()], [H.brainloss], [H.getOxyLoss()])")
	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.getBruteLoss()], [H.getFireLoss()], [H.brainloss], [H.getOxyLoss()], '[coord]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")


/proc/sql_report_cyborg_death(mob/living/silicon/robot/H)
	if(!config.sql_enabled)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = get_area(T.loc)
	var/podname = sanitizeSQL(placeofdeath.name)

	var/sqlname = sanitizeSQL(H.real_name)
	var/sqlkey = sanitizeSQL(H.key)
	var/sqlpod = sanitizeSQL(podname)
	var/sqlspecial = sanitizeSQL(H.mind.special_role)
	var/sqljob = sanitizeSQL(H.mind.assigned_role)
	var/laname
	var/lakey
	if(H.lastattacker)
		laname = sanitizeSQL(H.lastattacker:real_name)
		lakey = sanitizeSQL(H.lastattacker:key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"
	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.getBruteLoss()], [H.getFireLoss()], [H.brainloss], [H.getOxyLoss()], '[coord]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")
