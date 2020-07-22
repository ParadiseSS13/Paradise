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

	establish_db_connection()

	if(!GLOB.dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT id FROM [format_table_name("admin")] WHERE ckey = '[adm_ckey]'")
	select_query.Execute()

	var/new_admin = 1
	var/admin_id
	while(select_query.NextRow())
		new_admin = 0
		admin_id = text2num(select_query.item[1])

	flag_account_for_forum_sync(adm_ckey)
	if(new_admin)
		var/DBQuery/insert_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("admin")] (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, '[adm_ckey]', '[new_rank]', -1, 0)")
		insert_query.Execute()
		var/DBQuery/log_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , '[usr.ckey]', '[usr.client.address]', 'Added new admin [adm_ckey] to rank [new_rank]');")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>New admin added.</span>")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/DBQuery/insert_query = GLOB.dbcon.NewQuery("UPDATE [format_table_name("admin")] SET rank = '[new_rank]' WHERE id = [admin_id]")
			insert_query.Execute()
			var/DBQuery/log_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , '[usr.ckey]', '[usr.client.address]', 'Edited the rank of [adm_ckey] to [new_rank]');")
			log_query.Execute()
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

	establish_db_connection()
	if(!GLOB.dbcon.IsConnected())
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

	var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT id, flags FROM [format_table_name("admin")] WHERE ckey = '[adm_ckey]'")
	select_query.Execute()

	var/admin_id
	var/admin_rights
	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])
		admin_rights = text2num(select_query.item[2])

	if(!admin_id)
		return

	flag_account_for_forum_sync(adm_ckey)
	if(admin_rights & new_permission) //This admin already has this permission, so we are removing it.
		var/DBQuery/insert_query = GLOB.dbcon.NewQuery("UPDATE [format_table_name("admin")] SET flags = [admin_rights & ~new_permission] WHERE id = [admin_id]")
		insert_query.Execute()
		var/DBQuery/log_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , '[usr.ckey]', '[usr.client.address]', 'Removed permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]');")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>Permission removed.</span>")
	else //This admin doesn't have this permission, so we are adding it.
		var/DBQuery/insert_query = GLOB.dbcon.NewQuery("UPDATE [format_table_name("admin")] SET flags = '[admin_rights | new_permission]' WHERE id = [admin_id]")
		insert_query.Execute()
		var/DBQuery/log_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , '[usr.ckey]', '[usr.client.address]', 'Added permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]')")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>Permission added.</span>")

/datum/admins/proc/updateranktodb(ckey,newrank)
	establish_db_connection()
	if(!GLOB.dbcon.IsConnected())
		return
	if(!check_rights(R_PERMISSIONS))
		return
	var/sql_ckey = sanitizeSQL(ckey)
	var/sql_admin_rank = sanitizeSQL(newrank)

	var/DBQuery/query_update = GLOB.dbcon.NewQuery("UPDATE [format_table_name("player")] SET lastadminrank = '[sql_admin_rank]' WHERE ckey = '[sql_ckey]'")
	query_update.Execute()
	flag_account_for_forum_sync(sql_ckey)
