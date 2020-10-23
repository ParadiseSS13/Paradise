/client/proc/admin_memo()
	set name = "Memo"
	set category = "Server"
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/memotask = input(usr,"Choose task.","Memo") in list("Show","Write","Edit","Remove")
	if(!memotask)
		return
	admin_memo_output(memotask)

/client/proc/admin_memo_output(task, checkrights = 1, silent = 0)
	if(checkrights && !check_rights(R_SERVER))
		return
	if(!task)
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	switch(task)
		if("Write")
			var/datum/db_query/query_memocheck = SSdbcore.NewQuery(
				"SELECT ckey FROM [format_table_name("memo")] WHERE ckey=:ckey",
				list("ckey" = ckey)
			)

			if(!query_memocheck.warn_execute())
				qdel(query_memocheck)
				return

			if(query_memocheck.NextRow())
				to_chat(src, "You already have set a memo.")
				qdel(query_memocheck)
				return

			qdel(query_memocheck)
			var/memotext = input(src, "Write your Memo", "Memo") as message
			if(!memotext)
				return

			var/datum/db_query/query_memoadd = SSdbcore.NewQuery(
				"INSERT INTO [format_table_name("memo")] (ckey, memotext, timestamp) VALUES (:ckey, :memotext, NOW())",
				list(
					"ckey" = ckey,
					"memotext" = memotext
				)
			)

			if(!query_memoadd.warn_execute())
				qdel(query_memoadd)
				return

			log_admin("[key_name(src)] has set a memo: [memotext]")
			message_admins("[key_name_admin(src)] has set a memo:<br>[memotext]")
			qdel(query_memoadd)

		if("Edit")
			var/datum/db_query/query_memolist = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("memo")]")

			if(!query_memolist.warn_execute())
				qdel(query_memolist)
				return

			var/list/memolist = list()
			while(query_memolist.NextRow())
				var/lkey = query_memolist.item[1]
				memolist += "[lkey]"

			qdel(query_memolist)
			if(!length(memolist))
				to_chat(src, "No memos found in database.")
				return

			var/target_ckey = input(src, "Select whose memo to edit", "Select memo") as null|anything in memolist
			if(!target_ckey)
				return

			var/datum/db_query/query_memofind = SSdbcore.NewQuery(
				"SELECT memotext FROM [format_table_name("memo")] WHERE ckey=:ckey",
				list("ckey" = target_ckey)
			)

			if(!query_memofind.warn_execute())
				qdel(query_memofind)
				return

			if(query_memofind.NextRow())
				var/old_memo = query_memofind.item[1]
				var/new_memo = input("Input new memo", "New Memo", "[old_memo]", null) as message
				if(!new_memo)
					qdel(query_memofind)
					return

				var/edit_text = "Edited by [target_ckey] on [SQLtime()] from<br>[old_memo]<br>to<br>[new_memo]<hr>"

				var/datum/db_query/update_query = SSdbcore.NewQuery(
					"UPDATE [format_table_name("memo")] SET memotext=:newmemo, last_editor=:lasteditor, edits=CONCAT(IFNULL(edits,''),:edittext) WHERE ckey=:targetckey",
					list(
						"newmemo" = new_memo,
						"lasteditor" = ckey,
						"edittext" = edit_text,
						"targetckey" = target_ckey
					)
				)

				if(!update_query.warn_execute())
					qdel(update_query)
					qdel(query_memofind)
					return

				if(target_ckey == ckey)
					log_admin("[key_name(src)] has edited their memo from \"[old_memo]\" to \"[new_memo]\"")
					message_admins("[key_name_admin(src)] has edited their memo from \"[old_memo]]\" to \"[new_memo]\"")
				else
					log_admin("[key_name(src)] has edited [target_ckey]'s memo from \"[old_memo]\" to \"[new_memo]\"")
					message_admins("[key_name_admin(src)] has edited [target_ckey]'s memo from \"[old_memo]\" to \"[new_memo]\"")
				qdel(update_query)
			qdel(query_memofind)

		if("Show")
			var/datum/db_query/query_memoshow = SSdbcore.NewQuery("SELECT ckey, memotext, timestamp, last_editor FROM [format_table_name("memo")]")
			if(!query_memoshow.warn_execute())
				qdel(query_memoshow)
				return
			var/output = {"<meta charset="UTF-8">"}
			while(query_memoshow.NextRow())
				var/ckey = query_memoshow.item[1]
				var/memotext = query_memoshow.item[2]
				var/timestamp = query_memoshow.item[3]
				var/last_editor = query_memoshow.item[4]
				output += "<span class='memo'>Memo by <span class='prefix'>[ckey]</span> on [timestamp]"
				if(last_editor)
					output += "<br><span class='memoedit'>Last edit by [last_editor] <A href='?_src_=holder;memoeditlist=[ckey]'>(Click here to see edit log)</A></span>"
				output += "<br>[memotext]</span><br>"
			if(output)
				to_chat(src, output)
			else if(!silent)
				to_chat(src, "No memos found in database.")
			qdel(query_memoshow)

		if("Remove")
			var/datum/db_query/query_memodellist = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("memo")]")
			if(!query_memodellist.warn_execute())
				qdel(query_memodellist)
				return

			var/list/memolist = list()
			while(query_memodellist.NextRow())
				var/ckey = query_memodellist.item[1]
				memolist += "[ckey]"

			qdel(query_memodellist)
			if(!memolist.len)
				to_chat(src, "No memos found in database.")
				return

			var/target_ckey = input(src, "Select whose memo to delete", "Select memo") as null|anything in memolist
			if(!target_ckey)
				return

			var/datum/db_query/query_memodel = SSdbcore.NewQuery(
				"DELETE FROM [format_table_name("memo")] WHERE ckey=:ckey",
				list("ckey" = target_ckey)
			)

			if(!query_memodel.warn_execute())
				qdel(query_memodel)
				return

			qdel(query_memodel)
			if(target_ckey == ckey)
				log_admin("[key_name(src)] has removed their memo.")
				message_admins("[key_name_admin(src)] has removed their memo.")
			else
				log_admin("[key_name(src)] has removed [target_ckey]'s memo.")
				message_admins("[key_name_admin(src)] has removed [target_ckey]'s memo.")
