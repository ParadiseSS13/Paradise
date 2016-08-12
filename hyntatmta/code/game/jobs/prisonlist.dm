var/list/bwhitelist
/client/proc/bwhitelist_panel_open()
	set name = "Whitelist Panel"
	set desc = "Edit Player Whitelist"
	set category = "Admin"

	if(!holder)
		return

	holder.bwhitelist_panel()

/datum/admins/proc/bwhitelist_panel(var/ckeyname = null)
	if(!usr.client)
		return

	if(!check_rights(R_PERMISSIONS))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Failed to establish database connection")
		return

	var/output = "<div align='center'><table width='90%'><tr>"

	ckeyname = ckey(ckeyname) //Just in case

	output += {"<td width='35%' align='center'><h1>Whitelist</h1></td>
		<td width='65%' align='center' bgcolor='#f9f9f9'>
		<form method='GET' action='?src=\ref[src]'>
		<input type='hidden' name='src' value='\ref[src]'>
		<table width='100%'><tr>
		<td><b>Ckey:</b> <input type='text' name='ckeyname'></td>
		<td><input type='submit' name='addtowhitelist' value='Add to Whitelist'></td>
		</form>
		</tr>
		</td>
		</table>
		<form method='GET' action='?src=\ref[src]'><b>Search</b>
		<input type='hidden' name='src' value='\ref[src]'>
		<b>Ckey:</b> <input type='text' name='whitelistsearchckey' value='[ckeyname]'>
		<input type='submit' value='search'>
		</form>"}

	var/DBQuery/select_query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("bwhitelist")] ORDER BY ckey ASC")
	select_query.Execute()

	output += {"<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0' align='center'>
			<tr>
			<th width='60%'><b>CKEY</b></th>
			<th width='40%'><b>OPTIONS</b></th>
			</tr>"}

	while(select_query.NextRow())
		var/ckey = select_query.item[1]
		output += {"<tr bgcolor='lightgrey'>
		<td align='center'><b>[ckey]</b></td>
		<td align='center'>["<b><a href=\"byond://?src=\ref[src];remove=[ckey];\">Remove</a></b>"]</td>
		</tr>"}

	if(ckeyname)
		output = "<div align='center'><table width='90%'><tr>"
		output += {"<td width='35%' align='center'><h1>Whitelist</h1></td>
		<td width='65%' align='center' bgcolor='#f9f9f9'>
		<form method='GET' action='?src=\ref[src]'>
		<input type='hidden' name='src' value='\ref[src]'>
		<table width='100%'><tr>
		<td><b>Ckey:</b> <input type='text' name='ckeyname'></td>
		<td><input type='submit' name='addtowhitelist' value='Add to Whitelist'></td>
		</form>
		</tr>
		</td>
		</table>
		<form method='GET' action='?src=\ref[src]'><b>Search</b>
		<input type='hidden' name='src' value='\ref[src]'>
		<b>Ckey:</b> <input type='text' name='whitelistsearchckey' value='[ckeyname]'>
		<input type='submit' value='search'>
		</form>"}
		output += {"<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0' align='center'>
				<tr>
				<th width='60%'><b>CKEY</b></th>
				<th width='40%'><b>OPTIONS</b></th>
				</tr>"}



		select_query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("bwhitelist")] WHERE ckey = '[ckeyname]' ORDER BY ckey ASC")
		select_query.Execute()

		while(select_query.NextRow())
			var/ckey = select_query.item[1]

			output += {"<tr bgcolor='lightgrey'>
				<td align='center'><b>[ckey]</b></td>
				<td align='center'>["<b><a href=\"byond://?src=\ref[src];remove=[ckeyname];\">Remove</a></b>"]</td>
				</tr>"}

	output += "</table></div>"

	usr << browse(output,"window=lookupbans;size=900x500")


/proc/check_prisonlist(var/K)
	var/noprison_key
	if(!dbcon.IsConnected())
		log_admin("Unable to connect to whitelist database. Please try again later.")
		return 1
	if(!config.prisonlist_enabled)
		log_admin("Whitelist disabled in config.")
		return 1
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("bwhitelist")] WHERE ckey='[K]'")
		query.Execute()
		while(query.NextRow())
			noprison_key = query.item[1]
		if(noprison_key == K)
			return 1
	return 0

/proc/load_bwhitelist()
	log_admin("Loading whitelist")
	bwhitelist = list()
	if(!dbcon.IsConnected())
		log_admin("Failed to load bwhitelist. Error: [dbcon.ErrorMsg()]")
		return
	var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("bwhitelist")] ORDER BY ckey ASC")
	query.Execute()
	while(query.NextRow())
		bwhitelist += "[query.item[1]]"
	if(bwhitelist==list(  ))
		log_admin("Failed to load bwhitelist or its empty")
		return
	dbcon.Disconnect()

/proc/bwhitelist_save(var/ckeyname)
	if(!bwhitelist)
		load_bwhitelist()
		if(!bwhitelist)
			return
	var/sql = "INSERT INTO [format_table_name("bwhitelist")] (`ckey`) VALUES ('[ckeyname]')"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	to_chat(usr, "\blue Ckey saved to database.")
	message_admins("[key_name_admin(usr)] has added [ckeyname] to the whitelist.",1)


/proc/bwhitelist_remove(var/ckeyname)
	if(!bwhitelist)
		load_bwhitelist()
		if(!bwhitelist)
			return
	var/sql = "DELETE FROM [format_table_name("bwhitelist")] WHERE ckey='[ckeyname]'"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	to_chat(usr, "\blue Ckey removed from database.")
	message_admins("[key_name_admin(usr)] has removed [ckeyname] from the whitelist.",1)
