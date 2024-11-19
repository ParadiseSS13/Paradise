GLOBAL_LIST_EMPTY(admin_ranks)								//list of all ranks with associated rights
GLOBAL_PROTECT(admin_ranks) // this shit is being protected for obvious reasons

//load our rank - > rights associations
/proc/load_admin_ranks()
	GLOB.admin_ranks.Cut()

	var/previous_rights = 0

	// Process each rank set seperately
	// key: rank name | value: list of rights
	for(var/rankname in GLOB.configuration.admin.rank_rights_map)
		var/list/rank_right_tokens = GLOB.configuration.admin.rank_rights_map[rankname]

		var/rights = 0
		for(var/right_token in rank_right_tokens)
			var/token = lowertext(splittext(right_token, "+")[2])
			switch(token)
				if("@","prev")					rights |= previous_rights
				if("buildmode","build")			rights |= R_BUILDMODE
				if("admin")						rights |= R_ADMIN
				if("ban")						rights |= R_BAN
				if("event")						rights |= R_EVENT
				if("server")					rights |= R_SERVER
				if("debug")						rights |= R_DEBUG
				if("permissions","rights")		rights |= R_PERMISSIONS
				if("possess")					rights |= R_POSSESS
				if("stealth")					rights |= R_STEALTH
				if("rejuv","rejuvinate")		rights |= R_REJUVINATE
				if("varedit")					rights |= R_VAREDIT
				if("everything","host","all")	rights |= R_HOST
				if("sound","sounds")			rights |= R_SOUNDS
				if("spawn","create")			rights |= R_SPAWN
				if("mod")						rights |= R_MOD
				if("mentor")					rights |= R_MENTOR
				if("developer")					rights |= R_DEV_TEAM
				if("proccall")					rights |= R_PROCCALL
				if("viewruntimes")				rights |= R_VIEWRUNTIMES
				if("maintainer")				rights |= R_MAINTAINER

		GLOB.admin_ranks[rankname] = rights
		previous_rights = rights

	#ifdef TESTING
	var/msg = "Permission Sets Built:\n"
	for(var/rank in GLOB.admin_ranks)
		msg += "\t[rank] - [GLOB.admin_ranks[rank]]\n"
	testing(msg)
	#endif

/proc/load_admins(run_async = FALSE)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounce'>Admin reload blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to reload admins via advanced proc-call")
		log_admin("[key_name(usr)] attempted to reload admins via advanced proc-call")
		return
	//clear the datums references
	GLOB.admin_datums.Cut()
	for(var/client/C in GLOB.admins)
		C.hide_verbs()
		C.holder = null
	GLOB.admins.Cut()

	// Remove all profiler access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)

	if(!GLOB.configuration.admin.use_database_admins)
		load_admin_ranks()

		//process each line seperately
		for(var/iterator_key in GLOB.configuration.admin.ckey_rank_map)
			var/ckey = ckey(iterator_key) // Snip out formatting
			var/rank = GLOB.configuration.admin.ckey_rank_map[iterator_key]

			//load permissions associated with this rank
			var/rights = GLOB.admin_ranks[rank]

			//create the admin datum and store it for later use
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			if(D.rights & R_DEBUG || D.rights & R_VIEWRUNTIMES) // Grants profiler access to anyone with R_DEBUG or R_VIEWRUNTIMES
				world.SetConfig("APP/admin", ckey, "role=admin")

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(GLOB.directory[ckey])

	else
		//The current admin system uses SQL
		if(!SSdbcore.IsConnected())
			log_world("Failed to connect to database in load_admins(). Reverting to legacy system.")
			GLOB.configuration.admin.use_database_admins = FALSE
			load_admins()
			return

		var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, admin_rank, level, flags FROM admin")
		if(!query.warn_execute(async=run_async))
			qdel(query)
			return

		while(query.NextRow())
			var/ckey = query.item[1]
			var/rank = query.item[2]
			if(rank == "Removed")	continue	//This person was de-adminned. They are only in the admin list for archive purposes.

			var/rights = query.item[4]
			if(istext(rights))	rights = text2num(rights)
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			if(D.rights & R_DEBUG || D.rights & R_VIEWRUNTIMES) // Grants profiler access to anyone with R_DEBUG or R_VIEWRUNTIMES
				world.SetConfig("APP/admin", ckey, "role=admin")

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(GLOB.directory[ckey])

		qdel(query)

		if(!GLOB.admin_datums)
			log_world("The database query in load_admins() resulted in no admins being added to the list. Reverting to legacy system.")
			GLOB.configuration.admin.use_database_admins = FALSE
			load_admins()
			return

	#ifdef TESTING
	var/msg = "Admins Built:\n"
	for(var/ckey in GLOB.admin_datums)
		var/rank
		var/datum/admins/D = GLOB.admin_datums[ckey]
		if(D)	rank = D.rank
		msg += "\t[ckey] - [rank]\n"
	testing(msg)
	#endif


#ifdef TESTING
/client/verb/changerank(newrank in GLOB.admin_ranks)
	if(holder)
		holder.rank = newrank
		holder.rights = GLOB.admin_ranks[newrank]
	else
		holder = new /datum/admins(newrank,GLOB.admin_ranks[newrank],ckey)
	hide_verbs()
	holder.associate(src)

/client/verb/changerights(newrights as num)
	if(holder)
		holder.rights = newrights
	else
		holder = new /datum/admins("testing",newrights,ckey)
	hide_verbs()
	holder.associate(src)

#endif
