/client/proc/edit_admin_permissions()
	set category = "Admin"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions"
	if(!check_rights(R_PERMISSIONS))
		return
	usr.client.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!check_rights(R_PERMISSIONS))
		return

	var/output = {"<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<head>
<title>Permissions Panel</title>
<script type='text/javascript' src="search.js"></script>
<link rel='stylesheet' type='text/css' href="panels.css">
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:125px;text-align:right;'>CKEY <a class='small' href='?src=[UID()];editrights=add'>\[+\]</a></th>
<th style='width:125px;'>RANK</th><th style='width:100%;'>PERMISSIONS</th>
</tr>
"}

	for(var/adm_ckey in GLOB.admin_datums)
		var/datum/admins/D = GLOB.admin_datums[adm_ckey]
		if(!D)	continue
		var/rank = D.rank ? D.rank : "*none*"
		var/rights = rights2text(D.rights," ")
		if(!rights)	rights = "*none*"
		output += {"<tr>
<td style='text-align:right;'>[adm_ckey] <a class='small' href='?src=[UID()];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>
<td><a href='?src=[UID()];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>
<td><a class='small' href='?src=[UID()];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></font></td>
</tr>"}

		/*output += "<tr>"
		output += "<td style='text-align:right;'>[adm_ckey] <a class='small' href='?src=[UID()];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>"
		output += "<td><a href='?src=[UID()];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>"
		output += "<td><a class='small' href='?src=[UID()];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></font></td>"
		output += "</tr>"*/

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=editrights;size=600x500")

/datum/admins/proc/log_admin_rank_modification(var/adm_ckey, var/new_rank)
	if(config.admin_legacy_system)	return

	if(!usr.client)
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT id FROM [format_table_name("admin")] WHERE ckey=:adm_ckey", list(
		"adm_ckey" = adm_ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/new_admin = TRUE
	var/admin_id
	while(select_query.NextRow())
		new_admin = FALSE
		admin_id = text2num(select_query.item[1])
	qdel(select_query)
	flag_account_for_forum_sync(adm_ckey)
	if(new_admin)
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin")] (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, :adm_ckey, :new_rank, -1, 0)", list(
			"adm_ckey" = adm_ckey,
			"new_rank" = new_rank
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)

		var/logtxt = "Added new admin [adm_ckey] to rank [new_rank]"
		var/datum/db_query/log_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , :uckey, :uip, :logtxt)", list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
		if(!log_query.warn_execute())
			qdel(log_query)
			return
		qdel(log_query)

		to_chat(usr, "<span class='notice'>New admin added.</span>")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET rank=:new_rank WHERE id=:admin_id", list(
				"new_rank" = new_rank,
				"admin_id" = admin_id,
			))
			if(!insert_query.warn_execute())
				qdel(insert_query)
				return
			qdel(insert_query)

			var/logtxt = "Edited the rank of [adm_ckey] to [new_rank]"
			var/datum/db_query/log_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , :uckey, :uip, :logtxt)", list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt,
			))
			if(!log_query.warn_execute())
				qdel(log_query)
				return
			qdel(log_query)
			to_chat(usr, "<span class='notice'>Admin rank changed.</span>")

/datum/admins/proc/log_admin_permission_modification(var/adm_ckey, var/new_permission)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounce'>Admin edit blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to edit admin ranks via advanced proc-call")
		log_admin("[key_name(usr)] attempted to edit admin ranks via advanced proc-call")
		return
	if(config.admin_legacy_system)
		return

	if(!usr.client)
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	if(!adm_ckey || !new_permission)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(istext(new_permission))
		new_permission = text2num(new_permission)

	if(!istext(adm_ckey) || !isnum(new_permission))
		return

	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT id, flags FROM [format_table_name("admin")] WHERE ckey=:adm_ckey", list(
		"adm_ckey" = adm_ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/admin_id
	var/admin_rights
	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])
		admin_rights = text2num(select_query.item[2])

	qdel(select_query)
	if(!admin_id)
		return

	flag_account_for_forum_sync(adm_ckey)
	if(admin_rights & new_permission) //This admin already has this permission, so we are removing it.
		var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET flags=:newflags WHERE id=:admin_id", list(
			"newflags" = (admin_rights & ~new_permission),
			"admin_id" = admin_id
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)

		var/logtxt = "Removed permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]"
		var/datum/db_query/log_query = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))
		if(!log_query.warn_execute())
			qdel(log_query)
			return
		qdel(log_query)
		to_chat(usr, "<span class='notice'>Permission removed.</span>")
	else //This admin doesn't have this permission, so we are adding it.
		var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET flags=:newflags WHERE id=:admin_id", list(
			"newflags" = (admin_rights | new_permission),
			"admin_id" = admin_id
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)

		var/logtxt = "Added permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]"
		var/datum/db_query/log_query = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))

		if(!log_query.warn_execute())
			qdel(log_query)
			return
		qdel(log_query)
		to_chat(usr, "<span class='notice'>Permission added.</span>")

/datum/admins/proc/updateranktodb(ckey,newrank)
	if(!SSdbcore.IsConnected())
		return
	if(!check_rights(R_PERMISSIONS))
		return

	var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET lastadminrank=:admin_rank WHERE ckey=:ckey", list(
		"admin_rank" = newrank,
		"ckey" = ckey
	))
	if(!query_update.warn_execute())
		qdel(query_update)
		return

	qdel(query_update)
	flag_account_for_forum_sync(ckey)
