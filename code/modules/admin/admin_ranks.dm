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

/proc/reload_one_admin(admin_ckey, silent = FALSE)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounce'>Admin reload blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to reload an admin via advanced proc-call")
		log_admin("[key_name(usr)] attempted to reload an admin via advanced proc-call")
		return

	// Make sure it's actually in ckey format.
	admin_ckey = ckey(admin_ckey)

	// Remove any existing permissions.
	var/datum/admins/admin_datum = GLOB.admin_datums[admin_ckey]
	if(admin_datum)
		qdel(admin_datum)

	if(admin_ckey in (GLOB.de_admins + GLOB.de_mentors))
		if(!silent)
			message_admins("<span class='notice'>Admin permissions for [admin_ckey] will reload when they re-admin.</span>")
		return

	if(admin_ckey in GLOB.directory)
		var/client/admin = GLOB.directory[admin_ckey]
		var/localhosted = admin.try_localhost_autoadmin()
		if(localhosted)
			if(!silent)
				message_admins("<span class='notice'>Admin permissions for [admin_ckey] reloaded. Full permissions granted as they are currently connected from localhost.</span>")
			return

	if(GLOB.configuration.admin.use_database_admins)
		var/datum/db_query/get_admin = SSdbcore.NewQuery({"
			SELECT
				-- Use the display_rank if set, otherwise the name of their permissions_rank.
				IFNULL(admin.display_rank, admin_ranks.name),
				-- Permissions start with their admin rank permissions (if any)
				(IFNULL(admin_ranks.default_permissions, 0)
				-- Then add in any extra permissions they've been granted.
				| admin.extra_permissions)
				-- And exclude any permissions they've had removed.
				& ~admin.removed_permissions
			FROM admin
			-- We want all admins, and admin_ranks where available.
			LEFT OUTER JOIN admin_ranks
			ON admin.permissions_rank = admin_ranks.id
			WHERE admin.ckey=:admin_ckey"}, list(
				"admin_ckey" = admin_ckey
			))
		if(!get_admin.warn_execute())
			qdel(get_admin)
			return

		if(get_admin.NextRow())
			var/rank = get_admin.item[1]
			var/rights = get_admin.item[2]
			if(rights == 0)
				// If you have no rights, you don't get an admin datum.
				qdel(get_admin)
				if(!silent)
					message_admins("<span class='notice'>Admin permissions for [admin_ckey] have been reloaded.</span>")
				return
			admin_datum = new(rank, rights, admin_ckey)
			qdel(get_admin)
	else
		var/rank = GLOB.configuration.admin.ckey_rank_map[admin_ckey]

		// Load permissions associated with this rank
		var/rights = GLOB.admin_ranks[rank]

		// Create their admin datum.
		admin_datum = new /datum/admins(rank, rights, admin_ckey)

	// Set up their permissions.
	if(admin_datum)
		admin_datum.associate(GLOB.directory[admin_ckey])

	if(!silent)
		message_admins("<span class='notice'>Admin permissions for [admin_ckey] have been reloaded.</span>")

/proc/load_admins(run_async = FALSE)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounce'>Admin reload blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to reload admins via advanced proc-call")
		log_admin("[key_name(usr)] attempted to reload admins via advanced proc-call")
		return

	// Revoke all permissions.
	var/list/localhost_admins = list()
	for(var/datum/admins/admin_datum in GLOB.admin_datums)
		if(admin_datum.is_localhost_autoadmin && admin_datum.owner)
			localhost_admins += admin_datum.owner
		qdel(admin_datum)
	GLOB.admin_datums.Cut()
	GLOB.admins.Cut()

	// Just to be double-sure, revoke all profiler access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)

	if(!GLOB.configuration.admin.use_database_admins)
		load_admin_ranks()

		for(var/ckey in GLOB.configuration.admin.ckey_rank_map)
			var/rank = GLOB.configuration.admin.ckey_rank_map[ckey]

			// Load permissions associated with this rank
			var/rights = GLOB.admin_ranks[rank]

			// Create their admin datum.
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			// Set up their admin permissions.
			D.associate(GLOB.directory[ckey])

	else
		//The current admin system uses SQL
		if(!SSdbcore.IsConnected())
			log_world("Failed to connect to database in load_admins(). Reverting to legacy system.")
			GLOB.configuration.admin.use_database_admins = FALSE
			load_admins()
			return

		var/datum/db_query/get_admins = SSdbcore.NewQuery({"
			SELECT
				admin.ckey,
				-- Use the display_rank if set, otherwise the name of their permissions_rank.
				IFNULL(admin.display_rank, admin_ranks.name),
				-- Permissions start with their admin rank permissions (if any)
				(IFNULL(admin_ranks.default_permissions, 0)
				-- Then add in any extra permissions they've been granted.
				| admin.extra_permissions)
				-- And exclude any permissions they've had removed.
				& ~admin.removed_permissions
			FROM admin
			-- We want all admins, and admin_ranks where available.
			LEFT OUTER JOIN admin_ranks
			ON admin.permissions_rank = admin_ranks.id"})
		if(!get_admins.warn_execute(async=run_async))
			qdel(get_admins)
			return

		while(get_admins.NextRow())
			var/ckey = get_admins.item[1]
			var/rank = get_admins.item[2]
			var/rights = get_admins.item[3]
			if(rights == 0)
				// If you have no rights, you don't get an admin datum.
				continue
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			// Set up their admin permissions.
			D.associate(GLOB.directory[ckey])
		qdel(get_admins)

		if(!length(GLOB.admin_datums))
			log_world("The database query in load_admins() resulted in no admins being added to the list. Reverting to legacy system.")
			GLOB.configuration.admin.use_database_admins = FALSE
			load_admins()
			return

	for(var/client/localhost_admin in localhost_admins)
		localhost_admin.try_localhost_autoadmin()

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
