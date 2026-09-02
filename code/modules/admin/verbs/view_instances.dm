USER_VERB(view_server_instances, R_ADMIN, "View Server Instances", "View the running server instances", VERB_CATEGORY_SERVER)
	to_chat(client, "<b>Server instances info</b>")
	var/datum/db_query/dbq1 = SSdbcore.NewQuery({"
		SELECT server_id, key_name, key_value FROM instance_data_cache WHERE server_id IN
		(SELECT server_id FROM instance_data_cache WHERE
		key_name='heartbeat' AND last_updated BETWEEN NOW() - INTERVAL 60 SECOND AND NOW())
		AND key_name IN ("playercount")"})
	if(!dbq1.warn_execute())
		qdel(dbq1)
		return

	var/servers_outer = list()
	while(dbq1.NextRow())
		if(!servers_outer[dbq1.item[1]])
			servers_outer[dbq1.item[1]] = list()

		servers_outer[dbq1.item[1]][dbq1.item[2]] = dbq1.item[3] // This should assoc load our data

	qdel(dbq1)

	for(var/server in servers_outer)
		var/server_data = servers_outer[server]
		var/players = text2num(server_data["playercount"])

		to_chat(client, "<code>[server]</code> - [players] player[players == 1 ? "" : "s"] online.")
	to_chat(client, "<i>Offline instances are not reported</i>")
