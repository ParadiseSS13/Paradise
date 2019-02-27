/var/const/access_security = 1 // Security equipment
/var/const/access_brig = 2 // Brig timers and permabrig
/var/const/access_armory = 3
/var/const/access_forensics_lockers= 4
/var/const/access_medical = 5
/var/const/access_morgue = 6
/var/const/access_tox = 7
/var/const/access_tox_storage = 8
/var/const/access_genetics = 9
/var/const/access_engine = 10
/var/const/access_engine_equip = 11
/var/const/access_maint_tunnels = 12
/var/const/access_external_airlocks = 13
/var/const/access_emergency_storage = 14
/var/const/access_change_ids = 15
/var/const/access_ai_upload = 16
/var/const/access_teleporter = 17
/var/const/access_eva = 18
/var/const/access_heads = 19
/var/const/access_captain = 20
/var/const/access_all_personal_lockers = 21
/var/const/access_chapel_office = 22
/var/const/access_tech_storage = 23
/var/const/access_atmospherics = 24
/var/const/access_bar = 25
/var/const/access_janitor = 26
/var/const/access_crematorium = 27
/var/const/access_kitchen = 28
/var/const/access_robotics = 29
/var/const/access_rd = 30
/var/const/access_cargo = 31
/var/const/access_construction = 32
/var/const/access_chemistry = 33
/var/const/access_cargo_bot = 34
/var/const/access_hydroponics = 35
/var/const/access_manufacturing = 36
/var/const/access_library = 37
/var/const/access_lawyer = 38
/var/const/access_virology = 39
/var/const/access_cmo = 40
/var/const/access_qm = 41
/var/const/access_court = 42
/var/const/access_clown = 43
/var/const/access_mime = 44
/var/const/access_surgery = 45
/var/const/access_theatre = 46
/var/const/access_research = 47
/var/const/access_mining = 48
/var/const/access_mining_office = 49 //not in use
/var/const/access_mailsorting = 50
/var/const/access_mint = 51
/var/const/access_mint_vault = 52
/var/const/access_heads_vault = 53
/var/const/access_mining_station = 54
/var/const/access_xenobiology = 55
/var/const/access_ce = 56
/var/const/access_hop = 57
/var/const/access_hos = 58
/var/const/access_RC_announce = 59 //Request console announcements
/var/const/access_keycard_auth = 60 //Used for events which require at least two people to confirm them
/var/const/access_tcomsat = 61 // has access to the entire telecomms satellite / machinery
/var/const/access_gateway = 62
/var/const/access_sec_doors = 63 // Security front doors
/var/const/access_psychiatrist = 64 // Psychiatrist's office
/var/const/access_xenoarch = 65
/var/const/access_paramedic = 66
/var/const/access_blueshield = 67
/var/const/access_salvage_captain = 69 // Salvage ship captain's quarters
/var/const/access_mechanic = 70
/var/const/access_pilot = 71
/var/const/access_ntrep = 73
/var/const/access_magistrate = 74
/var/const/access_minisat = 75
/var/const/access_mineral_storeroom = 76
/var/const/access_network = 77

/var/const/access_weapons = 99 //Weapon authorization for secbots

	//BEGIN CENTCOM ACCESS
/var/const/access_cent_general = 101//General facilities.
/var/const/access_cent_living = 102//Living quarters.
/var/const/access_cent_medical = 103//Medical.
/var/const/access_cent_security = 104//Security.
/var/const/access_cent_storage = 105//Storage areas.
/var/const/access_cent_shuttles = 106//Shuttle docks.
/var/const/access_cent_telecomms = 107//Telecomms.
/var/const/access_cent_teleporter = 108//Teleporter
/var/const/access_cent_specops = 109//Special Ops.
/var/const/access_cent_specops_commander = 110//Special Ops Commander.
/var/const/access_cent_blackops = 111//Black Ops.
/var/const/access_cent_thunder = 112//Thunderdome.
/var/const/access_cent_bridge = 113//Bridge.
/var/const/access_cent_commander = 114//Commander's Office/ID computer.

//The Syndicate
/var/const/access_syndicate = 150//General Syndicate Access
/var/const/access_syndicate_leader = 151//Nuke Op Leader Access
/var/const/access_vox = 152//Vox Access
/var/const/access_syndicate_command = 153//Admin syndi officer

//Trade Stations
var/const/access_trade_sol = 160

//MONEY
/var/const/access_crate_cash = 200

//Awaymissions
/var/const/access_away01 = 271

//Ghost roles
var/const/access_free_golems = 300

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

	if(acc == IGNORE_ACCESS)
		return 1 //Mob ignores access

	else
		return check_access_list(acc)

	return 0

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

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

/obj/proc/check_access_list(var/list/L)
	generate_req_lists()

	if(!L)
		return 0
	if(!istype(L, /list))
		return 0
	return has_access(req_access, req_one_access, L)

/proc/has_access(var/list/req_access, var/list/req_one_access, var/list/accesses)
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
			return list(access_cent_general, access_cent_living)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_medical, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Emergency Response Team Member")
			return list(access_cent_general, access_cent_living, access_cent_medical, access_cent_security, access_cent_storage, access_cent_specops) + get_all_accesses()
		if("Emergency Response Team Leader")
			return list(access_cent_general, access_cent_living, access_cent_medical, access_cent_security, access_cent_storage, access_cent_specops, access_cent_specops_commander) + get_all_accesses()
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical, access_cent_storage) + get_all_accesses()
		if("Intel Officer")
			return list(access_cent_general, access_cent_living, access_cent_security, access_cent_storage) + get_all_accesses()
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_storage, access_cent_telecomms, access_cent_teleporter) + get_all_accesses()
		if("Death Commando")
			return list(access_cent_general, access_cent_living, access_cent_medical, access_cent_security, access_cent_storage, access_cent_specops, access_cent_specops_commander, access_cent_blackops) + get_all_accesses()
		if("Deathsquad Officer")
			return get_all_centcom_access() + get_all_accesses()
		if("NT Undercover Operative")
			return get_all_centcom_access() + get_all_accesses()
		if("Special Operations Officer")
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
			return list(access_syndicate)
		if("Syndicate Operative Leader")
			return list(access_syndicate, access_syndicate_leader)
		if("Syndicate Agent")
			return list(access_syndicate, access_maint_tunnels)
		if("Vox Raider")
			return list(access_vox)
		if("Vox Trader")
			return list(access_vox)
		if("Syndicate Commando")
			return list(access_syndicate, access_syndicate_leader)
		if("Syndicate Officer")
			return list(access_syndicate, access_syndicate_leader, access_syndicate_command)

/proc/get_all_accesses()
	return list(access_security, access_sec_doors, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_genetics, access_morgue, access_rd,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction,
	            access_hydroponics, access_library, access_lawyer, access_virology, access_psychiatrist, access_cmo, access_qm, access_clown, access_mime, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_paramedic, access_blueshield, access_mechanic,access_weapons,
	            access_pilot, access_ntrep, access_magistrate, access_mineral_storeroom, access_minisat, access_network)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_living, access_cent_medical, access_cent_security, access_cent_storage, access_cent_shuttles, access_cent_telecomms, access_cent_teleporter, access_cent_specops, access_cent_specops_commander, access_cent_blackops, access_cent_thunder, access_cent_bridge, access_cent_commander)

/proc/get_all_syndicate_access()
	return list(access_syndicate, access_syndicate_leader, access_vox, access_syndicate_command)

/proc/get_all_misc_access()
	return list(access_salvage_captain, access_trade_sol, access_crate_cash, access_away01)

/proc/get_absolutely_all_accesses()
	return (get_all_accesses() | get_all_centcom_access() | get_all_syndicate_access() | get_all_misc_access())

/proc/get_region_accesses(code)
	switch(code)
		if(REGION_ALL)
			return get_all_accesses()
		if(REGION_GENERAL) //station general
			return list(access_kitchen, access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer, access_magistrate, access_clown, access_mime)
		if(REGION_SECURITY) //security
			return list(access_sec_doors, access_weapons, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_pilot, access_hos)
		if(REGION_MEDBAY) //medbay
			return list(access_medical, access_genetics, access_morgue, access_chemistry, access_psychiatrist, access_virology, access_surgery, access_cmo, access_paramedic)
		if(REGION_RESEARCH) //research
			return list(access_research, access_tox, access_tox_storage, access_genetics, access_robotics, access_xenobiology, access_xenoarch, access_minisat, access_rd, access_network)
		if(REGION_ENGINEERING) //engineering and maintenance
			return list(access_construction, access_maint_tunnels, access_engine, access_engine_equip, access_external_airlocks, access_tech_storage, access_atmospherics, access_minisat, access_ce, access_mechanic)
		if(REGION_SUPPLY) //supply
			return list(access_mailsorting, access_mining, access_mining_station, access_mineral_storeroom, access_cargo, access_qm)
		if(REGION_COMMAND) //command
			return list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_tcomsat, access_gateway, access_all_personal_lockers, access_heads_vault, access_blueshield, access_ntrep, access_hop, access_captain)
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
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Cargo Bot Delivery"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Holding Cells"
		if(access_court)
			return "Courtroom"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_genetics)
			return "Genetics Lab"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "R&D Lab"
		if(access_tox_storage)
			return "Toxins Lab"
		if(access_chemistry)
			return "Chemistry Lab"
		if(access_rd)
			return "Research Director"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Custodial Closet"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "Power Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlocks"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Bridge"
		if(access_captain)
			return "Captain"
		if(access_all_personal_lockers)
			return "Personal Lockers"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction Areas"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydroponics)
			return "Hydroponics"
		if(access_library)
			return "Library"
		if(access_lawyer)
			return "Law Office"
		if(access_robotics)
			return "Robotics"
		if(access_virology)
			return "Virology"
		if(access_psychiatrist)
			return "Psychiatrist's Office"
		if(access_cmo)
			return "Chief Medical Officer"
		if(access_qm)
			return "Quartermaster"
		if(access_clown)
			return "Clown's Office"
		if(access_mime)
			return "Mime's Office"
		if(access_surgery)
			return "Surgery"
		if(access_theatre)
			return "Theatre"
		if(access_manufacturing)
			return "Manufacturing"
		if(access_research)
			return "Science"
		if(access_mining)
			return "Mining"
		if(access_mining_office)
			return "Mining Office"
		if(access_mailsorting)
			return "Cargo Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining EVA"
		if(access_xenobiology)
			return "Xenobiology Lab"
		if(access_xenoarch)
			return "Xenoarchaeology"
		if(access_hop)
			return "Head of Personnel"
		if(access_hos)
			return "Head of Security"
		if(access_ce)
			return "Chief Engineer"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth. Device"
		if(access_tcomsat)
			return "Telecommunications"
		if(access_network)
			return "Network Access"
		if(access_gateway)
			return "Gateway"
		if(access_sec_doors)
			return "Brig"
		if(access_blueshield)
			return "Blueshield"
		if(access_ntrep)
			return "Nanotrasen Rep."
		if(access_paramedic)
			return "Paramedic"
		if(access_mechanic)
			return "Mechanic Workshop"
		if(access_pilot)
			return "Security Pod Pilot"
		if(access_magistrate)
			return "Magistrate"
		if(access_mineral_storeroom)
			return "Mineral Storage"
		if(access_minisat)
			return "AI Satellite"
		if(access_weapons)
			return "Weapon Permit"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_cent_general)
			return "General Access"
		if(access_cent_living)
			return "Living Quarters"
		if(access_cent_medical)
			return "Medical"
		if(access_cent_security)
			return "Security"
		if(access_cent_storage)
			return "Storage"
		if(access_cent_shuttles)
			return "Shuttles"
		if(access_cent_telecomms)
			return "Telecommunications"
		if(access_cent_teleporter)
			return "Teleporter"
		if(access_cent_specops)
			return "Special Ops"
		if(access_cent_specops_commander)
			return "Special Ops Commander"
		if(access_cent_blackops)
			return "Black Ops"
		if(access_cent_thunder)
			return "Thunderdome"
		if(access_cent_bridge)
			return "Bridge"
		if(access_cent_commander)
			return "Commander"

/proc/get_syndicate_access_desc(A)
	switch(A)
		if(access_syndicate)
			return "Syndicate Operative"
		if(access_syndicate_leader)
			return "Syndicate Operative Leader"
		if(access_vox)
			return "Vox"
		if(access_syndicate_command)
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
	return list("VIP Guest","Custodian","Thunderdome Overseer","Emergency Response Team Member","Emergency Response Team Leader","Intel Officer","Medical Officer","Death Commando","Research Officer","Deathsquad Officer","Special Operations Officer","Nanotrasen Navy Representative","Nanotrasen Navy Officer","Nanotrasen Navy Captain","Supreme Commander")

//gets the actual job rank (ignoring alt titles)
//this is used solely for sechuds
/obj/proc/GetJobRealName()
	if(!istype(src, /obj/item/pda) && !istype(src,/obj/item/card/id))
		return

	var/rank
	var/assignment
	if(istype(src, /obj/item/pda))
		if(src:id)
			rank = src:id:rank
			assignment = src:id:assignment
	else if(istype(src, /obj/item/card/id))
		rank = src:rank
		assignment = src:assignment

	if( rank in GLOB.joblist )
		return rank

	if( assignment in GLOB.joblist )
		return assignment

	return "Unknown"

//gets the alt title, failing that the actual job rank
//this is unused
/obj/proc/sdsdsd()	//GetJobDisplayName
	if(!istype(src, /obj/item/pda) && !istype(src,/obj/item/card/id))
		return

	var/assignment
	if(istype(src, /obj/item/pda))
		if(src:id)
			assignment = src:id:assignment
	else if(istype(src, /obj/item/card/id))
		assignment = src:assignment

	if(assignment)
		return assignment

	return "Unknown"

proc/GetIdCard(var/mob/living/carbon/human/H)
	if(H.wear_id)
		var/id = H.wear_id.GetID()
		if(id)
			return id
	if(H.get_active_hand())
		var/obj/item/I = H.get_active_hand()
		return I.GetID()

proc/FindNameFromID(var/mob/living/carbon/human/H)
	ASSERT(istype(H))
	var/obj/item/card/id/C = H.get_active_hand()
	if( istype(C) || istype(C, /obj/item/pda) )
		var/obj/item/card/id/ID = C

		if( istype(C, /obj/item/pda) )
			var/obj/item/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

	C = H.wear_id

	if( istype(C) || istype(C, /obj/item/pda) )
		var/obj/item/card/id/ID = C

		if( istype(C, /obj/item/pda) )
			var/obj/item/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

proc/get_all_job_icons() //For all existing HUD icons
	return GLOB.joblist + list("Prisoner")

/obj/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/card/id/I
	if(istype(src, /obj/item/pda))
		var/obj/item/pda/P = src
		I = P.id
	else if(istype(src, /obj/item/card/id))
		I = src

	if(I)
		var/job_icons = get_all_job_icons()
		var/centcom = get_all_centcom_jobs()

		if(I.assignment	in centcom) //Return with the NT logo if it is a Centcom job
			return "Centcom"
		if(I.rank in centcom)
			return "Centcom"

		if(I.assignment	in job_icons) //Check if the job has a hud icon
			return I.assignment
		if(I.rank in job_icons)
			return I.rank

	else
		return

	return "Unknown" //Return unknown if none of the above apply
