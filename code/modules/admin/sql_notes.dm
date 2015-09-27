/proc/add_note(target_ckey, notetext, timestamp, adminckey, logged = 1, server, checkrights = 1)
	if(checkrights && !check_rights(R_ADMIN|R_MOD))
		return
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	if(!target_ckey)
		var/new_ckey = ckey(input(usr,"Who would you like to add a note for?","Enter a ckey",null) as text|null)
		if(!new_ckey)
			return
		new_ckey = sanitizeSQL(new_ckey)
		var/DBQuery/query_find_ckey = dbcon.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ckey = '[new_ckey]'")
		if(!query_find_ckey.Execute())
			var/err = query_find_ckey.ErrorMsg()
			log_game("SQL ERROR obtaining ckey from player table. Error : \[[err]\]\n")
			return
		if(!query_find_ckey.NextRow())
			usr << "<span class='redtext'>[new_ckey] has not been seen before, you can only add notes to known players.</span>"
			return
		else
			target_ckey = new_ckey
	var/target_sql_ckey = sanitizeSQL(target_ckey)
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
	var/admin_sql_ckey = sanitizeSQL(adminckey)
	if(!server)
		if (config && config.server_name)
			server = config.server_name
	server = sanitizeSQL(server)
	var/DBQuery/query_noteadd = dbcon.NewQuery("INSERT INTO [format_table_name("notes")] (ckey, timestamp, notetext, adminckey, server) VALUES ('[target_sql_ckey]', '[timestamp]', '[notetext]', '[admin_sql_ckey]', '[server]')")
	if(!query_noteadd.Execute())
		var/err = query_noteadd.ErrorMsg()
		log_game("SQL ERROR adding new note to table. Error : \[[err]\]\n")
		return
	if(logged)
		log_admin("[key_name(usr)] has added a note to [target_ckey]: [notetext]")
		message_admins("[key_name_admin(usr)] has added a note to [target_ckey]:<br>[notetext]")
		show_note(target_ckey)

/proc/remove_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/ckey
	var/notetext
	var/adminckey
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/DBQuery/query_find_note_del = dbcon.NewQuery("SELECT ckey, notetext, adminckey FROM [format_table_name("notes")] WHERE id = [note_id]")
	if(!query_find_note_del.Execute())
		var/err = query_find_note_del.ErrorMsg()
		log_game("SQL ERROR obtaining ckey, notetext, adminckey from player table. Error : \[[err]\]\n")
		return
	if(query_find_note_del.NextRow())
		ckey = query_find_note_del.item[1]
		notetext = query_find_note_del.item[2]
		adminckey = query_find_note_del.item[3]
	var/DBQuery/query_del_note = dbcon.NewQuery("DELETE FROM [format_table_name("notes")] WHERE id = [note_id]")
	if(!query_del_note.Execute())
		var/err = query_del_note.ErrorMsg()
		log_game("SQL ERROR removing note from table. Error : \[[err]\]\n")
		return
	log_admin("[key_name(usr)] has removed a note made by [adminckey] from [ckey]: [notetext]")
	message_admins("[key_name_admin(usr)] has removed a note made by [adminckey] from [ckey]:<br>[notetext]")
	show_note(ckey)

/proc/edit_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/target_ckey
	var/sql_ckey = sanitizeSQL(usr.ckey)
	var/DBQuery/query_find_note_edit = dbcon.NewQuery("SELECT ckey, notetext, adminckey FROM [format_table_name("notes")] WHERE id = [note_id]")
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
		var/DBQuery/query_update_note = dbcon.NewQuery("UPDATE [format_table_name("notes")] SET notetext = '[new_note]', last_editor = '[sql_ckey]', edits = CONCAT(IFNULL(edits,''),'[edit_text]') WHERE id = [note_id]")
		if(!query_update_note.Execute())
			var/err = query_update_note.ErrorMsg()
			log_game("SQL ERROR editing note. Error : \[[err]\]\n")
			return
		log_admin("[key_name(usr)] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[new_note]\"")
		message_admins("[key_name_admin(usr)] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[new_note]\"")
		show_note(target_ckey)

/proc/show_note(target_ckey, index, linkless = 0)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/output
	var/navbar
	var/ruler
	ruler = "<hr style='background:#000000; border:0; height:3px'>"
	navbar = "<a href='?_src_=holder;nonalpha=1'>\[All\]</a>|<a href='?_src_=holder;nonalpha=2'>\[#\]</a>"
	for(var/letter in alphabet)
		navbar += "|<a href='?_src_=holder;shownote=[letter]'>\[[letter]\]</a>"
	navbar += "<br><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='notessearch' value='[index]'>\
	<input type='submit' value='Search'></form>"
	if(!linkless)
		output = navbar
	if(target_ckey)
		var/target_sql_ckey = sanitizeSQL(target_ckey)
		var/DBQuery/query_get_notes = dbcon.NewQuery("SELECT id, timestamp, notetext, adminckey, last_editor, server FROM [format_table_name("notes")] WHERE ckey = '[target_sql_ckey]' ORDER BY timestamp")
		if(!query_get_notes.Execute())
			var/err = query_get_notes.ErrorMsg()
			log_game("SQL ERROR obtaining ckey, notetext, adminckey, last_editor, server from notes table. Error : \[[err]\]\n")
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
			output += "<b>[timestamp] | [server] | [adminckey]</b>"
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
		var/DBQuery/query_list_notes = dbcon.NewQuery("SELECT DISTINCT ckey FROM [format_table_name("notes")] WHERE ckey REGEXP '[search]' ORDER BY ckey")
		if(!query_list_notes.Execute())
			var/err = query_list_notes.ErrorMsg()
			log_game("SQL ERROR obtaining ckey from notes table. Error : \[[err]\]\n")
			return
		while(query_list_notes.NextRow())
			index_ckey = query_list_notes.item[1]
			output += "<a href='?_src_=holder;shownoteckey=[index_ckey]'>[index_ckey]</a><br>"
	else
		output += "<center><a href='?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
	usr << browse(output, "window=show_notes;size=900x500")
	
/proc/regex_note_sql_extract(str, exp)
	return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regEx_find")(str, exp))

// If the AUTOCONVERT_NOTES is turned on, any time a player connects this will be run to try and add all their notes to the database
/proc/convert_notes_sql(ckey)
	if(!ckey)
		return 0
	
	var/playerfile = "data/player_saves/[copytext(ckey, 1, 2)]/[ckey]/info.sav"
	var/savefile/info = new(playerfile)
	var/list/infos
	info >> infos
	if(!infos || !infos.len)
		fdel(playerfile)
		return 0

	ckey = ckey
	for(var/datum/player_info/I in infos)	
		var/notetext = I.content
		var/adminckey = I.author
		var/server
		if (config && config.server_name)
			server = config.server_name
		
		var/timestamp = I.timestamp
		var/regex = "\[A-Za-z\]+\\, (\[A-Za-z\]+) (\[0-9\]+)\[A-Za-z\]+ of (\[0-9\]+)"
		var/datum/regex/results = regex_note_sql_extract(timestamp, regex)
		var/month = month2number(results.str(2))
		var/day = results.str(3)
		var/year = results.str(4)
		timestamp = "[year]-[month]-[day] 00:00:00"

		add_note(ckey, notetext, timestamp, adminckey, 0, server, 0)
		
	fdel(playerfile)
	return 1

// Using this proc causes lag - you have been warned.	
/proc/mass_convert_notes()
	if(!check_rights(R_SERVER))
		return 0
	world << "Beginning mass note conversion."
	
	var/player_notes_file = "data/player_notes.sav"
	var/savefile/notesfile = new(player_notes_file)
	var/list/note_keys
	notesfile >> note_keys

	if(!notesfile)
		log_game("Error: Cannot access player_notes.sav file.")
		return 0
	if(!note_keys || !note_keys.len)
		log_game("Error: player_notes.sav file is empty. Deleting it.")
		fdel(player_notes_file)
		return 0
		
	note_keys = sortList(note_keys)
	var/i = 1
	for(i, i <= note_keys.len, i++)
		var/ckey = note_keys[i]
		convert_notes_sql(ckey)
	world << "Finished mass note conversion ([i] notes converted). Remember to turn off AUTOCONVERT_NOTES."
	world << "Deleting the player_notes.sav file."
	fdel(player_notes_file)	
	return 1
	
/proc/show_player_info_irc(var/key as text)
	var/target_sql_ckey = sanitizeSQL(key)
	var/DBQuery/query_get_notes = dbcon.NewQuery("SELECT timestamp, notetext, adminckey, server FROM [format_table_name("notes")] WHERE ckey = '[target_sql_ckey]' ORDER BY timestamp")
	if(!query_get_notes.Execute())
		var/err = query_get_notes.ErrorMsg()
		log_game("SQL ERROR obtaining timestamp, notetext, adminckey, server from notes table. Error : \[[err]\]\n")
		return
	var/output = " Info on [key]%0D%0A"
	while(query_get_notes.NextRow())
		var/timestamp = query_get_notes.item[1]
		var/notetext = query_get_notes.item[2]
		var/adminckey = query_get_notes.item[3]
		var/server = query_get_notes.item[4]
		output += "[notetext]%0D%0Aby [adminckey] on [timestamp] (Server: [server])%0D%0A%0D%0A"
	return output
