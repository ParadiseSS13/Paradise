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

	var/datum/asset/permissions_asset = get_asset_datum(/datum/asset/simple/permissions)
	permissions_asset.send(usr)

	var/db_section = ""
	if(db_available())
		db_section = {"
<div id='db_notice'><b>Admin database active.<br>All data is pulled from the database, and may require an admin reload to match actual permissions.<br>Automatically-granted localhost admin permissions are not listed.</b><br><br></div>
<div id='rank_edit'><b><a href='byond://?src=[UID()];editrank=1'>Edit admin ranks</a></b></div>
		"}

	var/output = {"<!DOCTYPE html>
<html><meta charset='utf-8'>
<head>
<title>Permissions Panel</title>
<script type='text/javascript' src='[SSassets.transport.get_asset_url("search.js")]'></script>
<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url("panels.css")]'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='spacer'></div>
[db_section]
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:20%;text-align:right;'>CKEY <a class='small' href='byond://?src=[UID()];editrights=add'>\[+\]</a></th>
<th style='width:20%;'>RANK</th><th style='width:60%;'>PERMISSIONS</th>
</tr>
"}

	var/list/admin_details = list()
	if(GLOB.configuration.admin.use_database_admins)
		var/datum/db_query/get_admins = SSdbcore.NewQuery({"
			SELECT
				admin.ckey, 
				admin_ranks.name,
				admin.display_rank,
				IFNULL(admin_ranks.default_permissions, 0),
				admin.extra_permissions,
				admin.removed_permissions
			FROM admin
			-- We want all admins, and admin_ranks where available.
			LEFT OUTER JOIN admin_ranks
			ON admin.permissions_rank = admin_ranks.id
			ORDER BY admin_ranks.name ASC, admin.ckey ASC"})
		if(!get_admins.warn_execute())
			qdel(get_admins)
			return

		while(get_admins.NextRow())
			var/ckey = get_admins.item[1]
			var/rank = get_admins.item[2]
			var/display_rank = get_admins.item[3]
			var/rank_permissions = get_admins.item[4]
			var/extra_permissions = get_admins.item[5]
			var/removed_permissions = get_admins.item[6]

			if(!rank && !display_rank && !extra_permissions && !removed_permissions)
				// Former admin, no current rank or permissions. Don't bother showing them.
				continue

			var/listed_rank
			if(rank)
				listed_rank = rank
			else
				listed_rank = "*none*"
			if(display_rank)
				listed_rank = "[display_rank] ([rank])"
			var/display_rights = ranked_rights2text(rank_permissions, extra_permissions, removed_permissions," ")
			if(display_rights == "")
				display_rights = "*none*"
			admin_details += list(list(
				ckey,
				listed_rank,
				display_rights
			))
		qdel(get_admins)
	else
		var/list/sorted_ckeys = list()
		for(var/adm_ckey in GLOB.admin_datums)
			sorted_ckeys += adm_ckey
		sortTim(sorted_ckeys, cmp = GLOBAL_PROC_REF(cmp_text_asc))

		for(var/adm_ckey in sorted_ckeys)
			var/datum/admins/D = GLOB.admin_datums[adm_ckey]
			if(!D)
				continue
			var/rank = D.rank ? D.rank : "*none*"
			var/rights = rights2text(D.rights," ")
			if(!rights)
				rights = "*none*"
			admin_details += list(list(adm_ckey, rank, rights))

	for(var/list/details in admin_details)
		output += {"<tr>
<td style='text-align:right;'>[details[1]] <a class='small' href='byond://?src=[UID()];editrights=remove;ckey=[details[1]]'>\[-\]</a></td>
<td><a href='byond://?src=[UID()];editrights=rank;ckey=[details[1]]'>[details[2]]</a></td>
<td><a class='small' href='byond://?src=[UID()];editrights=permissions;ckey=[details[1]]'>[details[3]]</a></font></td>
</tr>"}

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=editrights;size=600x500")

/datum/admins/proc/db_available()
	if(!SSdbcore.IsConnected())
		return FALSE
	if(!GLOB.configuration.admin.use_database_admins)
		return FALSE
	return TRUE

/datum/admins/proc/can_edit_db()
	if(!check_rights(R_PERMISSIONS))
		return FALSE
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Admin edit blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to edit admin DB via advanced proc-call")
		log_admin("[key_name(usr)] attempted to edit admin DB via advanced proc-call")
		return FALSE
	if(!usr.client)
		return FALSE
	if(!db_available())
		to_chat(usr, "<span class='warning'>Admin database unavailable</span>")
		return FALSE
	return TRUE

/datum/admins/proc/set_db_rank(target_key, new_rank, display_rank = null, clear_custom_permissions = FALSE)
	if(!can_edit_db())
		return

	if(!istext(target_key))
		to_chat(usr, "<span class='warning'>Provided key '[target_key]' is not text!</span>")
		return

	target_key = ckey(target_key)
	if(target_key == "")
		to_chat(usr, "<span class='warning'>Provided key was blank after converting to ckey!</span>")
		return

	if(!isnum(new_rank))
		to_chat(usr, "<span class='warning'>Provided rank ID '[new_rank]' is not a number!</span>")
		return

	var/datum/db_query/get_rank_name = SSdbcore.NewQuery("SELECT name FROM admin_ranks WHERE id = :new_rank", list(
		"new_rank" = new_rank
	))
	if(!get_rank_name.warn_execute())
		qdel(get_rank_name)
		return
	var/rank_name
	if(get_rank_name.NextRow())
		rank_name = get_rank_name.item[1]
	qdel(get_rank_name)
	if(!rank_name)
		to_chat(usr, "<span class='warning'>Rank with ID [new_rank] not found in database!</span>")
		return

	var/datum/db_query/get_admin_id = SSdbcore.NewQuery("SELECT id FROM admin WHERE ckey = :target_key", list(
		"target_key" = target_key
	))
	if(!get_admin_id.warn_execute())
		qdel(get_admin_id)
		return

	var/display_note = ""
	if(display_rank)
		display_note = " with the custom rank title [display_rank]"

	var/new_admin = TRUE
	var/admin_id
	if(get_admin_id.NextRow())
		new_admin = FALSE
		admin_id = text2num(get_admin_id.item[1])
	qdel(get_admin_id)
	if(new_admin)
		var/datum/db_query/insert_new_admin = SSdbcore.NewQuery("INSERT INTO admin (`ckey`, `permissions_rank`, `display_rank`) VALUES (:target_key, :new_rank, :display_rank)", list(
			"target_key" = target_key,
			"new_rank" = new_rank,
			"display_rank" = display_rank
		))
		if(!insert_new_admin.warn_execute())
			qdel(insert_new_admin)
			return
		qdel(insert_new_admin)
		message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: [target_key] (NEW ADMIN) is now a [rank_name][display_note].</span>")

		var/logtxt = "Added new admin [target_key] to rank [rank_name][display_note]"
		var/datum/db_query/add_log = SSdbcore.NewQuery("INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , :uckey, :uip, :logtxt)", list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
		if(!add_log.warn_execute())
			qdel(add_log)
			return
		qdel(add_log)
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/datum/db_query/update_admin_rank = SSdbcore.NewQuery("UPDATE admin SET permissions_rank = :new_rank, display_rank = :display_rank WHERE id = :admin_id", list(
				"new_rank" = new_rank,
				"display_rank" = display_rank,
				"admin_id" = admin_id,
			))
			if(!update_admin_rank.warn_execute())
				qdel(update_admin_rank)
				return
			qdel(update_admin_rank)
			message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: [target_key] is now a [rank_name][display_note].</span>")
			var/logtxt = "Edited the rank of [target_key] to [rank_name][display_note]"

			if(clear_custom_permissions)
				var/datum/db_query/clear_permissions = SSdbcore.NewQuery("UPDATE admin SET extra_permissions = 0, removed_permissions = 0 WHERE id = :admin_id", list(
					"admin_id" = admin_id,
				))
				if(!clear_permissions.warn_execute())
					qdel(clear_permissions)
					return
				qdel(clear_permissions)
				logtxt += " and cleared their custom permissions"
				message_admins("<span class='notice'>Admin permissions updated by [usr.ckey]: [target_key] no longer has any custom permissions.</span>")

			var/datum/db_query/add_log = SSdbcore.NewQuery("INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , :uckey, :uip, :logtxt)", list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt,
			))
			if(!add_log.warn_execute())
				qdel(add_log)
				return
			qdel(add_log)

/datum/admins/proc/toggle_db_permission(target_key, permission_bit)
	if(!can_edit_db())
		return

	if(!istext(target_key))
		to_chat(usr, "<span class='warning'>Provided key '[target_key]' is not text!</span>")
		return

	target_key = ckey(target_key)
	if(target_key == "")
		to_chat(usr, "<span class='warning'>Provided key was blank after converting to ckey!</span>")
		return

	if(!isnum(permission_bit) || permission_bit < 1 || floor(permission_bit) != permission_bit)
		to_chat(usr, "<span class='warning'>Provided permission '[permission_bit]' is not positive whole number!</span>")
		return

	var/pow2 = round(log(2, permission_bit), 1)
	if((2 ** pow2) != permission_bit)
		to_chat(usr, "<span class='warning'>Provided permission '[permission_bit]' is not a power of two, and would affect multiple permission bits!</span>")
		return

	var/datum/db_query/get_admin_permissions = SSdbcore.NewQuery("SELECT admin.id, admin_ranks.default_permissions, admin.extra_permissions, admin.removed_permissions FROM admin LEFT OUTER JOIN admin_ranks ON admin.permissions_rank = admin_ranks.id WHERE ckey = :target_key", list(
		"target_key" = target_key
	))
	if(!get_admin_permissions.warn_execute())
		qdel(get_admin_permissions)
		return

	var/admin_id
	var/rank_permissions = 0
	var/extra_permissions = 0
	var/removed_permissions = 0
	if(get_admin_permissions.NextRow())
		admin_id = get_admin_permissions.item[1]
		// || 0 forces this to be numeric if they have no rank in the database.
		rank_permissions = get_admin_permissions.item[2] || 0
		extra_permissions = get_admin_permissions.item[3]
		removed_permissions = get_admin_permissions.item[4]

	qdel(get_admin_permissions)
	if(!admin_id)
		to_chat(usr, "<span class='warning'>No admin found with ckey [target_key]!</span>")
		return

	flag_account_for_forum_sync(target_key)

	if(removed_permissions & permission_bit)
		// They had an exception removing this permission bit, let them have it.
		var/datum/db_query/remove_removal = SSdbcore.NewQuery("UPDATE admin SET removed_permissions = removed_permissions & ~:permission_bit WHERE id = :admin_id", list(
			"permission_bit" = permission_bit,
			"admin_id" = admin_id
		))
		if(!remove_removal.warn_execute())
			qdel(remove_removal)
			return
		qdel(remove_removal)
		message_admins("<span class='notice'>Admin permissions updated by [usr.ckey]: [target_key] is no longer excluded from having [rights2text(permission_bit)].</span>")

		var/logtxt = "Un-excluded permission [rights2text(permission_bit)] (flag = [permission_bit]) from admin [target_key]"
		var/datum/db_query/create_log = SSdbcore.NewQuery({"
			INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))
		create_log.warn_execute()
		qdel(create_log)
		return

	if(extra_permissions & permission_bit)
		// They had an exception adding this permission bit, remove it.
		var/datum/db_query/remove_extra = SSdbcore.NewQuery("UPDATE admin SET extra_permissions = extra_permissions & ~:permission_bit WHERE id = :admin_id", list(
			"permission_bit" = permission_bit,
			"admin_id" = admin_id
		))
		if(!remove_extra.warn_execute())
			qdel(remove_extra)
			return
		qdel(remove_extra)
		message_admins("<span class='notice'>Admin permissions updated by [usr.ckey]: [target_key] no longer has the extra permission [rights2text(permission_bit)].</span>")

		var/logtxt = "Removed extra permission [rights2text(permission_bit)] (flag = [permission_bit]) from admin [target_key]"
		var/datum/db_query/create_log = SSdbcore.NewQuery({"
			INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))
		create_log.warn_execute()
		qdel(create_log)
		return

	if(rank_permissions & permission_bit)
		// They have this permission from their rank, and an exception removing it.
		var/datum/db_query/create_removal = SSdbcore.NewQuery("UPDATE admin SET removed_permissions = removed_permissions | :permission_bit WHERE id = :admin_id", list(
			"permission_bit" = permission_bit,
			"admin_id" = admin_id
		))
		if(!create_removal.warn_execute())
			qdel(create_removal)
			return
		qdel(create_removal)
		message_admins("<span class='notice'>Admin permissions updated by [usr.ckey]: [target_key] is now excluded from having [rights2text(permission_bit)].</span>")

		var/logtxt = "Excluded permission [rights2text(permission_bit)] (flag = [permission_bit]) from admin [target_key]"
		var/datum/db_query/create_log = SSdbcore.NewQuery({"
			INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))
		create_log.warn_execute()
		qdel(create_log)
		return

	// They did not have this permission from their rank, add an exception granting it.
	var/datum/db_query/add_extra = SSdbcore.NewQuery("UPDATE admin SET extra_permissions = extra_permissions | :permission_bit WHERE id = :admin_id", list(
		"permission_bit" = permission_bit,
		"admin_id" = admin_id
	))
	if(!add_extra.warn_execute())
		qdel(add_extra)
		return
	qdel(add_extra)
	message_admins("<span class='notice'>Admin permissions updated by [usr.ckey]: [target_key] has been granted the extra permission [rights2text(permission_bit)].</span>")

	var/logtxt = "Added extra permission [rights2text(permission_bit)] (flag = [permission_bit]) to admin [target_key]"
	var/datum/db_query/create_log = SSdbcore.NewQuery({"
		INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
		VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
	create_log.warn_execute()
	qdel(create_log)

/datum/admins/proc/remove_db_admin(target_key, clear_custom_permissions = TRUE)
	if(!can_edit_db())
		return

	if(!istext(target_key))
		to_chat(usr, "<span class='warning'>Provided key '[target_key]' is not text!</span>")
		return

	target_key = ckey(target_key)
	if(target_key == "")
		to_chat(usr, "<span class='warning'>Provided key was blank after converting to ckey!</span>")
		return

	var/datum/db_query/get_admin_id = SSdbcore.NewQuery("SELECT admin.id FROM admin WHERE ckey = :target_key", list(
		"target_key" = target_key
	))
	if(!get_admin_id.warn_execute())
		qdel(get_admin_id)
		return

	var/admin_id
	if(get_admin_id.NextRow())
		admin_id = get_admin_id.item[1]
	qdel(get_admin_id)

	if(!admin_id)
		to_chat(usr, "<span class='warning'>No admin found with ckey [target_key]!</span>")
		return

	flag_account_for_forum_sync(target_key)

	var/datum/db_query/remove_admin = SSdbcore.NewQuery("UPDATE admin SET permissions_rank = NULL, display_rank = NULL WHERE id = :admin_id", list(
		"admin_id" = admin_id,
	))
	if(!remove_admin.warn_execute())
		qdel(remove_admin)
		return
	qdel(remove_admin)
	message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: [target_key] no longer has any admin rank.</span>")
	var/logtxt = "Removed the admin rank of [target_key]"

	if(clear_custom_permissions)
		var/datum/db_query/clear_permissions = SSdbcore.NewQuery("UPDATE admin SET extra_permissions = 0, removed_permissions = 0 WHERE id = :admin_id", list(
			"admin_id" = admin_id,
		))
		if(!clear_permissions.warn_execute())
			qdel(clear_permissions)
			return
		qdel(clear_permissions)
		message_admins("<span class='notice'>Admin permissions updated by [usr.ckey]: [target_key] no longer has any custom permissions.</span>")
		logtxt += " and cleared their custom permissions"

	var/datum/db_query/create_log = SSdbcore.NewQuery({"
		INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
		VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
	create_log.warn_execute()
	qdel(create_log)

/datum/admins/proc/create_db_rank(rank_name)
	if(!can_edit_db())
		return

	if(get_db_rank_id(rank_name))
		// We already have it.
		return

	var/datum/db_query/add_rank = SSdbcore.NewQuery("INSERT INTO admin_ranks SET name = :rank_name", list(
		"rank_name" = rank_name
	))
	add_rank.warn_execute()
	qdel(add_rank)

	message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: new rank [rank_name] created.</span>")
	var/logtxt = "Created the admin rank [rank_name]"
	var/datum/db_query/create_log = SSdbcore.NewQuery({"
		INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
		VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
	create_log.warn_execute()
	qdel(create_log)
	return get_db_rank_id(rank_name)

/datum/admins/proc/delete_db_rank(rank_name)
	if(!can_edit_db())
		return

	var/rank_id = get_db_rank_id(rank_name)
	if(!rank_id)
		to_chat(usr, "<span class='warning'>No rank named [rank_name] found!</span>")
		return

	var/datum/db_query/get_admins_with_rank = SSdbcore.NewQuery("SELECT ckey FROM admin WHERE permissions_rank = :rank_id", list(
		"rank_id" = rank_id
	))
	if(!get_admins_with_rank.warn_execute())
		qdel(get_admins_with_rank)
		return
	var/list/admins = list()
	while(get_admins_with_rank.NextRow())
		admins += get_admins_with_rank.item[1]
	qdel(get_admins_with_rank)
	if(length(admins) > 0)
		to_chat(usr, "<span class='warning'>[rank_name] is still in use, reassign the following admins first: [admins.Join(", ")]</span>")
		return

	var/datum/db_query/delete_rank = SSdbcore.NewQuery("DELETE FROM admin_ranks WHERE id = :rank_id", list(
		"rank_id" = rank_id
	))
	if(!delete_rank.warn_execute())
		qdel(delete_rank)
		return
	qdel(delete_rank)

	message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: unused rank [rank_name] deleted.</span>")
	var/logtxt = "Deleted the unused admin rank [rank_name]"
	var/datum/db_query/create_log = SSdbcore.NewQuery({"
		INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
		VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
	create_log.warn_execute()
	qdel(create_log)

/datum/admins/proc/toggle_db_rank_permission(rank_name, permission_bit)
	if(!can_edit_db())
		return

	var/datum/db_query/get_rank_details = SSdbcore.NewQuery("SELECT id, default_permissions FROM admin_ranks WHERE name = :rank_name", list(
		"rank_name" = rank_name
	))
	if(!get_rank_details.warn_execute())
		qdel(get_rank_details)
		return

	var/rank_id
	var/rank_permissions
	if(get_rank_details.NextRow())
		rank_id = get_rank_details.item[1]
		rank_permissions = get_rank_details.item[2]
	qdel(get_rank_details)
	if(!rank_id)
		to_chat(usr, "<span class='warning'>No rank named [rank_name] found!</span>")
		return

	if(!isnum(permission_bit) || permission_bit < 1 || floor(permission_bit) != permission_bit)
		to_chat(usr, "<span class='warning'>Provided permission '[permission_bit]' is not positive whole number!</span>")
		return

	var/pow2 = round(log(2, permission_bit), 1)
	if((2 ** pow2) != permission_bit)
		to_chat(usr, "<span class='warning'>Provided permission '[permission_bit]' is not a power of two, and would affect multiple permission bits!</span>")
		return

	if(rank_permissions & permission_bit)
		// Revoke the permission.
		var/datum/db_query/create_removal = SSdbcore.NewQuery("UPDATE admin_ranks SET default_permissions = default_permissions & ~:permission_bit WHERE id = :rank_id", list(
			"permission_bit" = permission_bit,
			"rank_id" = rank_id
		))
		if(!create_removal.warn_execute())
			qdel(create_removal)
			return
		qdel(create_removal)
		message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: [rank_name] no longer has [rights2text(permission_bit)]. An admin reload is required to apply this change.</span>")

		var/logtxt = "Removed permission [rights2text(permission_bit)] (flag = [permission_bit]) from admin rank [rank_name]"
		var/datum/db_query/create_log = SSdbcore.NewQuery({"
			INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))
		create_log.warn_execute()
		qdel(create_log)
		return

	// Grant the permission
	var/datum/db_query/grant_permission = SSdbcore.NewQuery("UPDATE admin_ranks SET default_permissions = default_permissions | :permission_bit WHERE id = :rank_id", list(
		"permission_bit" = permission_bit,
		"rank_id" = rank_id
	))
	if(!grant_permission.warn_execute())
		qdel(grant_permission)
		return
	qdel(grant_permission)
	message_admins("<span class='notice'>Admin ranks updated by [usr.ckey]: [rank_name] has been given [rights2text(permission_bit)]. An admin reload is required to apply this change.</span>")

	var/logtxt = "Added permission [rights2text(permission_bit)] (flag = [permission_bit]) to admin rank [rank_name]"
	var/datum/db_query/create_log = SSdbcore.NewQuery({"
		INSERT INTO admin_log (`datetime` ,`adminckey` ,`adminip` ,`log`)
		VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
	create_log.warn_execute()
	qdel(create_log)

/datum/admins/proc/get_db_ranks()
	if(!db_available())
		return
	var/datum/db_query/get_ranks = SSdbcore.NewQuery("SELECT name FROM admin_ranks")
	if(!get_ranks.warn_execute())
		qdel(get_ranks)
		CRASH("Unable to get admin ranks from database.")

	var/list/ranks = list()
	while(get_ranks.NextRow())
		ranks += get_ranks.item[1]
	qdel(get_ranks)

	return ranks

/datum/admins/proc/get_db_rank_id(rank_name)
	if(!db_available())
		return
	var/datum/db_query/get_rank_id = SSdbcore.NewQuery("SELECT id FROM admin_ranks WHERE name = :rank_name", list(
		"rank_name" = rank_name
	))
	if(!get_rank_id.warn_execute())
		qdel(get_rank_id)
		return

	var/rank_id
	if(get_rank_id.NextRow())
		rank_id = get_rank_id.item[1]
	qdel(get_rank_id)
	return rank_id

/datum/admins/proc/get_db_rank_permissions(rank_name)
	if(!db_available())
		return
	var/datum/db_query/get_rank_permissions = SSdbcore.NewQuery("SELECT default_permissions FROM admin_ranks WHERE name = :rank_name", list(
		"rank_name" = rank_name
	))
	if(!get_rank_permissions.warn_execute())
		qdel(get_rank_permissions)
		return

	var/rank_permissions
	if(get_rank_permissions.NextRow())
		rank_permissions = get_rank_permissions.item[1]
	qdel(get_rank_permissions)
	return rank_permissions
