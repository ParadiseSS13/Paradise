

proc/sql_report_karma(var/mob/spender, var/mob/receiver)
	var/sqlspendername = spender.name
	var/sqlspenderkey = spender.key
	var/sqlreceivername = receiver.name
	var/sqlreceiverkey = receiver.key
	var/sqlreceiverrole = "None"
	var/sqlreceiverspecial = "None"


	var/sqlspenderip = spender.client.address

	if(receiver.mind)
		if(receiver.mind.special_role)
			sqlreceiverspecial = receiver.mind.special_role
		if(receiver.mind.assigned_role)
			sqlreceiverrole = receiver.mind.assigned_role

	if(!dbcon.IsConnected())
		log_game("SQL ERROR during karma logging. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO karma (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time) VALUES ('[sqlspendername]', '[sqlspenderkey]', '[sqlreceivername]', '[sqlreceiverkey]', '[sqlreceiverrole]', '[sqlreceiverspecial]', '[sqlspenderip]', '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karma logging. Error : \[[err]\]\n")


		query = dbcon.NewQuery("SELECT * FROM karmatotals WHERE byondkey='[receiver.key]'")
		query.Execute()

		var/karma
		var/id
		while(query.NextRow())
			id = query.item[1]
			karma = text2num(query.item[3])
		if(karma == null)
			karma = 1
			query = dbcon.NewQuery("INSERT INTO karmatotals (byondkey, karma) VALUES ('[receiver.key]', [karma])")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (adding new key). Error : \[[err]\]\n")
		else
			karma += 1
			query = dbcon.NewQuery("UPDATE karmatotals SET karma=[karma] WHERE id=[id]")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (updating existing entry). Error : \[[err]\]\n")


var/list/karma_spenders = list()

/mob/verb/spend_karma(var/mob/M in player_list) // Karma system -- TLE
	set name = "Award Karma"
	set desc = "Let the gods know whether someone's been nice. <One use only>"
	set category = "Special Verbs"
	if(!istype(M, /mob))
		usr << "\red That's not a mob. You shouldn't have even been able to specify that. Please inform TLE post haste."
		return

	if(!M.client)
		usr << "\red That mob has no client connected at the moment."
		return
	if(src.client.karma_spent)
		usr << "\red You've already spent your karma for the round."
		return
	for(var/a in karma_spenders)
		if(a == src.key)
			usr << "\red You've already spent your karma for the round."
			return
	if(M.key == src.key)
		usr << "\red You can't spend karma on yourself!"
		return
	if(M.client.address == src.client.address)
		message_admins("\red Illegal karma spending detected from [src.key] to [M.key]. Using the same IP!")
		log_game("\red Illegal karma spending detected from [src.key] to [M.key]. Using the same IP!")
		usr << "\red The karma system is not available to multi-accounters."
	var/choice = input("Give [M.name] good karma?", "Karma") in list("Good", "Cancel")
	if(!choice || choice == "Cancel")
		return
	if(choice == "Good")
		M.client.karma += 1
		usr << "[choice] karma spent on [M.name]."
		src.client.karma_spent = 1
		karma_spenders.Add(src.key)
	if(M.client.karma <= -2 || M.client.karma >= 2)
		var/special_role = "None"
		var/assigned_role = "None"
		var/karma_diary = file("data/logs/karma_[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
		if(M.mind)
			if(M.mind.special_role)
				special_role = M.mind.special_role
			if(M.mind.assigned_role)
				assigned_role = M.mind.assigned_role
		karma_diary << "[M.name] ([M.key]) [assigned_role]/[special_role]: [M.client.karma] - [time2text(world.timeofday, "hh:mm:ss")] given by [src.key]"

	sql_report_karma(src, M)




/client/verb/check_karma()
	set name = "Check Karma"
	set category = "Special Verbs"
	set desc = "Reports how much karma you have accrued"

	var/currentkarma=verify_karma()
	usr << {"<br>You have <b>[currentkarma]</b> available."}
	return

/client/proc/verify_karma()
	var/currentkarma=0
	if(!dbcon.IsConnected())
		usr << "\red Unable to connect to karma database. Please try again later.<br>"
		return
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT karma, karmaspent FROM karmatotals WHERE byondkey='[src.key]'")
		query.Execute()

		var/totalkarma
		var/karmaspent
		while(query.NextRow())
			totalkarma = query.item[1]
			karmaspent = query.item[2]
		currentkarma = (text2num(totalkarma) - text2num(karmaspent))
/*		if(totalkarma)
			usr << {"<br>You have <b>[currentkarma]</b> available.<br>
You've gained <b>[totalkarma]</b> total karma in your time here.<br>"}
		else
			usr << "<b>Your total karma is:</b> 0<br>"*/
	return currentkarma


/client/verb/karmashop()
	set name = "karmashop"
	set desc = "Spend your hard-earned karma here"
	set hidden = 1

	karmashopmenu()
	return


/client/proc/karmashopmenu()

	var/dat = "<html><body><center>"
	dat += "<a href='?src=\ref[src];karmashop=tab;tab=0' [karma_tab == 0 ? "class='linkOn'" : ""]>Job Unlocks</a>"
	dat += "<a href='?src=\ref[src];karmashop=tab;tab=1' [karma_tab == 1 ? "class='linkOn'" : ""]>Species Unlocks</a>"
	dat += "<a href='?src=\ref[src];karmashop=tab;tab=2' [karma_tab == 2 ? "class='linkOn'" : ""]>Ambassador Unlocks</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(karma_tab)
		if (0) // Job Unlocks
			dat += {"
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=1'>Unlock Barber -- 5KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=2'>Unlock Brig Physician -- 5KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=8'>Unlock Nanotrasen Recruiter -- 10KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=3'>Unlock Nanotrasen Representative -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=4'>Unlock Customs Officer -- 30P</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=5'>Unlock Blueshield -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=9'>Unlock Security Pod Pilot -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=6'>Unlock Mechanic -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=7'>Unlock Magistrate -- 45KP</a><br>
			"}

		if (1) // Species Unlocks
			dat += {"
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=1'>Unlock Machine People -- 15KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=2'>Unlock Kidan -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=3'>Unlock Grey -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=4'>Unlock Vox -- 45KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=5'>Unlock Slime People -- 45KP</a><br>
			"}

		if (2) // Ambassador Unlocks
			dat += {"
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=1'>Unlock Tajaran Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=2'>Unlock Unathi Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=3'>Unlock Skrell Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=4'>Unlock Diona Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=5'>Unlock Kidan Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=6'>Unlock Slime People Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=7'>Unlock Grey Ambassador -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy3=8'>Unlock Vox Ambassador -- 30KP</a><br>
			<B> You need to have unlocked the relevant species before being able to purchase this job. </B><br><br>
			<span class='danger'>Ambassadors can be bought but are not yet spawnable in-game. Soon!</span><br><br>
			"}

	dat += "<B>PLEASE NOTE THAT PEOPLE WHO TRY TO GAME THE KARMA SYSTEM WILL END UP ON THE WALL OF SHAME. THIS INCLUDES BUT IS NOT LIMITED TO TRADES, OOC KARMA BEGGING, CODE EXPLOITS, ETC.</B>"
	dat += "</center></body></html>"

	var/datum/browser/popup = new(usr, "karmashop", "<div align='center'>Karma Shop</div>", 400, 400)
	popup.set_content(dat)
	popup.open(0)
	return



/client/proc/DB_job_unlock(var/job,var/cost)

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM whitelist WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbjob
	var/dbckey
	while(query.NextRow())

		dbckey = query.item[2]
		dbjob = query.item[3]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO whitelist (ckey, job) VALUES ('[usr.key]','[job]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			return
		else
			usr << "You have unlocked [job]."
			message_admins("[key_name(usr)] has unlocked [job].")
			karmacharge(cost)

	if(dbckey)
		var/list/joblist = text2list(dbjob,",")
		if(!(job in joblist))
			joblist += job
			var/newjoblist = list2text(joblist,",")
			query = dbcon.NewQuery("UPDATE whitelist SET job='[newjoblist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				return
			else
				usr << "You have unlocked [job]."
				message_admins("[key_name(usr)] has unlocked [job].")
				karmacharge(cost)
		else
			usr << "You already have this job unlocked!"
			return





/client/proc/DB_species_unlock(var/species,var/cost)

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM whitelist WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbspecies
	var/dbckey
	while(query.NextRow())

		dbckey = query.item[2]
		dbspecies = query.item[4]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO whitelist (ckey, species) VALUES ('[usr.key]','[species]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			return
		else
			usr << "You have unlocked [species]."
			message_admins("[key_name(usr)] has unlocked [species].")
			karmacharge(cost)

	if(dbckey)
		var/list/specieslist = text2list(dbspecies,",")
		if(!(species in specieslist))
			specieslist += species
			var/newspecieslist = list2text(specieslist,",")
			query = dbcon.NewQuery("UPDATE whitelist SET species='[newspecieslist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				return
			else
				usr << "You have unlocked [species]."
				message_admins("[key_name(usr)] has unlocked [species].")
				karmacharge(cost)
		else
			usr << "You already have this species unlocked!"
			return

/client/proc/karmacharge(var/cost)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM karmatotals WHERE byondkey='[usr.key]'")
	query.Execute()

	while(query.NextRow())
		var/spent = text2num(query.item[4])
		spent += cost
		query = dbcon.NewQuery("UPDATE karmatotals SET karmaspent=[spent] WHERE byondkey='[usr.key]'")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karmaspent updating (updating existing entry). Error : \[[err]\]\n")
			message_admins("SQL ERROR during karmaspent updating (updating existing entry). Error : \[[err]\]\n")
			return
		else
			usr << "You have been charged [cost]."
			message_admins("[key_name(usr)] has been charged [cost].")
			return
