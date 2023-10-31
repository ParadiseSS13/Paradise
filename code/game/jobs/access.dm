/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if we don't require any access at all
	if(check_access())
		return 1

	if(!M)
		return 0

	var/acc = M.get_access() //see mob.dm

	if(acc == IGNORE_ACCESS || M.can_admin_interact())
		return 1 //Mob ignores access

	else
		return check_access_list(acc)

/obj/proc/generate_req_lists()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!req_access)
		req_access = list()
		if(req_access_txt)
			var/list/req_access_str = splittext(req_access_txt, ";")
			for(var/x in req_access_str)
				var/n = text2num(x)
				if(n)
					req_access += n

	if(!req_one_access)
		req_one_access = list()
		if(req_one_access_txt)
			var/list/req_one_access_str = splittext(req_one_access_txt,";")
			for(var/x in req_one_access_str)
				var/n = text2num(x)
				if(n)
					req_one_access += n

/obj/proc/check_access(obj/item/I)
	var/list/L
	if(I)
		L = I.GetAccess()
	else
		L = list()
	return check_access_list(L)

/obj/proc/check_access_list(list/L)
	generate_req_lists()

	if(!L)
		return 0
	if(!istype(L, /list))
		return 0
	return has_access(req_access, req_one_access, L)

/proc/has_access(list/req_access, list/req_one_access, list/accesses)
	for(var/req in req_access)
		if(!(req in accesses)) //doesn't have this access
			return 0
	if(req_one_access.len)
		for(var/req in req_one_access)
			if(req in accesses) //has an access from the single access list
				return 1
		return 0
	return 1

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("Custodian")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE)
		if("Thunderdome Overseer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
		if("Emergency Response Team Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS) + get_all_accesses()
		if("Emergency Response Team Engineer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS) + get_all_accesses()
		if("Emergency Response Team Medic")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS) + get_all_accesses()
		if("Emergency Response Team Inquisitor")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS) + get_all_accesses()
		if("Emergency Response Team Janitor")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS) + get_all_accesses()
		if("Emergency Response Team Member")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS) + get_all_accesses()
		if("Emergency Response Team Leader")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS, ACCESS_CENT_SPECOPS_COMMANDER) + get_all_accesses()
		if("Medical Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE) + get_all_accesses()
		if("Intel Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE) + get_all_accesses()
		if("Research Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_CENT_TELECOMMS, ACCESS_CENT_TELEPORTER) + get_all_accesses()
		if("Deathsquad Commando")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS, ACCESS_CENT_SPECOPS_COMMANDER, ACCESS_CENT_BLACKOPS) + get_all_accesses()
		if("NT Undercover Operative")
			return get_all_centcom_access() + get_all_accesses()
		if("Special Operations Officer")
			return get_all_centcom_access() + get_all_accesses()
		if("Solar Federation General")
			return get_all_centcom_access() + get_all_accesses()
		if("Nanotrasen Navy Representative")
			return get_all_centcom_access() + get_all_accesses()
		if("Nanotrasen Navy Officer")
			return get_all_centcom_access() + get_all_accesses()
		if("Nanotrasen Navy Captain")
			return get_all_centcom_access() + get_all_accesses()
		if("Supreme Commander")
			return get_all_centcom_access() + get_all_accesses()

/proc/get_syndicate_access(job)
	switch(job)
		if("Syndicate Operative")
			return list(ACCESS_SYNDICATE)
		if("Syndicate Operative Leader")
			return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
		if("Syndicate Agent")
			return list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)
		if("Syndicate Commando")
			return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
		if("Syndicate Officer")
			return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND)

/proc/get_all_accesses()
	return list(ACCESS_MINISAT, ACCESS_AI_UPLOAD,  ACCESS_ARMORY, ACCESS_ATMOSPHERICS, ACCESS_BAR, ACCESS_SEC_DOORS, ACCESS_BLUESHIELD,
				ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_CHAPEL_OFFICE, ACCESS_CE, ACCESS_CHEMISTRY, ACCESS_CLOWN, ACCESS_CMO,
				ACCESS_COURT, ACCESS_CONSTRUCTION, ACCESS_CREMATORIUM, ACCESS_JANITOR, ACCESS_ENGINE, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_FORENSICS_LOCKERS,
				ACCESS_GENETICS, ACCESS_EXPEDITION, ACCESS_BRIG, ACCESS_HOP, ACCESS_HOS, ACCESS_HYDROPONICS, ACCESS_CHANGE_IDS, ACCESS_KEYCARD_AUTH, ACCESS_KITCHEN,
				ACCESS_LAWYER, ACCESS_LIBRARY, ACCESS_MAGISTRATE, ACCESS_MAINT_TUNNELS, ACCESS_HEADS_VAULT, ACCESS_MEDICAL, ACCESS_MIME,
				ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_NETWORK, ACCESS_NTREP, ACCESS_PARAMEDIC,  ACCESS_ALL_PERSONAL_LOCKERS,
				ACCESS_ENGINE_EQUIP, ACCESS_PSYCHIATRIST, ACCESS_QM, ACCESS_RD, ACCESS_RC_ANNOUNCE, ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_RESEARCH, ACCESS_SECURITY,
				ACCESS_SURGERY, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_THEATRE, ACCESS_TCOMSAT, ACCESS_TOX_STORAGE, ACCESS_VIROLOGY, ACCESS_WEAPONS, ACCESS_XENOBIOLOGY,
				ACCESS_XENOARCH)

/proc/get_all_centcom_access()
	return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SHUTTLES, ACCESS_CENT_TELECOMMS, ACCESS_CENT_TELEPORTER, ACCESS_CENT_SPECOPS, ACCESS_CENT_SPECOPS_COMMANDER, ACCESS_CENT_BLACKOPS, ACCESS_CENT_THUNDER, ACCESS_CENT_BRIDGE, ACCESS_CENT_COMMANDER)

/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND)

/proc/get_all_misc_access()
	return list(ACCESS_SALVAGE_CAPTAIN, ACCESS_TRADE_SOL, ACCESS_CRATE_CASH, ACCESS_AWAY01)

/proc/get_absolutely_all_accesses()
	return (get_all_accesses() | get_all_centcom_access() | get_all_syndicate_access() | get_all_misc_access())

/proc/get_region_accesses(code)
	switch(code)
		if(REGION_ALL)
			return get_all_accesses()
		if(REGION_GENERAL) //station general
			return list(ACCESS_KITCHEN, ACCESS_BAR, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_THEATRE, ACCESS_LAWYER, ACCESS_MAGISTRATE, ACCESS_CLOWN, ACCESS_MIME)
		if(REGION_SECURITY) //security
			return list(ACCESS_SEC_DOORS, ACCESS_WEAPONS, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_HOS)
		if(REGION_MEDBAY) //medbay
			return list(ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_PSYCHIATRIST, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_CMO, ACCESS_PARAMEDIC)
		if(REGION_RESEARCH) //research
			return list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_GENETICS, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_RD, ACCESS_NETWORK)
		if(REGION_ENGINEERING) //engineering and maintenance
			return list(ACCESS_CONSTRUCTION, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_MINISAT, ACCESS_CE)
		if(REGION_SUPPLY) //supply
			return list(ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_CARGO, ACCESS_QM, ACCESS_HEADS_VAULT)
		if(REGION_COMMAND) //command
			return list(ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_TCOMSAT, ACCESS_EXPEDITION, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_HEADS_VAULT, ACCESS_BLUESHIELD, ACCESS_NTREP, ACCESS_HOP, ACCESS_CAPTAIN)
		if(REGION_CENTCOMM) //because why the heck not
			return get_all_centcom_access() + get_all_accesses()

/proc/get_region_accesses_name(code)
	switch(code)
		if(REGION_ALL)
			return "All"
		if(REGION_GENERAL) //station general
			return "General"
		if(REGION_SECURITY) //security
			return "Security"
		if(REGION_MEDBAY) //medbay
			return "Medbay"
		if(REGION_RESEARCH) //research
			return "Research"
		if(REGION_ENGINEERING) //engineering and maintenance
			return "Engineering"
		if(REGION_SUPPLY) //supply
			return "Supply"
		if(REGION_COMMAND) //command
			return "Command"
		if(REGION_CENTCOMM) //CC
			return "CentComm"


/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_CARGO)
			return "Cargo Bay"
		if(ACCESS_CARGO_BOT)
			return "Cargo Bot Delivery"
		if(ACCESS_SECURITY)
			return "Security"
		if(ACCESS_BRIG)
			return "Holding Cells"
		if(ACCESS_COURT)
			return "Courtroom"
		if(ACCESS_FORENSICS_LOCKERS)
			return "Forensics"
		if(ACCESS_MEDICAL)
			return "Medical"
		if(ACCESS_GENETICS)
			return "Genetics Lab"
		if(ACCESS_MORGUE)
			return "Morgue"
		if(ACCESS_TOX)
			return "R&D Lab"
		if(ACCESS_TOX_STORAGE)
			return "Toxins Lab"
		if(ACCESS_CHEMISTRY)
			return "Chemistry Lab"
		if(ACCESS_RD)
			return "Research Director"
		if(ACCESS_BAR)
			return "Bar"
		if(ACCESS_JANITOR)
			return "Custodial Closet"
		if(ACCESS_ENGINE)
			return "Engineering"
		if(ACCESS_ENGINE_EQUIP)
			return "Power Equipment"
		if(ACCESS_MAINT_TUNNELS)
			return "Maintenance"
		if(ACCESS_EXTERNAL_AIRLOCKS)
			return "External Airlocks"
		if(ACCESS_EMERGENCY_STORAGE)
			return "Emergency Storage"
		if(ACCESS_CHANGE_IDS)
			return "ID Computer"
		if(ACCESS_AI_UPLOAD)
			return "AI Upload"
		if(ACCESS_TELEPORTER)
			return "Teleporter"
		if(ACCESS_EVA)
			return "EVA"
		if(ACCESS_HEADS)
			return "Bridge"
		if(ACCESS_CAPTAIN)
			return "Captain"
		if(ACCESS_ALL_PERSONAL_LOCKERS)
			return "Personal Lockers"
		if(ACCESS_CHAPEL_OFFICE)
			return "Chapel Office"
		if(ACCESS_TECH_STORAGE)
			return "Technical Storage"
		if(ACCESS_ATMOSPHERICS)
			return "Atmospherics"
		if(ACCESS_CREMATORIUM)
			return "Crematorium"
		if(ACCESS_ARMORY)
			return "Armory"
		if(ACCESS_CONSTRUCTION)
			return "Construction Areas"
		if(ACCESS_KITCHEN)
			return "Kitchen"
		if(ACCESS_HYDROPONICS)
			return "Hydroponics"
		if(ACCESS_LIBRARY)
			return "Library"
		if(ACCESS_LAWYER)
			return "Law Office"
		if(ACCESS_ROBOTICS)
			return "Robotics"
		if(ACCESS_VIROLOGY)
			return "Virology"
		if(ACCESS_PSYCHIATRIST)
			return "Psychiatrist's Office"
		if(ACCESS_CMO)
			return "Chief Medical Officer"
		if(ACCESS_QM)
			return "Quartermaster"
		if(ACCESS_CLOWN)
			return "Clown's Office"
		if(ACCESS_MIME)
			return "Mime's Office"
		if(ACCESS_SURGERY)
			return "Surgery"
		if(ACCESS_THEATRE)
			return "Theatre"
		if(ACCESS_MANUFACTURING)
			return "Manufacturing"
		if(ACCESS_RESEARCH)
			return "Science"
		if(ACCESS_MINING)
			return "Mining Dock"
		if(ACCESS_MINING_OFFICE)
			return "Mining Office"
		if(ACCESS_MAILSORTING)
			return "Cargo Office"
		if(ACCESS_MINT)
			return "Mint"
		if(ACCESS_MINT_VAULT)
			return "Mint Vault"
		if(ACCESS_HEADS_VAULT)
			return "Main Vault"
		if(ACCESS_MINING_STATION)
			return "Mining Outpost"
		if(ACCESS_XENOBIOLOGY)
			return "Xenobiology Lab"
		if(ACCESS_XENOARCH)
			return "Xenoarchaeology"
		if(ACCESS_HOP)
			return "Head of Personnel"
		if(ACCESS_HOS)
			return "Head of Security"
		if(ACCESS_CE)
			return "Chief Engineer"
		if(ACCESS_RC_ANNOUNCE)
			return "RC Announcements"
		if(ACCESS_KEYCARD_AUTH)
			return "Keycode Auth. Device"
		if(ACCESS_TCOMSAT)
			return "Telecommunications"
		if(ACCESS_NETWORK)
			return "Network Access"
		if(ACCESS_EXPEDITION)
			return "Expedition"
		if(ACCESS_SEC_DOORS)
			return "Brig"
		if(ACCESS_BLUESHIELD)
			return "Blueshield"
		if(ACCESS_NTREP)
			return "Nanotrasen Rep."
		if(ACCESS_PARAMEDIC)
			return "Paramedic"
		if(ACCESS_MAGISTRATE)
			return "Magistrate"
		if(ACCESS_MINERAL_STOREROOM)
			return "Mineral Storage"
		if(ACCESS_MINISAT)
			return "AI Satellite"
		if(ACCESS_WEAPONS)
			return "Weapon Permit"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_CENT_GENERAL)
			return "General Access"
		if(ACCESS_CENT_LIVING)
			return "Living Quarters"
		if(ACCESS_CENT_MEDICAL)
			return "Medical"
		if(ACCESS_CENT_SECURITY)
			return "Security"
		if(ACCESS_CENT_STORAGE)
			return "Storage"
		if(ACCESS_CENT_SHUTTLES)
			return "Shuttles"
		if(ACCESS_CENT_TELECOMMS)
			return "Telecommunications"
		if(ACCESS_CENT_TELEPORTER)
			return "Teleporter"
		if(ACCESS_CENT_SPECOPS)
			return "Special Ops"
		if(ACCESS_CENT_SPECOPS_COMMANDER)
			return "Special Ops Commander"
		if(ACCESS_CENT_BLACKOPS)
			return "Black Ops"
		if(ACCESS_CENT_THUNDER)
			return "Thunderdome"
		if(ACCESS_CENT_BRIDGE)
			return "Bridge"
		if(ACCESS_CENT_COMMANDER)
			return "Commander"

/proc/get_syndicate_access_desc(A)
	switch(A)
		if(ACCESS_SYNDICATE)
			return "Syndicate Operative"
		if(ACCESS_SYNDICATE_LEADER)
			return "Syndicate Operative Leader"
		if(ACCESS_SYNDICATE_COMMAND)
			return "Syndicate Command"

/proc/get_all_jobs()
	var/list/all_jobs = list()
	var/list/all_datums = subtypesof(/datum/job)
	all_datums.Remove(list(/datum/job/ai,/datum/job/cyborg))
	var/datum/job/jobdatum
	for(var/jobtype in all_datums)
		jobdatum = new jobtype
		all_jobs.Add(jobdatum.title)
	return all_jobs

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Deathsquad Commando","Research Officer","Special Operations Officer","Nanotrasen Navy Representative","Nanotrasen Navy Officer","Nanotrasen Navy Captain","Supreme Commander")

/proc/get_all_ERT_jobs()
	return list("Emergency Response Team Officer","Emergency Response Team Engineer","Emergency Response Team Medic","Emergency Response Team Inquisitor","Emergency Response Team Janitor","Emergency Response Team Leader","Emergency Response Team Member")

/proc/get_all_solgov_jobs()
	return list("Solar Federation Lieutenant","Solar Federation Specops Lieutenant","Solar Federation Marine","Solar Federation Specops Marine","Solar Federation Representative","Sol Trader","Solar Federation General")

/proc/get_all_soviet_jobs()
	return list("Soviet Tourist", "Soviet Conscript", "Soviet Soldier", "Soviet Officer", "Soviet Marine", "Soviet Marine Captain", "Soviet Admiral")

/proc/get_all_job_icons() //For all existing HUD icons
	return GLOB.joblist + get_all_ERT_jobs() + list("Prisoner")

/proc/get_accesslist_static_data(num_min_region = REGION_GENERAL, num_max_region = REGION_COMMAND)
	var/list/retval
	for(var/i in num_min_region to num_max_region)
		var/list/accesses = list()
		var/list/available_accesses
		if(i == REGION_CENTCOMM) // Override necessary, because get_region_accesses(REGION_CENTCOM) returns BOTH CC and crew accesses.
			available_accesses = get_all_centcom_access()
		else
			available_accesses = get_region_accesses(i)
		for(var/access in available_accesses)
			var/access_desc = (i == REGION_CENTCOMM) ? get_centcom_access_desc(access) : get_access_desc(access)
			if(access_desc)
				accesses += list(list(
					"desc" = replacetext(access_desc, "&nbsp", " "),
					"ref" = access,
				))
		retval += list(list(
			"name" = get_region_accesses_name(i),
			"regid" = i,
			"accesses" = accesses
		))
	return retval
