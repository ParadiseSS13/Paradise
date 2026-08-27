SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS
	priority = FIRE_PRIORITY_ACHIEVEMENTS
	var/achievements_enabled = FALSE

	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///The achievement with the highest amount of players that have unlocked it.
	var/datum/award/achievement/most_unlocked_achievement
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

/datum/controller/subsystem/achievements/Initialize()
	if(!SSdbcore.Connect())
		return
	achievements_enabled = TRUE

	var/list/achievements_by_db_id = list()
	for(var/datum/award/achievement/achievement as anything in subtypesof(/datum/award/achievement))
		if(!initial(achievement.database_id)) // abstract type
			continue
		var/datum/award/achievement/instance = new achievement
		achievements[achievement] = instance
		awards[achievement] = instance
		achievements_by_db_id[instance.database_id] = instance

	for(var/datum/award/score/score as anything in subtypesof(/datum/award/score))
		if(!initial(score.database_id)) // abstract type
			continue
		var/instance = new score
		scores[score] = instance
		awards[score] = instance

	update_metadata()

	/**
	 * Count how many (unlocked) achievements are in the achievements database
	 * then store that amount in the times_achieved variable for each achievement.
	 *
	 * Thanks to Jordie for the query.
	 */
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT a.achievement_key, COUNT(a.achievement_key) AS count FROM achievements a \
		JOIN achievement_metadata m ON a.achievement_key = m.achievement_key AND m.achievement_type = 'achievement' \
		GROUP BY a.achievement_key ORDER BY count DESC"
	)
	if(query.Execute(async = TRUE))
		while(query.NextRow())
			var/id = query.item[1]
			var/datum/award/achievement/instance = id ? achievements_by_db_id[id] : null
			if(isnull(instance)) // removed achievement
				continue
			instance.times_achieved = query.item[2]
			// the results are ordered in descending orders, so the first in the list should be the most unlocked one.
			if(!most_unlocked_achievement)
				most_unlocked_achievement = instance
	qdel(query)

	for(var/ckey in GLOB.persistent_clients_by_ckey)
		var/datum/persistent_client/persistent_client = GLOB.persistent_clients_by_ckey[ckey]
		if(!persistent_client.achievements.initialized)
			persistent_client.achievements.InitializeData()

	return

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_db()

/datum/controller/subsystem/achievements/proc/save_achievements_to_db()
	var/list/cheevos_to_save = list()
	for(var/ckey in GLOB.persistent_clients_by_ckey)
		var/datum/persistent_client/persistent_client = GLOB.persistent_clients_by_ckey[ckey]
		if(!persistent_client?.achievements)
			continue
		cheevos_to_save += persistent_client.achievements.get_changed_data()

	if(!length(cheevos_to_save))
		return

	SSdbcore.MassInsert(format_table_name("achievements"), cheevos_to_save,duplicate_key = TRUE)
	SEND_SIGNAL(src, COMSIG_ACHIEVEMENTS_SAVED_TO_DB)

//Update the metadata if any are behind
/datum/controller/subsystem/achievements/proc/update_metadata()
	var/list/current_metadata = list()
	//select metadata here
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT achievement_key,achievement_version FROM [format_table_name("achievement_metadata")]")
	if(!query.Execute(async = TRUE))
		qdel(query)
		return
	else
		while(query.NextRow())
			current_metadata[query.item[1]] = text2num(query.item[2])
		qdel(query)

	var/list/to_update = list()
	for(var/key in awards)
		var/datum/award/award = awards[key]
		if(!current_metadata[award.database_id] || current_metadata[award.database_id] < award.achievement_version)
			to_update += list(award.get_metadata_row())

	if(length(to_update))
		SSdbcore.MassInsert(format_table_name("achievement_metadata"), to_update, duplicate_key = TRUE)

	var/list/orphaned_keys = get_orphaned_keys(FALSE)
	if(length(orphaned_keys))
		message_admins("Achievement metadata found without matching achievement, use Achievements-Admin-Panel verb to cleanup if necessary")

/// returns list of metadata keys and versions in db with no matching achievement datum, either deleted achievements, or from server with code ahead of us.
/datum/controller/subsystem/achievements/proc/get_orphaned_keys(include_archived = TRUE)
	. = list()
	var/list/current_metadata = list()
	// Fetch all keys from the db
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT achievement_key,achievement_version FROM [format_table_name("achievement_metadata")]")
	if(!query.Execute(async = TRUE))
		qdel(query)
		return
	else
		while(query.NextRow())
			current_metadata[query.item[1]] = query.item[2]
		qdel(query)

	var/list/achievements_by_db_id = list()
	for(var/datum/award/award as anything in subtypesof(/datum/award))
		if(!initial(award.database_id)) // abstract type
			continue
		achievements_by_db_id[award.database_id] = TRUE

	for(var/key in current_metadata)
		if(achievements_by_db_id[key])
			continue
		if(!include_archived && current_metadata[key] == ACHIEVEMENT_ARCHIVED_VERSION)
			continue
		.[key] = current_metadata[key]
