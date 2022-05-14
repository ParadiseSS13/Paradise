/datum/client_login_processor/cuis
	priority = 45

/datum/client_login_processor/cuis/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT cuiRealName, cuiPath, cuiItemName, cuiDescription, cuiJobMask FROM customuseritems WHERE cuiCKey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/cuis/process_result(datum/db_query/Q, client/C)
	while(Q.NextRow())
		var/datum/custom_user_item/cui = new()
		cui.characer_name = Q.item[1]
		cui.object_typepath = text2path(Q.item[2])
		cui.item_name_override = Q.item[3]
		cui.item_desc_override = Q.item[4]
		cui.raw_job_mask = Q.item[5]

		if(cui.parse_info(C.ckey))
			C.cui_entries += cui
