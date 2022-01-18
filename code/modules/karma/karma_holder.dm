// This file contains stuff regarding the karma holder datum
// This is attached to a client and holds their info
/datum/karma_holder
	/// List of jobs this person has unlocked
	var/list/unlocked_jobs = list()
	/// List of species this person has unlocked
	var/list/unlocked_species = list()
	/// Amount of karma earned total
	var/karma_earned = 0
	/// Amount of karma spent total
	var/karma_spent = 0
	/// What tab are they on
	var/karma_tab = 0


// Safety stuff
/datum/karma_holder/vv_edit_var(var_name, var_value)
	return FALSE // no

/datum/karma_holder/CanProcCall(procname)
	return FALSE // no

// Opens the karma shop menu
/datum/karma_holder/proc/open_shop_menu()
	var/dat = "<html><body><center>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=0' [karma_tab == 0 ? "class='linkOn'" : ""]>Job Unlocks</a>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=1' [karma_tab == 1 ? "class='linkOn'" : ""]>Species Unlocks</a>"
	dat += "<a href='?src=[UID()];karmashop=tab;tab=2' [karma_tab == 2 ? "class='linkOn'" : ""]>Karma Refunds</a>"
	dat += "</center>"
	dat += "<HR>"

	var/currentkarma = (karma_earned - karma_spent)
	dat += "You have <b>[currentkarma]</b> available.<br><HR>"

	switch(karma_tab)
		if(0) // Job Unlocks
			if(!("Barber" in unlocked_jobs))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=1'>Unlock Barber -- 5KP</a><br>"
			else
				dat += "Barber  - <font color='green'>Unlocked</font><br>"
			if(!("Nanotrasen Representative" in unlocked_jobs))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=3'>Unlock Nanotrasen Representative -- 30KP</a><br>"
			else
				dat += "Nanotrasen Representative - <font color='green'>Unlocked</font><br>"
			if(!("Blueshield" in unlocked_jobs))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy=4'>Unlock Blueshield -- 30KP</a><br>"
			else
				dat += "Blueshield - <font color='green'>Unlocked</font><br>"

		if(1) // Species Unlocks
			if(!("Machine" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=1'>Unlock Machine People -- 15KP</a><br>"
			else
				dat += "Machine People - <font color='green'>Unlocked</font><br>"
			if(!("Kidan" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=2'>Unlock Kidan -- 30KP</a><br>"
			else
				dat += "Kidan - <font color='green'>Unlocked</font><br>"
			if(!("Grey" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=3'>Unlock Grey -- 30KP</a><br>"
			else
				dat += "Grey - <font color='green'>Unlocked</font><br>"
			if(!("Drask" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=7'>Unlock Drask -- 30KP</a><br>"
			else
				dat += "Drask - <font color='green'>Unlocked</font><br>"
			if(!("Vox" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=4'>Unlock Vox -- 45KP</a><br>"
			else
				dat += "Vox - <font color='green'>Unlocked</font><br>"
			if(!("Slime People" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=5'>Unlock Slime People -- 45KP</a><br>"
			else
				dat += "Slime People - <font color='green'>Unlocked</font><br>"
			if(!("Plasmaman" in unlocked_species))
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaBuy2=6'>Unlock Plasmaman -- 45KP</a><br>"
			else
				dat += "Plasmaman - <font color='green'>Unlocked</font><br>"

		if(2) // Karma Refunds
			var/list/refundable = list()
			// Get both
			var/list/purchased = unlocked_jobs + unlocked_species
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
			if("Mechanic" in purchased)
				refundable += "Mechanic"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Mechanic;KarmaRefundType=job;KarmaRefundCost=30'>Refund Mechanic -- 30KP</a><br>"
			if("Security Pod Pilot" in purchased)
				refundable += "Security Pod Pilot"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Security Pod Pilot;KarmaRefundType=job;KarmaRefundCost=30'>Refund Security Pod Pilot -- 30KP</a><br>"
			if("Magistrate" in purchased)
				refundable += "Magistrate"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Magistrate;KarmaRefundType=job;KarmaRefundCost=45'>Refund Magistrate -- 45KP</a><br>"
			if("Brig Physician" in purchased)
				refundable += "Brig Physician"
				dat += "<a href='?src=[UID()];karmashop=shop;KarmaRefund=Brig Physician;KarmaRefundType=job;KarmaRefundCost=45'>Refund Brig Physician -- 5KP</a><br>"

			if(!length(refundable))
				dat += "You do not have any refundable karma purchases.<br>"

	dat += "<br><b>Please note that people who attempt to game the karma system will be banned from the system and have all their unlocks revoked. \"Gaming\" the system includes, but is not limited to:<ul><li>- Karma trading</li><li>- OOC Karma begging</li><li>- Code exploits</li></ul></b>"
	dat += "</center></body></html>"

	var/datum/browser/popup = new(usr, "karmashop", "<div align='center'>Karma Shop</div>", 400, 500)
	popup.set_content(dat)
	popup.open(FALSE)

// Reloads the values from the DB to ensure they havnt been gamed
/datum/karma_holder/proc/sync_karma(mob/M = usr)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT karma, karmaspent FROM karmatotals WHERE byondkey=:ckey", list(
		"ckey" = M.ckey
	))

	if(!select_query.warn_execute())
		qdel(select_query)
		return

	while(select_query.NextRow())
		karma_earned = select_query.item[1]
		karma_spent = select_query.item[2]

	qdel(select_query)


//Checks if can afford, what you're purchasing, then purchases. (used in client_procs.dm)
/datum/karma_holder/proc/karma_purchase(price = 0, category, name, DBname = null)
	sync_karma() // Ensure its up to date
	var/karma_available = karma_earned - karma_spent
	if(karma_available < price)
		to_chat(usr, "You do not have enough karma!")
		return
	if(alert("Are you sure you want to unlock [name]?", "Confirmation", "No", "Yes") != "Yes")
		return
	if(karma_available < price) // This is repeated for a reason. Someone could queue up 10 windows to buy things.
		to_chat(usr, "You do not have enough karma!")
		return
	if(!isnull(DBname)) //In case database uses another name for logging. (Machine, Machine People)
		name = DBname
	switch(category)
		if("job")
			DB_job_unlock(name, price)
		if("species")
			DB_species_unlock(name, price)
		else
			message_admins("Invalid category used in karma shop by [key_name_admin(usr)] | Possible href exploit.")

	open_shop_menu()


/datum/karma_holder/proc/DB_job_unlock(job, cost)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT ckey, job FROM whitelist WHERE ckey=:ckey", list(
		"ckey" = usr.ckey
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

	// They exist already
	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		if(!(job in joblist))
			joblist += job
			var/newjoblist = jointext(joblist,",")
			var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE whitelist SET job=:newjoblist WHERE ckey=:ckey", list(
				"newjoblist" = newjoblist,
				"ckey" = usr.ckey
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return

			to_chat(usr, "You have unlocked [job].")
			log_karma("[key_name(usr)] has unlocked [job].")
			qdel(update_query)
			karmacharge(cost)
			usr.client.karmaholder.unlocked_jobs += job
		else
			to_chat(usr, "You already have this job unlocked!")

	// They dont exist. Insert them
	else
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO whitelist (ckey, job) VALUES (:ckey, :job)", list(
			"ckey" = usr.ckey,
			"job" = job
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return

		to_chat(usr, "You have unlocked [job].")
		log_karma("[key_name(usr)] has unlocked [job].")
		karmacharge(cost)

		qdel(insert_query)

/datum/karma_holder/proc/DB_species_unlock(species, cost)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT ckey, species FROM whitelist WHERE ckey=:ckey", list(
		"ckey" = usr.ckey
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

	// They exist
	if(dbckey)
		var/list/specieslist = splittext(dbspecies,",")
		if(!(species in specieslist))
			specieslist += species
			var/newspecieslist = jointext(specieslist,",")
			var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE whitelist SET species=:newspecieslist WHERE ckey=:ckey", list(
				"newspecieslist" = newspecieslist,
				"ckey" = usr.ckey
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return

			to_chat(usr, "You have unlocked [species].")
			log_karma("[key_name(usr)] has unlocked [species].")
			qdel(update_query)
			karmacharge(cost)
			usr.client.karmaholder.unlocked_species += species
		else
			to_chat(usr, "You already have this species unlocked!")

	// They dont. New row.
	else
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO whitelist (ckey, species) VALUES (:ckey, :species)", list(
			"ckey" = usr.ckey,
			"species" = species
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return

		to_chat(usr, "You have unlocked [species].")
		log_karma("[key_name(usr)] has unlocked [species].")
		qdel(insert_query)
		karmacharge(cost)


/datum/karma_holder/proc/karmacharge(cost, refund = FALSE)
	sync_karma() // Ensure its up to date
	if(refund)
		karma_spent -= cost
	else
		karma_spent += cost
	var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE karmatotals SET karmaspent=:spent WHERE byondkey=:ckey", list(
		"spent" = karma_spent,
		"ckey" = usr.ckey
	))
	if(!update_query.warn_execute())
		qdel(update_query)
		return

	to_chat(usr, "You have been [refund ? "refunded" : "charged"] [cost] karma.")
	log_karma("[key_name(usr)] has been [refund ? "refunded" : "charged"] [cost] karma.")
	qdel(update_query)

/datum/karma_holder/proc/karmarefund(type, name, cost)
	switch(name)
		if("Tajaran Ambassador","Unathi Ambassador","Skrell Ambassador","Diona Ambassador","Kidan Ambassador",
		"Slime People Ambassador","Grey Ambassador","Vox Ambassador","Customs Officer", "Mechanic", "Security Pod Pilot")
			cost = 30
		if("Nanotrasen Recruiter")
			cost = 10
		if("Magistrate")
			cost = 45
		if("Brig Physician")
			cost = 5
		else
			to_chat(usr, "<span class='warning'>That job is not refundable.</span>")
			return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, job, species FROM whitelist WHERE ckey=:ckey", list(
		"ckey" = usr.ckey
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
				statement = "UPDATE whitelist SET job=:newtypelist WHERE ckey=:ckey"
			if("species")
				typelist = splittext(dbspecies,",")
				statement = "UPDATE whitelist SET species=:newtypelist WHERE ckey=:ckey"
			else
				to_chat(usr, "<span class='warning'>Type [type] is not a valid column.</span>")

		if(name in typelist)
			typelist -= name
			var/newtypelist = jointext(typelist,",")
			var/datum/db_query/update_query = SSdbcore.NewQuery(statement, list(
				"ckey" = usr.ckey,
				"newtypelist" = newtypelist
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return
			else
				to_chat(usr, "You have been refunded [cost] karma for [type] [name].")
				log_karma("[key_name(usr)] has been refunded [cost] karma for [type] [name].")
				switch(type)
					if("job")
						usr.client.karmaholder.unlocked_jobs -= name
					if("species")
						usr.client.karmaholder.unlocked_species -= name
				qdel(update_query)
				karmacharge(text2num(cost), TRUE)
		else
			to_chat(usr, "<span class='warning'>You have not bought [name].</span>")

	else
		to_chat(usr, "<span class='warning'>Your ckey ([dbckey]) was not found.</span>")

/datum/karma_holder/Topic(href, href_list)
	..()
	if(href_list["karmashop"])
		if(!GLOB.configuration.general.enable_karma)
			to_chat(src, "Karma is disabled on this server.")
			return

		switch(href_list["karmashop"])
			if("tab")
				karma_tab = text2num(href_list["tab"])
				open_shop_menu()
				return
			if("shop")
				if(href_list["KarmaBuy"])
					switch(href_list["KarmaBuy"])
						if("1")
							karma_purchase(5, "job", "Barber")
						if("3")
							karma_purchase(30, "job", "Nanotrasen Representative")
						if("4")
							karma_purchase(30, "job", "Blueshield")
					return
				if(href_list["KarmaBuy2"])
					switch(href_list["KarmaBuy2"])
						if("1")
							karma_purchase(15, "species", "Machine People", "Machine")
						if("2")
							karma_purchase(30, "species", "Kidan")
						if("3")
							karma_purchase(30, "species", "Grey")
						if("4")
							karma_purchase(45, "species", "Vox")
						if("5")
							karma_purchase(45, "species", "Slime People")
						if("6")
							karma_purchase(45, "species", "Plasmaman")
						if("7")
							karma_purchase(30, "species", "Drask")
					return
				if(href_list["KarmaRefund"])
					var/type = href_list["KarmaRefundType"]
					var/job = href_list["KarmaRefund"]
					var/cost = href_list["KarmaRefundCost"]
					karmarefund(type, job, cost)
					open_shop_menu()
					return
