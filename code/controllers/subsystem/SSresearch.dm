SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY // ALL THE THINGS
	wait = 60 SECONDS
	cpu_display = SS_CPUDISPLAY_LOW
	offline_implications = "Ingame R&D may no longer function correctly and will no longer have an OOC backup. No immediate action is needed."
	/// List of R&D backups - Key = datum ID, value = /datum/rnd_backup
	var/list/backups = list()
	/// Used to ensure research lists contain valid point types.
	var/list/point_types = list("Research", "Illegal", "Alien")
	/// Used to determine toxins reward, global as toxins is only used for points by the station.
	var/successful_toxins = 0

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
		for(var/node_id in RNC.research_files.known_technodes)
			var/datum/technode/T = RNC.research_files.known_technodes[node_id]
			B.technodes[node_id] = T
		for(var/point_type in RNC.research_files.research_points)
			B.points[point_type] = RNC.research_files.research_points[point_type]


/datum/rnd_backup
	/// Name of last network
	var/last_name
	/// Timestamp of last backup
	var/last_timestamp
	/// List of technodes
	var/list/technodes = list()
	/// List of points
	var/list/points = list()

/datum/rnd_backup/proc/to_backup_disk(turf/T)
	var/obj/item/disk/rnd_backup_disk/D = new(T)
	D.stored_tech_assoc = technodes
	D.last_backup_time = last_timestamp
