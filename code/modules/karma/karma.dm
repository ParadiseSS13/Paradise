proc/sql_report_karma(var/mob/spender, var/mob/receiver)
	var/sqlspendername = sanitizeSQL(spender.name)
	var/sqlspenderkey = spender.ckey
	var/sqlreceivername = sanitizeSQL(receiver.name)
	var/sqlreceiverkey = receiver.ckey
	var/sqlreceiverrole = "None"
	var/sqlreceiverspecial = "None"

	var/sqlspenderip = spender.client.address

	if(receiver.mind)
		if(receiver.mind.special_role)
			sqlreceiverspecial = sanitizeSQL(receiver.mind.special_role)
		if(receiver.mind.assigned_role)
			sqlreceiverrole = sanitizeSQL(receiver.mind.assigned_role)

	if(!dbcon.IsConnected())
		log_game("SQL ERROR during karma logging. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("karma")] (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time) VALUES ('[sqlspendername]', '[sqlspenderkey]', '[sqlreceivername]', '[sqlreceiverkey]', '[sqlreceiverrole]', '[sqlreceiverspecial]', '[sqlspenderip]', '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karma logging. Error : \[[err]\]\n")


		query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[receiver.ckey]'")
		query.Execute()

		var/karma
		var/id
		while(query.NextRow())
			id = query.item[1]
			karma = text2num(query.item[3])
		if(karma == null)
			karma = 1
			query = dbcon.NewQuery("INSERT INTO [format_table_name("karmatotals")] (byondkey, karma) VALUES ('[receiver.ckey]', [karma])")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (adding new key). Error : \[[err]\]\n")
		else
			karma += 1
			query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karma=[karma] WHERE id=[id]")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (updating existing entry). Error : \[[err]\]\n")


var/list/karma_spenders = list()

// Returns 1 if mob can give karma at all; if not, tells them why
/mob/proc/can_give_karma()
	if(!client)
		return 0
	if(config.disable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return 0
	if(!ticker || !player_list.len || (ticker.current_state == GAME_STATE_PREGAME))
		to_chat(src, "<span class='warning'>You can't award karma until the game has started.</span>")
		return 0
	if(client.karma_spent || (ckey in karma_spenders))
		to_chat(src, "<span class='warning'>You've already spent your karma for the round.</span>")
		return 0
	return 1

// Returns 1 if mob can give karma to M; if not, tells them why
/mob/proc/can_give_karma_to_mob(mob/M)
	if(!can_give_karma())
		return 0
	if(!istype(M))
		to_chat(src, "<span class='warning'>That's not a mob.</span>")
		return 0
	if(!M.client)
		to_chat(src, "<span class='warning'>That mob has no client connected at the moment.</span>")
		return 0
	if(ckey == M.ckey)
		to_chat(src, "<span class='warning'>You can't spend karma on yourself!</span>")
		return 0
	if(client.address == M.client.address)
		message_admins("<span class='warning'>Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!</span>")
		log_game("Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!")
		to_chat(src, "<span class='warning'>You can't spend karma on someone connected from the same IP.</span>")
		return 0
	return 1


/mob/verb/spend_karma_list()
	set name = "Award Karma"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!can_give_karma())
		return

	var/list/karma_list = list()
	for(var/mob/M in player_list)
		if(!(M.client && M.mind))
			continue
		if(M == src)
			continue
		if(!isobserver(src) && isNonCrewAntag(M))
			continue // Don't include special roles for non-observers, because players use it to meta
		karma_list += M

	if(!karma_list.len)
		to_chat(usr, "<span class='warning'>There's no-one to spend your karma on.</span>")
		return

	var/pickedmob = input("Who would you like to award Karma to?", "Award Karma", "Cancel") as null|mob in karma_list

	if(isnull(pickedmob))
		return

	spend_karma(pickedmob)

/mob/verb/spend_karma(var/mob/M)
	set name = "Award Karma to Player"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!M)
		to_chat(usr, "Please right click a mob to award karma directly, or use the 'Award Karma' verb to select a player from the player listing.")
		return
	if(config.disable_karma) // this is here because someone thought it was a good idea to add an alert box before checking if they can even give a mob karma
		to_chat(usr, "<span class='warning'>Karma is disabled.</span>")
		return
	if(alert("Give [M.name] good karma?", "Karma", "Yes", "No") != "Yes")
		return
	if(!can_give_karma_to_mob(M))
		return // Check again, just in case things changed while the alert box was up

	M.client.karma += 1
	to_chat(usr, "Good karma spent on [M.name].")
	client.karma_spent = 1
	karma_spenders += ckey

	var/special_role = "None"
	var/assigned_role = "None"
	var/karma_diary = file("data/logs/karma_[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	if(M.mind)
		if(M.mind.special_role)
			special_role = M.mind.special_role
		if(M.mind.assigned_role)
			assigned_role = M.mind.assigned_role
	karma_diary << "[M.name] ([M.key]) [assigned_role]/[special_role]: [M.client.karma] - [time2text(world.timeofday, "hh:mm:ss")] given by [key]"
	message_admins("[usr.ckey] gave [M.client] good karma.")
	sql_report_karma(src, M)

/mob/verb/reduce_karma_list()
	set name = "Reduce Karma"
	set desc = "Let the gods know whether someone's been really bad. Can only be used once per round."
	set category = "Special Verbs"

	if(!can_give_karma())
		return

	var/list/karma_list = list()
	for(var/mob/M in player_list)
		if(!(M.client && M.mind))
			continue
		if(M == src)
			continue
		if(!isobserver(src) && isNonCrewAntag(M))
			continue
		karma_list += M

	if(!karma_list.len)
		to_chat(usr, "<span class='warning'>There's no-one to blame here.</span>")
		return

	var/pickedmob = input("Who's been really bad today?", "Reduce Karma", "Cancel") as null|mob in karma_list

	if(isnull(pickedmob))
		return

	reduce_karma(pickedmob)

/mob/verb/reduce_karma(var/mob/M)
	set name = "Reduce Player Karma"
	set desc = "Let the gods know whether someone's been really bad. Can only be used once per round."
	set category = "Special Verbs"

	if(!M)
		to_chat(usr, "Please right click a mob to reduce their karma directly, or use the 'Reduce Karma' verb to select a player from the player listing.")
		return
	if(config.disable_karma)
		to_chat(usr, "<span class='warning'>Karma is disabled.</span>")
		return
	if(alert("Reduce [M.name]'s karma?", "Karma", "Yes", "No") != "Yes")
		return
	if(!can_give_karma_to_mob(M))
		return

	M.client.karmatrah(2,0,M.client)
	to_chat(usr, "[M.name] lost his bit of karma. You should be really proud of yourself.")
	client.karma_spent = 1
	karma_spenders += ckey

	var/special_role = "None"
	var/assigned_role = "None"
	var/karma_diary = file("data/logs/karma_[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	if(M.mind)
		if(M.mind.special_role)
			special_role = M.mind.special_role
		if(M.mind.assigned_role)
			assigned_role = M.mind.assigned_role
	karma_diary << "[M.name] ([M.key]) [assigned_role]/[special_role]: [M.client.karma] - [time2text(world.timeofday, "hh:mm:ss")] taken away by [key]"

	sql_report_karma(src, M)

/client/verb/check_karma()
	set name = "Check Karma"
	set desc = "Reports how much karma you have accrued."
	set category = "Special Verbs"

	if(config.disable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return 0

	var/currentkarma=verify_karma()
	to_chat(usr, {"<br>You have <b>[currentkarma]</b> available."})
	return

/client/proc/verify_karma()
	var/currentkarma=0
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Unable to connect to karma database. Please try again later.<br></span>")
		return
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT karma, karmaspent FROM [format_table_name("karmatotals")] WHERE byondkey='[src.ckey]'")
		query.Execute()

		var/totalkarma
		var/karmaspent
		while(query.NextRow())
			totalkarma = query.item[1]
			karmaspent = query.item[2]
		currentkarma = (text2num(totalkarma) - text2num(karmaspent))
/*		if(totalkarma)
			to_chat(usr, {"<br>You have <b>[currentkarma]</b> available.<br>)
You've gained <b>[totalkarma]</b> total karma in your time here.<br>"}
		else
			to_chat(usr, "<b>Your total karma is:</b> 0<br>")*/
	return currentkarma

/client/verb/karmashop()
	set name = "karmashop"
	set desc = "Spend your hard-earned karma here"
	set hidden = 1

	if(config.disable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return 0

	karmashopmenu()
	return

/client/proc/karmashopmenu()
	var/dat = "<html><body><center>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=0' [karma_tab == 0 ? "class='linkOn'" : ""]>Job Unlocks</a>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=1' [karma_tab == 1 ? "class='linkOn'" : ""]>Species Unlocks</a>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=2' [karma_tab == 2 ? "class='linkOn'" : ""]>Item Unlocks</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(karma_tab)
		if(0) // Job Unlocks
			dat += {"
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=1'>Unlock Barber -- 5KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=6'>Unlock Mechanic -- 10KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=2'>Unlock Brig Physician -- 15KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=9'>Unlock Security Pod Pilot -- 15KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=3'>Unlock Nanotrasen Representative -- 30KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=5'>Unlock Blueshield -- 30KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy=7'>Unlock Magistrate -- 30KP</a><br>
			"}

		if(1) // Species Unlocks
			dat += {"

			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=10'>Unlock Diona -- 25KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=1'>Unlock Machine People -- 30KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=7'>Unlock Drask -- 30KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=2'>Unlock Kidan -- 30KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=12'>Unlock Wryn -- 30KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=4'>Unlock Vox -- 40KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=6'>Unlock Plasmaman -- 40KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=13'>Unlock Skrell -- 45KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=5'>Unlock Slime People -- 50KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=9'>Unlock Tajaran -- 60KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=3'>Unlock Grey -- 60KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=11'>Unlock Nucleation -- 70KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=14'>Unlock Vulpkanin -- 75KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy2=8'>Unlock Unathi -- 80KP</a><br>
			"}

		if(2) // Item Unlocks
			dat += {"
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=4001'>Unlock Dio Brando's costume -- 5KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=4002'>Unlock Sneaking suit -- 5KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=4003'>Unlock Adeptus Mechanicus -- 5KP</a>(for Engineering only)<br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=4005'>Unlock Simon Coat -- 5KP</a>(for Heads only)<br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=9001'>Unlock Kamina Cape -- 10KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=4006'>Unlock H.E.V. -- 10KP</a>(for Engineering only)<br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=4008'>Unlock Alchemist Outfit -- 10KP</a>(for Chemist and Librarian only)<br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=1'>Unlock DIO Set -- 15KP</a><br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=2'>Unlock Slastena Set -- 15KP</a>(for Chef and Civilians only)<br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=0002'>Unlock Sergeant's Helmet -- 30KP</a>(for Head of Security and Warden only)<br>
			<a href='?src=[UID()];karmashop=shop;KarmaBuy3=0003'>Unlock Victorian Clothes -- 40KP</a><br>
			"}

	dat += "<br><B>PLEASE NOTE THAT PEOPLE WHO TRY TO GAME THE KARMA SYSTEM WILL END UP ON THE WALL OF SHAME. THIS INCLUDES BUT IS NOT LIMITED TO TRADES, OOC KARMA BEGGING, CODE EXPLOITS, ETC.</B>"
	dat += "</center></body></html>"

	var/datum/browser/popup = new(usr, "karmashop", "<div align='center'>Karma Shop</div>", 400, 400)
	popup.set_content(dat)
	popup.open(0)
	return

/client/proc/DB_job_unlock(var/job,var/cost)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.ckey]'")
	query.Execute()

	var/dbjob
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbjob = query.item[3]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, job) VALUES ('[usr.ckey]','[job]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error: \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error: \[[err]\]\n")
			return
		else
			to_chat(usr, "You have unlocked [job].")
			message_admins("[key_name(usr)] has unlocked [job].")
			karmacharge(cost)

	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		if(!(job in joblist))
			joblist += job
			var/newjoblist = jointext(joblist,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET job='[newjoblist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				return
			else
				to_chat(usr, "You have unlocked [job].")
				message_admins("[key_name(usr)] has unlocked [job].")
				karmacharge(cost)
		else
			to_chat(usr, "You already have this job unlocked!")
			return

/client/proc/DB_species_unlock(var/species,var/cost)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.ckey]'")
	query.Execute()

	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbspecies = query.item[4]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, species) VALUES ('[usr.ckey]','[species]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			return
		else
			to_chat(usr, "You have unlocked [species].")
			message_admins("[key_name(usr)] has unlocked [species].")
			karmacharge(cost)

	if(dbckey)
		var/list/specieslist = splittext(dbspecies,",")
		if(!(species in specieslist))
			specieslist += species
			var/newspecieslist = jointext(specieslist,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET species='[newspecieslist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				return
			else
				to_chat(usr, "You have unlocked [species].")
				message_admins("[key_name(usr)] has unlocked [species].")
				karmacharge(cost)
		else
			to_chat(usr, "You already have this species unlocked!")
			return

/client/proc/karmacharge(var/cost,var/refund = 0)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[usr.ckey]'")
	query.Execute()

	while(query.NextRow())
		var/spent = text2num(query.item[4])
		if(refund)
			spent -= cost
		else
			spent += cost
		query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karmaspent=[spent] WHERE byondkey='[usr.ckey]'")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karmaspent updating (updating existing entry). Error: \[[err]\]\n")
			message_admins("SQL ERROR during karmaspent updating (updating existing entry). Error: \[[err]\]\n")
			return
		else
			to_chat(usr, "You have been [refund ? "refunded" : "charged"] [cost] karma.")
			message_admins("[key_name(usr)] has been [refund ? "refunded" : "charged"] [cost] karma.")
			return

/client/proc/karmatrah(var/cost,var/refund = 0, var/client/C)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[C.ckey]'")
	query.Execute()

	while(query.NextRow())
		var/spent = text2num(query.item[4])
		if(refund)
			spent -= cost
		else
			spent += cost
		query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karmaspent=[spent] WHERE byondkey='[C.ckey]'")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karmaspent updating (updating existing entry). Error: \[[err]\]\n")
			message_admins("SQL ERROR during karmaspent updating (updating existing entry). Error: \[[err]\]\n")
			return
		else
			message_admins("[usr.ckey] reduced [C.ckey]'s karma.")
			return
/*
/client/proc/karmarefund(var/type,var/name,var/cost)
	if(name == "Tajaran Ambassador")
		cost = 30
	else if(name == "Unathi Ambassador")
		cost = 30
	else if(name == "Skrell Ambassador")
		cost = 30
	else if(name == "Diona Ambassador")
		cost = 30
	else if(name == "Kidan Ambassador")
		cost = 30
	else if(name == "Slime People Ambassador")
		cost = 30
	else if(name == "Grey Ambassador")
		cost = 30
	else if(name == "Vox Ambassador")
		cost = 30
	else if(name == "Customs Officer")
		cost = 30
	else if(name == "Nanotrasen Recruiter")
		cost = 10
	else
		to_chat(usr, "<span class='warning'>That job is not refundable.</span>")
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.ckey]'")
	query.Execute()

	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbjob = query.item[3]
		dbspecies = query.item[4]

	if(dbckey)
		var/list/typelist = list()
		if(type == "job")
			typelist = splittext(dbjob,",")
		else if(type == "species")
			typelist = splittext(dbspecies,",")
		else
			to_chat(usr, "<span class='warning'>Type [type] is not a valid column.</span>")

		if(name in typelist)
			typelist -= name
			var/newtypelist = jointext(typelist,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET [type]='[newtypelist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				return
			else
				to_chat(usr, "You have been refunded [cost] karma for [type] [name].")
				message_admins("[key_name(usr)] has been refunded [cost] karma for [type] [name].")
				karmacharge(text2num(cost),1)
		else
			to_chat(usr, "<span class='warning'>You have not bought [name].</span>")

	else
<<<<<<< HEAD
		to_chat(usr, "\red Your ckey ([dbckey]) was not found.")
*/
/client/proc/checkpurchased(var/name = null) // If the first parameter is null, return a full list of purchases
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.ckey]'")
	query.Execute()

	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbjob = query.item[3]
		dbspecies = query.item[4]

	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		var/list/specieslist = splittext(dbspecies,",")
		var/list/combinedlist = joblist + specieslist
		if(name)
			if(name in combinedlist)
				return 1
			else
				return 0
		else
			return combinedlist
	else
		return 0
