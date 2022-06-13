// ADD TO admin_verbs.dm or they wont show up!
// database
#define WORLD_ID 0

/datum/admins/proc/dbClearQueue()
	set category = "Server"
	set desc="Executes all items in the queue to be synced"
	set name="Database Queue"

	if(!check_rights(R_ADMIN))
		return
	log_and_message_admins("[key_name_admin(usr)] has forced database queue")
	SSdbcore.syncToDb(TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Databse Queue")


/datum/admins/proc/dbSaveAll()
	set category = "Server"
	set desc="Adds all items synced to the database to the queue and executes"
	set name="Databse All"

	if(!check_rights(R_ADMIN))
		return
	log_and_message_admins("[key_name_admin(usr)] has started full database sync...")
	var/updated = 0
	var/missing = 0
	var/fixed = 0
	for(var/atom/A in world)
		if(A.db_uid <= 0) continue
		if(A.sync_to_db())
			updated += 1
			if(istype(A, /turf/simulated))
				for(var/obj/O in A.contents)
					if(O.db_uid <= 0) continue
					missing += 1
					if(O.sync_to_db())
						fixed += 1

	log_and_message_admins("database sync has finished syncing [updated] records with [fixed]/[missing] missing handled")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Databse All")

proc/db_truncate(table)
	var/datum/db_query/record = SSdbcore.NewQuery("TRUNCATE TABLE [table]")
	record.Execute()
	qdel(record)

proc/db_delete(table, where_clause)
	var/datum/db_query/record = SSdbcore.NewQuery("DELETE FROM [table] WHERE ([where_clause])")
	var/value = 0
	record.Execute()
	if(record.NextRow())
		value = text2num(record.item[1])
	qdel(record)
	return value


// helper functions

proc/count_table_db(table, key_name, where_clause)
	var/datum/db_query/record = SSdbcore.NewQuery("SELECT count([key_name]) FROM [table] WHERE ([where_clause])")
	var/value = 0
	record.Execute()
	if(record.NextRow())
		value = 1
	qdel(record)
	return value

proc/check_exists_db(table, key_name, key_value)
	var/datum/db_query/record = SSdbcore.NewQuery("SELECT [key_name] FROM [table] WHERE ([table].[key_name] = [key_value]) LIMIT 0,1")
	var/value = 0
	record.Execute()
	if(record.NextRow())
		value = 1
	qdel(record)
	return value

proc/disable_safe_updates()
	var/datum/db_query/clear_area = SSdbcore.NewQuery("SET SQL_SAFE_UPDATES = 0;")
	clear_area.Execute()
	qdel(clear_area)

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(var/t as text)
	return replacetext(t, "'", "\\'")

/proc/sanitizeText(var/t as text)
	return replacetext(t, "\"", "\\\"")

proc/SaveAllAreas()
	var/areas = 0
	db_truncate("rs_world_areas")
	var/query_string = {"
			INSERT INTO
				rs_world_areas (
					uid,
					type,
					data
				)
			VALUES"}

	for(var/area/AR in world)
		if(istype(AR, /area/space) || istype(AR, /area/shuttle))
			continue
		if(AR.contents.len <= 0)
			continue
		var/list/data = AR.serialize()
		var/data_str = sanitizeSQL("[json_encode(data)]")
		if (areas > 0)
			query_string += ", "
		query_string += {"
		(
			[AR.uid],
			'[AR.type]',
			'[data_str]'
		)
		"}
		//to_chat(world, "DB >> saving area [AR.name] on [AR.map_name] with [AR.uid] as id and [data.len] data, level is [AR.level]")
		areas += 1

	var/datum/db_query/save_areas = SSdbcore.NewQuery(query_string)
	save_areas.Execute()
	qdel(save_areas)

	to_chat(world, "DB >> saved [areas] areas")

proc/SaveAllTurfs(var/turf/start,var/turf/end)
	// turfs
	db_truncate("rs_world_turfs")
	var/query_string = {"
			INSERT INTO
				rs_world_turfs (
					x,y,z,
					data,
					air
				)
			VALUES"}
	var/turf/nw = locate(min(start.x,end.x),max(start.y,end.y),min(start.z,end.z))
	var/turf/se = locate(max(start.x,end.x),min(start.y,end.y),max(start.z,end.z))
	var/turfs = 0
	for(var/pos_z=nw.z;pos_z<=se.z;pos_z++)
		for(var/pos_y=nw.y;pos_y>=se.y;pos_y--)
			for(var/pos_x=nw.x;pos_x<=se.x;pos_x++)
				var/turf/T = locate(pos_x,pos_y,pos_z)
				var/area/A = T.loc
				if(istype(A, /area/space) || istype(A, /area/shuttle))
					continue

				var/data_str = json_encode(T.serialize())
				var/air_str = ""

				if(istype(T, /turf/space))
					continue

				if(istype(T, /turf/simulated/floor))
					var/turf/simulated/floor/S = T
					if (S.air)
						air_str = json_encode(S.air.serialize())

				if (turfs > 0)
					query_string += ", "
				query_string += {"
				(
					[pos_x],[pos_y],[pos_z],
					'[data_str]',
					'[air_str]'
				)
				"}
				turfs += 1




	var/datum/db_query/save_turfs = SSdbcore.NewQuery(query_string)
	save_turfs.Execute()
	qdel(save_turfs)

	to_chat(world, "DB >> saved [turfs] turfs")

// world saving
proc/WorldSave(var/turf/start,var/turf/end)
	to_chat(world, "<font size=2 color='red'><b>### Admin [usr.key] started world sync to database... this may take some time ###</b></font>")
	sleep(1)
	var/objects = 0
	var/mobs = 0
	disable_safe_updates()
	sleep(1)

	for(var/obj/O in world)
		if (!O.synced || !isturf(O.loc))
			continue
		objects += 1

	to_chat(world, "DB >> saved [objects] objects")

	// save turfs
	//for(var/mob/living/carbon/human/H in GLOB.player_list)
	//	if (H.uid > 0)
			//db_delete_all("rs_character_inventory","character_uid = [H.uid]")
			/*
			for (var/obj/item/I in H.contents)
				var/list/data = I.serialize()
				var/json_dna = json_encode(data)
				var/datum/db_query/register_character = SSdbcore.NewQuery({"
				INSERT INTO rs_character_inventory(
						type,
						uid,
						slot,
						data)
					VALUES (
						'[I.type]',
						'[character.real_name]',
						'[character.real_name]',
						'[character.gender]',
						[character.age],
						'[eyes_organ.eye_color]',
						'[head_organ.hair_colour]',
						'[head_organ.facial_colour]',
						'[head_organ.h_style]',
						'[character.underwear]',
						'[character.socks]',
						'[json_dna]');
				"})
				register_character.Execute()
				character.uid = text2num(register_character.last_insert_id)
				qdel(register_character)
				to_chat(world, "will save [I.name] of [I.type] with [data.len] lines of data")
			*/