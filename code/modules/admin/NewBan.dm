GLOBAL_VAR(CMinutes)
GLOBAL_DATUM(banlist_savefile, /savefile)
GLOBAL_PROTECT(banlist_savefile) // Obvious reasons

/proc/CheckBan(var/ckey, var/id, var/address)
	if(!GLOB.banlist_savefile)		// if banlist_savefile cannot be located for some reason
		LoadBans()		// try to load the bans
		if(!GLOB.banlist_savefile)	// uh oh, can't find bans!
			return 0	// ABORT ABORT ABORT

	. = list()
	var/appeal
	if(config && config.banappeals)
		appeal = "\nFor more information on your ban, or to appeal, head to <a href='[config.banappeals]'>[config.banappeals]</a>"
	GLOB.banlist_savefile.cd = "/base"
	if( "[ckey][id]" in GLOB.banlist_savefile.dir )
		GLOB.banlist_savefile.cd = "[ckey][id]"
		if(GLOB.banlist_savefile["temp"])
			if(!GetExp(GLOB.banlist_savefile["minutes"]))
				ClearTempbans()
				return 0
			else
				.["desc"] = "\nReason: [GLOB.banlist_savefile["reason"]]\nExpires: [GetExp(GLOB.banlist_savefile["minutes"])]\nBy: [GLOB.banlist_savefile["bannedby"]][appeal]"
		else
			GLOB.banlist_savefile.cd	= "/base/[ckey][id]"
			.["desc"]	= "\nReason: [GLOB.banlist_savefile["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [GLOB.banlist_savefile["bannedby"]][appeal]"
		.["reason"]	= "ckey/id"
		return .
	else
		for(var/A in GLOB.banlist_savefile.dir)
			GLOB.banlist_savefile.cd = "/base/[A]"
			var/matches
			if( ckey == GLOB.banlist_savefile["key"] )
				matches += "ckey"
			if( id == GLOB.banlist_savefile["id"] )
				if(matches)
					matches += "/"
				matches += "id"
			if( address == GLOB.banlist_savefile["ip"] )
				if(matches)
					matches += "/"
				matches += "ip"

			if(matches)
				if(GLOB.banlist_savefile["temp"])
					if(!GetExp(GLOB.banlist_savefile["minutes"]))
						ClearTempbans()
						return 0
					else
						.["desc"] = "\nReason: [GLOB.banlist_savefile["reason"]]\nExpires: [GetExp(GLOB.banlist_savefile["minutes"])]\nBy: [GLOB.banlist_savefile["bannedby"]][appeal]"
				else
					.["desc"] = "\nReason: [GLOB.banlist_savefile["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [GLOB.banlist_savefile["bannedby"]][appeal]"
				.["reason"] = matches
				return .
	return 0

/proc/UpdateTime() //No idea why i made this a proc.
	GLOB.CMinutes = (world.realtime / 10) / 60
	return 1

/hook/startup/proc/loadBans()
	return LoadBans()

/proc/LoadBans()

	GLOB.banlist_savefile = new("data/banlist.bdb")
	log_admin("Loading Banlist")

	if(!length(GLOB.banlist_savefile.dir)) log_admin("Banlist is empty.")

	if(!GLOB.banlist_savefile.dir.Find("base"))
		log_admin("Banlist missing base dir.")
		GLOB.banlist_savefile.dir.Add("base")
		GLOB.banlist_savefile.cd = "/base"
	else if(GLOB.banlist_savefile.dir.Find("base"))
		GLOB.banlist_savefile.cd = "/base"

	ClearTempbans()
	return 1

/proc/ClearTempbans()
	UpdateTime()

	GLOB.banlist_savefile.cd = "/base"
	for(var/A in GLOB.banlist_savefile.dir)
		GLOB.banlist_savefile.cd = "/base/[A]"
		if(!GLOB.banlist_savefile["key"] || !GLOB.banlist_savefile["id"])
			RemoveBan(A)
			log_admin("Invalid Ban.")
			message_admins("Invalid Ban.")
			continue

		if(!GLOB.banlist_savefile["temp"]) continue
		if(GLOB.CMinutes >= GLOB.banlist_savefile["minutes"]) RemoveBan(A)

	return 1


/proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes, address)

	var/bantimestamp

	if(temp)
		UpdateTime()
		bantimestamp = GLOB.CMinutes + minutes

	GLOB.banlist_savefile.cd = "/base"
	if( GLOB.banlist_savefile.dir.Find("[ckey][computerid]") )
		to_chat(usr, "<span class='danger'>Ban already exists.</span>")
		return 0
	else
		GLOB.banlist_savefile.dir.Add("[ckey][computerid]")
		GLOB.banlist_savefile.cd = "/base/[ckey][computerid]"
		GLOB.banlist_savefile["key"] << ckey
		GLOB.banlist_savefile["id"] << computerid
		GLOB.banlist_savefile["ip"] << address
		GLOB.banlist_savefile["reason"] << reason
		GLOB.banlist_savefile["bannedby"] << bannedby
		GLOB.banlist_savefile["temp"] << temp
		if(temp)
			GLOB.banlist_savefile["minutes"] << bantimestamp
		if(!temp)
			add_note(ckey, "Permanently banned - [reason]", null, bannedby, 0)
		else
			add_note(ckey, "Banned for [minutes] minutes - [reason]", null, bannedby, 0)
	return 1

/proc/RemoveBan(foldername)
	var/key
	var/id

	GLOB.banlist_savefile.cd = "/base/[foldername]"
	GLOB.banlist_savefile["key"] >> key
	GLOB.banlist_savefile["id"] >> id
	GLOB.banlist_savefile.cd = "/base"

	if(!GLOB.banlist_savefile.dir.Remove(foldername)) return 0

	if(!usr)
		log_admin("Ban Expired: [key]")
		message_admins("Ban Expired: [key]")
	else
		ban_unban_log_save("[key_name_admin(usr)] unbanned [key]")
		log_admin("[key_name_admin(usr)] unbanned [key]")
		message_admins("[key_name_admin(usr)] unbanned: [key]")
		feedback_inc("ban_unban",1)
		usr.client.holder.DB_ban_unban( ckey(key), BANTYPE_ANY_FULLBAN)
	for(var/A in GLOB.banlist_savefile.dir)
		GLOB.banlist_savefile.cd = "/base/[A]"
		if(key == GLOB.banlist_savefile["key"] /*|| id == GLOB.banlist_savefile["id"]*/)
			GLOB.banlist_savefile.cd = "/base"
			GLOB.banlist_savefile.dir.Remove(A)
			continue

	return 1

/proc/GetExp(minutes as num)
	UpdateTime()
	var/exp = minutes - GLOB.CMinutes
	if(exp <= 0)
		return 0
	else
		var/timeleftstring
		if(exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if(exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring

/datum/admins/proc/unbanpanel()
	var/count = 0
	var/dat
	GLOB.banlist_savefile.cd = "/base"
	for(var/A in GLOB.banlist_savefile.dir)
		count++
		GLOB.banlist_savefile.cd = "/base/[A]"
		var/ref		= UID()
		var/key		= GLOB.banlist_savefile["key"]
		var/id		= GLOB.banlist_savefile["id"]
		var/ip		= GLOB.banlist_savefile["ip"]
		var/reason	= GLOB.banlist_savefile["reason"]
		var/by		= GLOB.banlist_savefile["bannedby"]
		var/expiry
		if(GLOB.banlist_savefile["temp"])
			expiry = GetExp(GLOB.banlist_savefile["minutes"])
			if(!expiry)		expiry = "Removal Pending"
		else				expiry = "Permaban"

		dat += text("<tr><td><A href='?src=[ref];unbanf=[key][id]'>(U)</A><A href='?src=[ref];unbane=[key][id]'>(E)</A> Key: <B>[key]</B></td><td>ComputerID: <B>[id]</B></td><td>IP: <B>[ip]</B></td><td> [expiry]</td><td>(By: [by])</td><td>(Reason: [reason])</td></tr>")

	dat += "</table>"
	dat = "<HR><B>Bans:</B> <FONT COLOR=blue>(U) = Unban , (E) = Edit Ban</FONT> - <FONT COLOR=green>([count] Bans)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat, "window=unbanp;size=875x400")

//////////////////////////////////// DEBUG ////////////////////////////////////

/proc/CreateBans()

	UpdateTime()

	var/i
	var/last

	for(i=0, i<1001, i++)
		var/a = pick(1,0)
		var/b = pick(1,0)
		if(b)
			GLOB.banlist_savefile.cd = "/base"
			GLOB.banlist_savefile.dir.Add("trash[i]trashid[i]")
			GLOB.banlist_savefile.cd = "/base/trash[i]trashid[i]"
			GLOB.banlist_savefile["key"] << "trash[i]"
		else
			GLOB.banlist_savefile.cd = "/base"
			GLOB.banlist_savefile.dir.Add("[last]trashid[i]")
			GLOB.banlist_savefile.cd = "/base/[last]trashid[i]"
			GLOB.banlist_savefile["key"] << last
		GLOB.banlist_savefile["id"] << "trashid[i]"
		GLOB.banlist_savefile["reason"] << "Trashban[i]."
		GLOB.banlist_savefile["temp"] << a
		GLOB.banlist_savefile["minutes"] << GLOB.CMinutes + rand(1,2000)
		GLOB.banlist_savefile["bannedby"] << "trashmin"
		last = "trash[i]"

	GLOB.banlist_savefile.cd = "/base"

/proc/ClearAllBans()
	GLOB.banlist_savefile.cd = "/base"
	for(var/A in GLOB.banlist_savefile.dir)
		RemoveBan(A)

