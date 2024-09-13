SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY // ALL THE THINGS
	wait = 60 SECONDS
	cpu_display = SS_CPUDISPLAY_LOW
	offline_implications = "Ingame R&D will no longer have an OOC backup. No immediate action is needed."
	/// List of R&D backups - Key = datum ID, value = /datum/rnd_backup
	var/list/backups = list()

/datum/controller/subsystem/research/get_stat_details()
	return "C:[length(backups)]"

/datum/controller/subsystem/research/fire()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		var/rnc_uid = RNC.UID()
		if(!(rnc_uid in backups))
			backups[rnc_uid] = new /datum/rnd_backup

		var/datum/rnd_backup/B = backups[rnc_uid]
		B.last_name = RNC.network_name
		B.last_timestamp = time2text(ROUND_TIME, "hh:mm:ss")
		B.levels.Cut()
		for(var/tech_id in RNC.research_files.known_tech)
			var/datum/tech/T = RNC.research_files.known_tech[tech_id]
			B.levels[tech_id] = T.level

/datum/rnd_backup
	/// Name of last network
	var/last_name
	/// Timestamp of last backup
	var/last_timestamp
	/// List of levels
	var/list/levels = list()

/datum/rnd_backup/proc/to_backup_disk(turf/T)
	var/obj/item/disk/rnd_backup_disk/D = new(T)
	D.stored_tech_assoc = levels
	D.last_backup_time = last_timestamp
