proc/sql_report_admin_karma(var/client/spender, var/receiver_key, var/karma_given)
	var/sqlspenderkey = spender.key
	var/sqlreceiverrole = "None"
	var/sqlreceiverspecial = "None"

	var/sqlspenderip = spender.address

	if(!dbcon.IsConnected())
		log_game("SQL ERROR during karma logging. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("karma")] (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time) VALUES ('ADMIN GIFT', '[sqlspenderkey]', 'ADMIN GIFT', '[receiver_key]', '[sqlreceiverrole]', '[sqlreceiverspecial]', '[sqlspenderip]', '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karma logging. Error : \[[err]\]\n")


		query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[receiver_key]'")
		query.Execute()

		var/karma
		var/id
		while(query.NextRow())
			id = query.item[1]
			karma = text2num(query.item[3])
		if(karma == null)
			karma = karma_given
			query = dbcon.NewQuery("INSERT INTO [format_table_name("karmatotals")] (byondkey, karma) VALUES ('[receiver_key]', [karma])")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (adding new key). Error : \[[err]\]\n")
		else
			karma += karma_given
			query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karma=[karma] WHERE id=[id]")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (updating existing entry). Error : \[[err]\]\n")

/client/proc/give_karma_list()
	set name = "Give Karma"
	set desc = "Let the gods know whether someone's been nice."
	set category = "Admin"

	if(!check_rights(R_PERMISSIONS))
		return

	var/list/karma_list = list("Write ckey manually")
	for(var/client/C in clients)
		karma_list += C
	if(!karma_list.len || karma_list.len == 1)
		to_chat(usr, "\red There's no-one to spend your karma on.")
		return

	var/pickedclient = input("Who would you like to award Karma to?", "Give Karma", "Write ckey manually") as null|anything in karma_list
	var/karma_receiver
	if(isnull(pickedclient))
		return
	if(pickedclient == "Write ckey manually")
		pickedclient = input(src, "Write down ckey of the player you wish to give karma", "Give karma manually") as message|null
	karma_receiver = pickedclient
	give_karma(karma_receiver)
	return

/client/proc/give_karma(var/receiver)

	var/karma_gift = input(src,"How much karma points you want to spent?","Karma Gift",0) as num
	if(!isnum(karma_gift))
		karma_gift = 0
		return
	log_admin("[usr.key] gave [karma_gift] karma points to [receiver]")
	message_admins("[usr.key] gave [karma_gift] karma points to [receiver]")
	sql_report_admin_karma(src, receiver, karma_gift)
	return

proc/sql_report_objective_karma(var/receiver_key, var/karma_given)
	var/sqlreceiverrole = "None"
	var/sqlreceiverspecial = "None"


	if(!dbcon.IsConnected())
		log_game("SQL ERROR during karma logging. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("karma")] (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time) VALUES ('ROLE/JOB GIFT', 'OBJECTIVES', 'ROLE/JOB GIFT', '[receiver_key]', '[sqlreceiverrole]', '[sqlreceiverspecial]', 'ROLE/JOB GIFT', '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karma logging. Error : \[[err]\]\n")


		query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[receiver_key]'")
		query.Execute()

		var/karma
		var/id
		while(query.NextRow())
			id = query.item[1]
			karma = text2num(query.item[3])
		if(karma == null)
			karma = karma_given
			query = dbcon.NewQuery("INSERT INTO [format_table_name("karmatotals")] (byondkey, karma) VALUES ('[receiver_key]', [karma])")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (adding new key). Error : \[[err]\]\n")
		else
			karma += karma_given
			query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karma=[karma] WHERE id=[id]")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (updating existing entry). Error : \[[err]\]\n")
