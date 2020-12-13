/proc/add_note(target_ckey, notetext, timestamp, adminckey, logged = 1, server, checkrights = 1)
	if(checkrights && !check_rights(R_ADMIN|R_MOD))
		return
	if(!GLOB.dbcon.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return

	if(!target_ckey)
		var/new_ckey = ckey(clean_input("Who would you like to add a note for?","Enter a ckey",null))
		if(!new_ckey)
			return
		target_ckey = ckey(new_ckey)
	else
		target_ckey = ckey(target_ckey)

	var/DBQuery/query_find_ckey = GLOB.dbcon.NewQuery("SELECT ckey, exp FROM [format_table_name("player")] WHERE ckey = '[target_ckey]'")
	if(!query_find_ckey.Execute())
		var/err = query_find_ckey.ErrorMsg()
		log_game("SQL ERROR obtaining ckey from player table. Error : \[[err]\]\n")
		return
	if(!query_find_ckey.NextRow())
		if(usr)
			to_chat(usr, "<span class='redtext'>[target_ckey] has not been seen before, you can only add notes to known players.</span>")
		return

	var/exp_data = query_find_ckey.item[2]
	var/crew_number = 0
	if(exp_data)
		var/list/play_records = params2list(exp_data)
		crew_number = play_records[EXP_TYPE_CREW]

	if(!notetext)
		notetext = input(usr,"Write your note","Add Note") as message|null
		if(!notetext)
			return
	notetext = sanitizeSQL(notetext)
	if(!timestamp)
		timestamp = SQLtime()
	if(!adminckey)
		adminckey = usr.ckey
		if(!adminckey)
			return
	else if(usr && (usr.ckey == ckey(adminckey))) // Don't ckeyize special note sources
		adminckey = ckey(adminckey)
	var/admin_sql_ckey = sanitizeSQL(adminckey)
	if(!server)
		if(config && config.server_name)
			server = config.server_name
	server = sanitizeSQL(server)
	var/DBQuery/query_noteadd = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("notes")] (ckey, timestamp, notetext, adminckey, server, crew_playtime) VALUES ('[target_ckey]', '[timestamp]', '[notetext]', '[admin_sql_ckey]', '[server]', '[crew_number]')")
	if(!query_noteadd.Execute())
		var/err = query_noteadd.ErrorMsg()
		log_game("SQL ERROR adding new note to table. Error : \[[err]\]\n")
		return
	if(logged)
		log_admin("[usr ? key_name(usr) : adminckey] has added a note to [target_ckey]: [notetext]")
		message_admins("[usr ? key_name_admin(usr) : adminckey] has added a note to [target_ckey]:<br>[notetext]")
		show_note(target_ckey)

/proc/remove_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/ckey
	var/notetext
	var/adminckey
	if(!GLOB.dbcon.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/DBQuery/query_find_note_del = GLOB.dbcon.NewQuery("SELECT ckey, notetext, adminckey FROM [format_table_name("notes")] WHERE id = [note_id]")
	if(!query_find_note_del.Execute())
		var/err = query_find_note_del.ErrorMsg()
		log_game("SQL ERROR obtaining ckey, notetext, adminckey from player table. Error : \[[err]\]\n")
		return
	if(query_find_note_del.NextRow())
		ckey = query_find_note_del.item[1]
		notetext = query_find_note_del.item[2]
		adminckey = query_find_note_del.item[3]
	var/DBQuery/query_del_note = GLOB.dbcon.NewQuery("DELETE FROM [format_table_name("notes")] WHERE id = [note_id]")
	if(!query_del_note.Execute())
		var/err = query_del_note.ErrorMsg()
		log_game("SQL ERROR removing note from table. Error : \[[err]\]\n")
		return
	log_admin("[usr ? key_name(usr) : "Bot"] has removed a note made by [adminckey] from [ckey]: [notetext]")
	message_admins("[usr ? key_name_admin(usr) : "Bot"] has removed a note made by [adminckey] from [ckey]:<br>[notetext]")
	show_note(ckey)

/proc/edit_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	if(!GLOB.dbcon.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/target_ckey
	var/sql_ckey = usr.ckey
	var/DBQuery/query_find_note_edit = GLOB.dbcon.NewQuery("SELECT ckey, notetext, adminckey FROM [format_table_name("notes")] WHERE id = [note_id]")
	if(!query_find_note_edit.Execute())
		var/err = query_find_note_edit.ErrorMsg()
		log_game("SQL ERROR obtaining notetext from notes table. Error : \[[err]\]\n")
		return
	if(query_find_note_edit.NextRow())
		target_ckey = query_find_note_edit.item[1]
		var/old_note = query_find_note_edit.item[2]
		var/adminckey = query_find_note_edit.item[3]
		var/new_note = input("Input new note", "New Note", "[old_note]") as message|null
		if(!new_note)
			return
		new_note = sanitizeSQL(new_note)
		var/edit_text = "Edited by [sql_ckey] on [SQLtime()] from \"[old_note]\" to \"[new_note]\"<hr>"
		edit_text = sanitizeSQL(edit_text)
		var/DBQuery/query_update_note = GLOB.dbcon.NewQuery("UPDATE [format_table_name("notes")] SET notetext = '[new_note]', last_editor = '[sql_ckey]', edits = CONCAT(IFNULL(edits,''),'[edit_text]') WHERE id = [note_id]")
		if(!query_update_note.Execute())
			var/err = query_update_note.ErrorMsg()
			log_game("SQL ERROR editing note. Error : \[[err]\]\n")
			return
		log_admin("[usr ? key_name(usr) : "Bot"] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[new_note]\"")
		message_admins("[usr ? key_name_admin(usr) : "Bot"] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[new_note]\"")
		show_note(target_ckey)

/proc/show_note(target_ckey, index, linkless = 0)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/output
	var/navbar
	var/ruler
	ruler = "<hr style='background:#000000; border:0; height:3px'>"
	navbar = "<a href='?_src_=holder;nonalpha=1'>\[All\]</a>|<a href='?_src_=holder;nonalpha=2'>\[#\]</a>"
	for(var/letter in GLOB.alphabet)
		navbar += "|<a href='?_src_=holder;shownote=[letter]'>\[[letter]\]</a>"
	navbar += "<br><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='notessearch' value='[index]'>\
	<input type='submit' value='Search'></form>"
	if(!linkless)
		output = navbar
	if(target_ckey)
		var/target_sql_ckey = ckey(target_ckey)
		var/DBQuery/query_get_notes = GLOB.dbcon.NewQuery("SELECT id, timestamp, notetext, adminckey, last_editor, server, crew_playtime FROM [format_table_name("notes")] WHERE ckey = '[target_sql_ckey]' ORDER BY timestamp")
		if(!query_get_notes.Execute())
			var/err = query_get_notes.ErrorMsg()
			log_game("SQL ERROR obtaining ckey, notetext, adminckey, last_editor, server, crew_playtime from notes table. Error : \[[err]\]\n")
			return
		output += "<h2><center>Notes of [target_ckey]</center></h2>"
		if(!linkless)
			output += "<center><a href='?_src_=holder;addnote=[target_ckey]'>\[Add Note\]</a></center>"
		output += ruler
		while(query_get_notes.NextRow())
			var/id = query_get_notes.item[1]
			var/timestamp = query_get_notes.item[2]
			var/notetext = query_get_notes.item[3]
			var/adminckey = query_get_notes.item[4]
			var/last_editor = query_get_notes.item[5]
			var/server = query_get_notes.item[6]
			var/mins = text2num(query_get_notes.item[7])
			output += "<b>[timestamp] | [server] | [adminckey]"
			if(mins)
				var/playstring = get_exp_format(mins)
				output += " | [playstring] as Crew"
			output += "</b>"

			if(!linkless)
				output += " <a href='?_src_=holder;removenote=[id]'>\[Remove Note\]</a> <a href='?_src_=holder;editnote=[id]'>\[Edit Note\]</a>"
				if(last_editor)
					output += " <font size='2'>Last edit by [last_editor] <a href='?_src_=holder;noteedits=[id]'>(Click here to see edit log)</a></font>"
			output += "<br>[notetext]<hr style='background:#000000; border:0; height:1px'>"
	else if(index)
		var/index_ckey
		var/search
		output += "<center><a href='?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
		if(!isnum(index))
			index = sanitizeSQL(index)
		switch(index)
			if(1)
				search = "^."
			if(2)
				search = "^\[^\[:alpha:\]\]"
			else
				search = "^[index]"
		var/DBQuery/query_list_notes = GLOB.dbcon.NewQuery("SELECT DISTINCT ckey FROM [format_table_name("notes")] WHERE ckey REGEXP '[search]' ORDER BY ckey")
		if(!query_list_notes.Execute())
			var/err = query_list_notes.ErrorMsg()
			log_game("SQL ERROR obtaining ckey from notes table. Error : \[[err]\]\n")
			return
		to_chat(usr, "<span class='notice'>Started regex note search for [search]. Please wait for results...</span>")
		message_admins("[usr.ckey] has started a note search with the following regex: [search] | CPU usage may be higher.")
		while(query_list_notes.NextRow())
			index_ckey = query_list_notes.item[1]
			output += "<a href='?_src_=holder;shownoteckey=[index_ckey]'>[index_ckey]</a><br>"
			CHECK_TICK
		message_admins("The note search started by [usr.ckey] has complete. CPU should return to normal.")
	else
		output += "<center><a href='?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
	usr << browse(output, "window=show_notes;size=900x500")

