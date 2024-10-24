/client/proc/watchlist_add(target_ckey, browse = 0)
	if(!check_rights(R_ADMIN))
		return
	if(!target_ckey)
		var/new_ckey = ckey(clean_input("Who would you like to add to the watchlist?","Enter a ckey",null))
		if(!new_ckey)
			return
		var/datum/db_query/query_watchfind = SSdbcore.NewQuery("SELECT ckey FROM player WHERE ckey=:new_ckey", list(
			"new_ckey" = new_ckey
		))
		if(!query_watchfind.warn_execute())
			qdel(query_watchfind)
			return
		if(!query_watchfind.NextRow())
			to_chat(usr, "<span class='redtext'>[new_ckey] has not been seen before, you can only add known players.</span>")
			qdel(query_watchfind)
			return
		else
			qdel(query_watchfind)
			target_ckey = new_ckey

	var/already_watched = FALSE
	var/datum/db_query/query_watch = SSdbcore.NewQuery("SELECT reason FROM watch WHERE ckey=:target_ckey", list(
		"target_ckey" = target_ckey
	))
	if(!query_watch.warn_execute())
		qdel(query_watch)
		return
	if(query_watch.NextRow())
		already_watched = TRUE
	qdel(query_watch)

	if(already_watched)
		to_chat(usr, "<span class='redtext'>[target_ckey] is already on the watchlist.</span>")
		return
	var/reason = input(usr,"Please state the reason","Reason") as message|null
	if(!reason)
		return
	var/adminckey = usr.ckey
	if(!adminckey)
		return
	var/datum/db_query/query_watchadd = SSdbcore.NewQuery({"
		INSERT INTO watch (ckey, reason, adminckey, timestamp)
		VALUES (:targetkey, :reason, :adminkey, NOW())"},
		list(
			"targetkey" = target_ckey,
			"reason" = reason,
			"adminkey" = adminckey
		)
	)
	if(!query_watchadd.Execute())
		var/err = query_watchadd.ErrorMsg()
		log_game("SQL ERROR during adding new watch entry. Error : \[[err]\]\n")
		return
	log_admin("[key_name(usr)] has added [target_ckey] to the watchlist - Reason: [reason]")
	message_admins("[key_name_admin(usr)] has added [target_ckey] to the watchlist - Reason: [reason]", 1)
	if(GLOB.directory[target_ckey])
		var/client/C = GLOB.directory[target_ckey]
		C.watchlisted = TRUE // Mark them ingame now
	if(browse)
		watchlist_show(target_ckey)

/client/proc/watchlist_remove(target_ckey, browse = 0)
	if(!check_rights(R_ADMIN))
		return
	var/datum/db_query/query_watchdel = SSdbcore.NewQuery("DELETE FROM watch WHERE ckey=:target_ckey", list(
		"target_ckey" = target_ckey
	))
	if(!query_watchdel.warn_execute())
		qdel(query_watchdel)
		return
	qdel(query_watchdel)
	log_admin("[key_name(usr)] has removed [target_ckey] from the watchlist")
	message_admins("[key_name_admin(usr)] has removed [target_ckey] from the watchlist", 1)
	if(GLOB.directory[target_ckey])
		var/client/C = GLOB.directory[target_ckey]
		C.watchlisted = FALSE // Mark them ingame now
	if(browse)
		watchlist_show()

/client/proc/watchlist_edit(target_ckey, browse = 0)
	if(!check_rights(R_ADMIN))
		return
	var/datum/db_query/query_watchreason = SSdbcore.NewQuery("SELECT reason FROM watch WHERE ckey=:target_ckey", list(
		"target_ckey" = target_ckey
	))
	if(!query_watchreason.warn_execute())
		qdel(query_watchreason)
		return
	if(query_watchreason.NextRow())
		var/watch_reason = query_watchreason.item[1]
		var/new_reason = input("Input the new reason", "New Reason", "[watch_reason]") as message|null
		if(!new_reason || new_reason == watch_reason)
			return
		var/sql_ckey = usr.ckey
		var/edit_text = "Edited by [sql_ckey] on [SQLtime()] from \"[watch_reason]\" to \"[new_reason]\""

		var/datum/db_query/query_watchupdate = SSdbcore.NewQuery("UPDATE watch SET reason=:new_reason, last_editor=:sql_ckey, edits = CONCAT(IFNULL(edits,''), :edit_text) WHERE ckey=:target_ckey", list(
			"new_reason" = new_reason,
			"sql_ckey" = sql_ckey,
			"edit_text" = edit_text,
			"target_ckey" = target_ckey
		))
		if(!query_watchupdate.warn_execute())
			qdel(query_watchupdate)
			qdel(query_watchreason)
			return
		qdel(query_watchupdate)
		log_admin("[key_name(usr)] has edited [target_ckey]'s watchlist reason from \"[watch_reason]\" to \"[new_reason]\"")
		message_admins("[key_name_admin(usr)] has edited [target_ckey]'s watchlist reason from \"[watch_reason]\" to \"[new_reason]\"")
		if(browse)
			watchlist_show(target_ckey)
	qdel(query_watchreason)

/client/proc/watchlist_show(search)
	if(!check_rights(R_ADMIN))
		return
	var/output
	output += "<!DOCTYPE html><meta charset='UTF-8'><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='watchsearch' value='[search]'>\
	<input type='submit' value='Search'></form>"
	output += "<a href='byond://?_src_=holder;watchshow=1'>\[Clear Search\]</a> <a href='byond://?_src_=holder;watchaddbrowse=1'>\[Add Ckey\]</a>"
	output += "<hr style='background:#000000; border:0; height:3px'>"
	if(search)
		search = "^[search]"
	else
		search = "^."

	var/datum/db_query/query_watchlist = SSdbcore.NewQuery("SELECT ckey, reason, adminckey, timestamp, last_editor FROM watch WHERE ckey REGEXP :search ORDER BY ckey", list(
		"search" = search
	))
	if(!query_watchlist.warn_execute())
		qdel(query_watchlist)
		return
	while(query_watchlist.NextRow())
		var/ckey = query_watchlist.item[1]
		var/reason = query_watchlist.item[2]
		var/adminckey = query_watchlist.item[3]
		var/timestamp = query_watchlist.item[4]
		var/last_editor = query_watchlist.item[5]
		output += "<b>[ckey]</b> | Added by <b>[adminckey]</b> on <b>[timestamp]</b> <a href='byond://?_src_=holder;watchremovebrowse=[ckey]'>\[Remove\]</a> <a href='byond://?_src_=holder;watcheditbrowse=[ckey]'>\[Edit Reason\]</a>"
		if(last_editor)
			output += " <font size='2'>Last edit by [last_editor] <a href='byond://?_src_=holder;watcheditlog=[ckey]'>(Click here to see edit log)</a></font>"
		output += "<br>[reason]<hr style='background:#000000; border:0; height:1px'>"
	usr << browse(output, "window=watchwin;size=900x500")
	qdel(query_watchlist)
