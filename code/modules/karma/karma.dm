/*	KARMA
	Everything karma related is here.
	Part of karma purchase is handled in client_procs.dm	*/

/proc/sql_report_karma(var/mob/spender, var/mob/receiver)
	var/receiverrole = "None"
	var/receiverspecial = "None"

	if(receiver.mind)
		if(receiver.mind.special_role)
			receiverspecial = receiver.mind.special_role
		if(receiver.mind.assigned_role)
			receiverrole = receiver.mind.assigned_role

	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/log_query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("karma")] (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time)
		VALUES (:sname, :skey, :rname, :rkey, :rrole, :rspecial, :sip, Now())"}, list(
			"sname" = spender.name,
			"skey" = spender.ckey,
			"rname" = receiver.name,
			"rkey" = receiver.ckey,
			"rrole" = receiverrole,
			"rspecial" = receiverspecial,
			"sip" = spender.client.address
		))

	if(!log_query.warn_execute())
		qdel(log_query)
		return

	qdel(log_query)

	var/datum/db_query/select_spender = SSdbcore.NewQuery("SELECT id, karma FROM [format_table_name("karmatotals")] WHERE byondkey=:rkey", list(
		"rkey" = receiver.ckey
	))

	if(!select_spender.warn_execute())
		qdel(select_spender)
		return

	var/karma
	var/id
	while(select_spender.NextRow())
		id = select_spender.item[1]
		karma = text2num(select_spender.item[2])

	qdel(select_spender)

	if(karma == null)
		karma = 1

		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("karmatotals")] (byondkey, karma) VALUES (:rkey, :karma)", list(
			"rkey" = receiver.ckey,
			"karma" = karma
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)
	else
		karma++
		var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [format_table_name("karmatotals")] SET karma=:karma WHERE id=:id", list(
			"karma" = karma,
			"id" = id
		))
		if(!update_query.warn_execute())
			qdel(update_query)
			return
		qdel(update_query)

GLOBAL_LIST_EMPTY(karma_spenders)

// Returns TRUE if mob can give karma at all; if not, tells them why
/mob/proc/can_give_karma()
	if(!client)
		to_chat(src, "<span class='warning'>You can't award karma without being connected.</span>")
		return FALSE
	if(config.disable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return FALSE
	if(!SSticker || !GLOB.player_list.len || (SSticker.current_state == GAME_STATE_PREGAME))
		to_chat(src, "<span class='warning'>You can't award karma until the game has started.</span>")
		return FALSE
	if(client.karma_spent || (ckey in GLOB.karma_spenders))
		to_chat(src, "<span class='warning'>You've already spent your karma for the round.</span>")
		return FALSE
	return TRUE

// Returns TRUE if mob can give karma to M; if not, tells them why
/mob/proc/can_give_karma_to_mob(mob/M)
	if(!can_give_karma())
		return FALSE
	if(!istype(M))
		to_chat(src, "<span class='warning'>That's not a mob.</span>")
		return FALSE
	if(!M.client)
		to_chat(src, "<span class='warning'>That mob has no client connected at the moment.</span>")
		return FALSE
	if(M.ckey == ckey)
		to_chat(src, "<span class='warning'>You can't spend karma on yourself!</span>")
		return FALSE
	if(client.address == M.client.address)
		message_admins("<span class='warning'>Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!</span>")
		log_game("Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!")
		to_chat(src, "<span class='warning'>You can't spend karma on someone connected from the same IP.</span>")
		return FALSE
	if(M.get_preference(PREFTOGGLE_DISABLE_KARMA))
		to_chat(src, "<span class='warning'>That player has turned off incoming karma.")
		return FALSE
	return TRUE


/mob/verb/spend_karma_list()
	set name = "Award Karma"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!can_give_karma())
		return

	var/list/karma_list = list()
	for(var/mob/M in GLOB.player_list)
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

	M.client.karma++
	to_chat(usr, "Good karma spent on [M.name].")
	client.karma_spent = TRUE
	GLOB.karma_spenders += ckey

	var/special_role = "None"
	var/assigned_role = "None"
	var/karma_diary = file("[GLOB.log_directory]/karma.log")
	if(M.mind)
		if(M.mind.special_role)
			special_role = M.mind.special_role
		if(M.mind.assigned_role)
			assigned_role = M.mind.assigned_role
	karma_diary << "[M.name] ([M.key]) [assigned_role]/[special_role]: [M.client.karma] - [time2text(world.timeofday, "hh:mm:ss")] given by [key]"

	sql_report_karma(src, M)

/client/verb/check_karma()
	set name = "Check Karma"
	set desc = "Reports how much karma you have accrued."
	set category = "Special Verbs"

	if(config.disable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return

	var/currentkarma = verify_karma()
	if(!isnull(currentkarma))
		to_chat(usr, {"<br>You have <b>[currentkarma]</b> available."})

/client/proc/verify_karma()
	var/currentkarma = 0
	if(!SSdbcore.IsConnected())
		to_chat(usr, "<span class='warning'>Unable to connect to karma database. Please try again later.<br></span>")
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT karma, karmaspent FROM [format_table_name("karmatotals")] WHERE byondkey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/totalkarma
	var/karmaspent
	while(query.NextRow())
		totalkarma = query.item[1]
		karmaspent = query.item[2]
	qdel(query)
	currentkarma = (text2num(totalkarma) - text2num(karmaspent))

	return currentkarma

/client/verb/karmashop()
	set name = "karmashop"
	set desc = "Spend your hard-earned karma here"
	set hidden = TRUE

	if(config.disable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return
	karmashopmenu()

/client/proc/karmashopmenu()
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, job, species FROM [format_table_name("whitelist")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/list/joblist
	var/list/specieslist
	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[1]
		dbjob = query.item[2]
		dbspecies = query.item[3]

	qdel(query)

	if(dbckey)
		joblist = splittext(dbjob,",")
		specieslist = splittext(dbspecies,",")

	var/dat = {"<html><meta charset="UTF-8"><body><center>"}
	dat += "<a href='?src=[UID()];karmashop=tab;tab=0' [karma_tab == 0 ? "class='linkOn'" : ""]>Job Unlocks</a>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=1' [karma_tab == 1 ? "class='linkOn'" : ""]>Species Unlocks</a>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=2' [karma_tab == 2 ? "class='linkOn'" : ""]>Karma Refunds</a>"
	dat += "</center>"
	dat += "<HR>"

	var/currentkarma = verify_karma()
	dat += "You have <b>[currentkarma]</b> available.<br><HR>"

	switch(karma_tab)
		if(0) // Job Unlocks
			if(!("Barber" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=1'>Unlock Barber -- 5KP</a><br>"
			else
				dat += "Barber  - <font color='green'>Unlocked</font><br>"
			if(!("Brig Physician" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=2'>Unlock Brig Physician -- 5KP</a><br>"
			else
				dat += "Brig Physician - <font color='green'>Unlocked</font><br>"
			if(!("Nanotrasen Representative" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=3'>Unlock Nanotrasen Representative -- 30KP</a><br>"
			else
				dat += "Nanotrasen Representative - <font color='green'>Unlocked</font><br>"
			if(!("Blueshield" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=5'>Unlock Blueshield -- 30KP</a><br>"
			else
				dat += "Blueshield - <font color='green'>Unlocked</font><br>"
			if(!("Security Pod Pilot" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=9'>Unlock Security Pod Pilot -- 30KP</a><br>"
			else
				dat += "Security Pod Pilot - <font color='green'>Unlocked</font><br>"
			if(!("Mechanic" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=6'>Unlock Mechanic -- 30KP</a><br>"
			else
				dat += "Mechanic - <font color='green'>Unlocked</font><br>"
			if(!("Magistrate" in joblist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=7'>Unlock Magistrate -- 45KP</a><br>"
			else
				dat+= "Magistrate - <font color='green'>Unlocked</font><br>"

		if(1) // Species Unlocks
			if(!("Machine" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=1'>Unlock Machine People -- 15KP</a><br>"
			else
				dat += "Machine People - <font color='green'>Unlocked</font><br>"
			if(!("Kidan" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=2'>Unlock Kidan -- 30KP</a><br>"
			else
				dat += "Kidan - <font color='green'>Unlocked</font><br>"
			if(!("Grey" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=3'>Unlock Grey -- 30KP</a><br>"
			else
				dat += "Grey - <font color='green'>Unlocked</font><br>"
			if(!("Drask" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=7'>Unlock Drask -- 30KP</a><br>"
			else
				dat += "Drask - <font color='green'>Unlocked</font><br>"
			if(!("Vox" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=4'>Unlock Vox -- 45KP</a><br>"
			else
				dat += "Vox - <font color='green'>Unlocked</font><br>"
			if(!("Slime People" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=5'>Unlock Slime People -- 45KP</a><br>"
			else
				dat += "Slime People - <font color='green'>Unlocked</font><br>"
			if(!("Plasmaman" in specieslist))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=6'>Unlock Plasmaman -- 45KP</a><br>"
			else
				dat += "Plasmaman - <font color='green'>Unlocked</font><br>"

		if(2) // Karma Refunds
			var/list/refundable = list()
			var/list/purchased = checkpurchased()
			if("Tajaran Ambassador" in purchased)
				refundable += "Tajaran Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Tajaran Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Tajaran Ambassador -- 30KP</a><br>"
			if("Unathi Ambassador" in purchased)
				refundable += "Unathi Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Unathi Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Unathi Ambassador -- 30KP</a><br>"
			if("Skrell Ambassador" in purchased)
				refundable += "Skrell Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Skrell Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Skrell Ambassador -- 30KP</a><br>"
			if("Diona Ambassador" in purchased)
				refundable += "Diona Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Diona Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Diona Ambassador -- 30KP</a><br>"
			if("Kidan Ambassador" in purchased)
				refundable += "Kidan Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Kidan Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Kidan Ambassador -- 30KP</a><br>"
			if("Slime People Ambassador" in purchased)
				refundable += "Slime People Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Slime People Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Slime People Ambassador -- 30KP</a><br>"
			if("Grey Ambassador" in purchased)
				refundable += "Grey Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Grey Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Grey Ambassador -- 30KP</a><br>"
			if("Vox Ambassador" in purchased)
				refundable += "Vox Ambassador"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Vox Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Vox Ambassador -- 30KP</a><br>"
			if("Customs Officer" in purchased)
				refundable += "Customs Officer"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Customs Officer;KarmaRefundType=job;KarmaRefundCost=30'>Refund Customs Officer -- 30KP</a><br>"
			if("Nanotrasen Recruiter" in purchased)
				refundable += "Nanotrasen Recruiter"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Nanotrasen Recruiter;KarmaRefundType=job;KarmaRefundCost=10'>Refund Nanotrasen Recruiter -- 10KP</a><br>"

			if(!refundable.len)
				dat += "You do not have any refundable karma purchases.<br>"

	dat += "<br><B>PLEASE NOTE THAT PEOPLE WHO TRY TO GAME THE KARMA SYSTEM WILL END UP ON THE WALL OF SHAME. THIS INCLUDES BUT IS NOT LIMITED TO TRADES, OOC KARMA BEGGING, CODE EXPLOITS, ETC.</B>"
	dat += "</center></body></html>"

	var/datum/browser/popup = new(usr, "karmashop", "<div align='center'>Karma Shop</div>", 400, 400)
	popup.set_content(dat)
	popup.open(0)

//Checks if can afford, what you're purchasing, then purchases. (used in client_procs.dm)
/client/proc/karma_purchase(var/karma = 0, var/price = 1, var/category, var/name, var/DBname = null)
	if(karma < price)
		to_chat(usr, "You do not have enough karma!")
		return
	if(alert("Are you sure you want to unlock [name]?", "Confirmation", "No", "Yes") != "Yes")
		return
	if(karma < price)	//Check one more time. (definitely not repeated code)
		to_chat(usr, "You do not have enough karma!")
		return
	if(!isnull(DBname)) //In case database uses another name for logging. (Machine, Machine People)
		name = DBname
	if(category == "job")
		DB_job_unlock(name,price)
		karmashopmenu()
	else if(category == "species")
		DB_species_unlock(name,price)
		karmashopmenu()

/client/proc/DB_job_unlock(var/job,var/cost)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT ckey, job FROM [format_table_name("whitelist")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/dbjob
	var/dbckey
	while(select_query.NextRow())
		dbckey = select_query.item[1]
		dbjob = select_query.item[2]

	qdel(select_query)
	if(!dbckey)
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, job) VALUES (:ckey, :job)", list(
			"ckey" = ckey,
			"job" = job
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		else
			to_chat(usr, "You have unlocked [job].")
			message_admins("[key_name(usr)] has unlocked [job].") // why do we admin log this
			karmacharge(cost)

		qdel(insert_query)

	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		if(!(job in joblist))
			joblist += job
			var/newjoblist = jointext(joblist,",")
			var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [format_table_name("whitelist")] SET job=:newjoblist WHERE ckey=:ckey", list(
				"newjoblist" = newjoblist,
				"ckey" = ckey
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return
			else
				to_chat(usr, "You have unlocked [job].")
				message_admins("[key_name(usr)] has unlocked [job].")
				karmacharge(cost)
				qdel(update_query)
		else
			to_chat(usr, "You already have this job unlocked!")
			return

/client/proc/DB_species_unlock(var/species,var/cost)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT ckey, species FROM [format_table_name("whitelist")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/dbspecies
	var/dbckey
	while(select_query.NextRow())
		dbckey = select_query.item[1]
		dbspecies = select_query.item[2]
	qdel(select_query)
	if(!dbckey)
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, species) VALUES (:ckey, :species)", list(
			"ckey" = ckey,
			"species" = species
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		else
			to_chat(usr, "You have unlocked [species].")
			message_admins("[key_name(usr)] has unlocked [species].")
			qdel(insert_query)
			karmacharge(cost)

	if(dbckey)
		var/list/specieslist = splittext(dbspecies,",")
		if(!(species in specieslist))
			specieslist += species
			var/newspecieslist = jointext(specieslist,",")
			var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [format_table_name("whitelist")] SET species=:newspecieslist WHERE ckey=:ckey", list(
				"newspecieslist" = newspecieslist,
				"ckey" = ckey
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return
			else
				to_chat(usr, "You have unlocked [species].")
				message_admins("[key_name(usr)] has unlocked [species].")
				qdel(update_query)
				karmacharge(cost)
		else
			to_chat(usr, "You already have this species unlocked!")
			return

/client/proc/karmacharge(var/cost,var/refund = FALSE)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT karmaspent FROM [format_table_name("karmatotals")] WHERE byondkey=:ckey", list(
		"ckey" = ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	while(select_query.NextRow())
		var/spent = text2num(select_query.item[1])
		if(refund)
			spent -= cost
		else
			spent += cost
		var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [format_table_name("karmatotals")] SET karmaspent=:spent WHERE byondkey=:ckey", list(
			"spent" = spent,
			"ckey" = ckey
		))
		if(!update_query.warn_execute())
			qdel(select_query)
			qdel(update_query)
			return
		else
			to_chat(usr, "You have been [refund ? "refunded" : "charged"] [cost] karma.")
			message_admins("[key_name(usr)] has been [refund ? "refunded" : "charged"] [cost] karma.")
			qdel(select_query)
			qdel(update_query)
			return

/client/proc/karmarefund(var/type,var/name,var/cost)
	switch(name)
		if("Tajaran Ambassador","Unathi Ambassador","Skrell Ambassador","Diona Ambassador","Kidan Ambassador",
		"Slime People Ambassador","Grey Ambassador","Vox Ambassador","Customs Officer")
			cost = 30
		if("Nanotrasen Recruiter")
			cost = 10
		else
			to_chat(usr, "<span class='warning'>That job is not refundable.</span>")
			return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, job, species FROM [format_table_name("whitelist")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[1]
		dbjob = query.item[2]
		dbspecies = query.item[3]

	qdel(query)

	if(dbckey)
		var/list/typelist = list()
		var/statement
		switch(type)
			if("job")
				typelist = splittext(dbjob,",")
				statement = "UPDATE [format_table_name("whitelist")] SET job=:newtypelist WHERE ckey=:ckey"
			if("species")
				typelist = splittext(dbspecies,",")
				statement = "UPDATE [format_table_name("whitelist")] SET species=:newtypelist WHERE ckey=:ckey"
			else
				to_chat(usr, "<span class='warning'>Type [type] is not a valid column.</span>")

		if(name in typelist)
			typelist -= name
			var/newtypelist = jointext(typelist,",")
			var/datum/db_query/update_query = SSdbcore.NewQuery(statement, list(
				"ckey" = ckey,
				"newtypelist" = newtypelist
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return
			else
				to_chat(usr, "You have been refunded [cost] karma for [type] [name].")
				message_admins("[key_name(usr)] has been refunded [cost] karma for [type] [name].")
				qdel(update_query)
				karmacharge(text2num(cost),1)
		else
			to_chat(usr, "<span class='warning'>You have not bought [name].</span>")

	else
		to_chat(usr, "<span class='warning'>Your ckey ([dbckey]) was not found.</span>")

/client/proc/checkpurchased(var/name = null) // If the first parameter is null, return a full list of purchases
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, job, species FROM [format_table_name("whitelist")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[1]
		dbjob = query.item[2]
		dbspecies = query.item[3]

	qdel(query)
	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		var/list/specieslist = splittext(dbspecies,",")
		var/list/combinedlist = joblist + specieslist
		if(name)
			if(name in combinedlist)
				return TRUE
			else
				return FALSE
		else
			return combinedlist
	else
		return FALSE
