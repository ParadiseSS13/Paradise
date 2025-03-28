/proc/add_note(target_ckey, notetext, timestamp, adminckey, logged = 1, checkrights = 1, show_after = TRUE, automated = FALSE, sanitise_html = TRUE, public = FALSE) // Dont you EVER disable 'sanitise_html', only automated systems should use this
	if(checkrights && !check_rights(R_ADMIN|R_MOD))
		return
	if(IsAdminAdvancedProcCall() && !sanitise_html)
		// *sigh*
		to_chat(usr, "<span class='boldannounceooc'>Unsanitized note add blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to possibly inject HTML into notes via advanced proc-call")
		log_admin("[key_name(usr)] attempted to possibly inject HTML into notes via advanced proc-call")
		return

	if(!SSdbcore.IsConnected())
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

	var/datum/db_query/query_find_ckey = SSdbcore.NewQuery("SELECT ckey, exp FROM player WHERE ckey=:ckey", list(
		"ckey" = target_ckey
	))

	if(!query_find_ckey.warn_execute())
		qdel(query_find_ckey)
		return

	var/ckey_found = FALSE
	var/exp_data
	while(query_find_ckey.NextRow())
		exp_data = query_find_ckey.item[2]
		ckey_found = TRUE

	qdel(query_find_ckey)

	if(!ckey_found)
		if(usr)
			to_chat(usr, "<span class='redtext'>[target_ckey] has not been seen before, you can only add notes to known players.</span>")
		return

	var/crew_number = 0
	if(exp_data)
		var/list/play_records = params2list(exp_data)
		crew_number = play_records[EXP_TYPE_CREW]

	if(!notetext)
		notetext = input(usr,"Write your note","Add Note") as message|null
		if(!notetext)
			return
		public = (alert(usr, "Would you like to make this note public?", "Public Note?", "Private", "Public") == "Public")

	if(!adminckey)
		adminckey = usr.ckey
		if(!adminckey)
			return
	else if(usr && (usr.ckey == ckey(adminckey))) // Don't ckeyize special note sources
		adminckey = ckey(adminckey)

	// Force cast this to 1/0 incase someone tries to feed bad data
	automated = !!automated

	if(sanitise_html)
		notetext = html_encode(notetext)

	var/datum/db_query/query_noteadd = SSdbcore.NewQuery({"
		INSERT INTO notes (ckey, timestamp, notetext, adminckey, server, crew_playtime, round_id, automated, public)
		VALUES (:targetckey, NOW(), :notetext, :adminkey, :server, :crewnum, :roundid, :automated, :public)
	"}, list(
		"targetckey" = target_ckey,
		"notetext" = notetext,
		"adminkey" = adminckey,
		"server" = GLOB.configuration.system.instance_id,
		"crewnum" = crew_number,
		"roundid" = GLOB.round_id,
		"automated" = automated,
		"public" = public
	))
	if(!query_noteadd.warn_execute())
		qdel(query_noteadd)
		return
	qdel(query_noteadd)
	if(logged)
		log_admin("[usr ? key_name(usr) : adminckey] has added a [public ? "public" : "private"] note to [target_ckey]: [notetext]")
		message_admins("[usr ? key_name_admin(usr) : adminckey] has added a [public ? "public" : "private"] note to [target_ckey]:<br>[notetext]")
		if(show_after)
			show_note(target_ckey)

/proc/remove_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/ckey
	var/notetext
	var/adminckey
	if(!SSdbcore.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/datum/db_query/query_find_note_del = SSdbcore.NewQuery("SELECT ckey, notetext, adminckey FROM notes WHERE id=:note_id", list(
		"note_id" = note_id
	))
	if(!query_find_note_del.warn_execute())
		qdel(query_find_note_del)
		return
	if(query_find_note_del.NextRow())
		ckey = query_find_note_del.item[1]
		notetext = query_find_note_del.item[2]
		adminckey = query_find_note_del.item[3]
	qdel(query_find_note_del)

	var/datum/db_query/query_del_note = SSdbcore.NewQuery("UPDATE notes SET deleted=1, deletedby=:ckey WHERE id=:note_id", list(
		"ckey" = usr.ckey,
		"note_id" = note_id
	))
	if(!query_del_note.warn_execute())
		qdel(query_del_note)
		return
	qdel(query_del_note)

	var/safe_text = html_encode(notetext)

	log_admin("[usr ? key_name(usr) : "Bot"] has removed a note made by [adminckey] from [ckey]: [safe_text]")
	message_admins("[usr ? key_name_admin(usr) : "Bot"] has removed a note made by [adminckey] from [ckey]:<br>[safe_text]")
	show_note(ckey)

/proc/edit_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	if(!SSdbcore.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/target_ckey
	var/datum/db_query/query_find_note_edit = SSdbcore.NewQuery("SELECT ckey, notetext, adminckey, automated FROM notes WHERE id=:note_id", list(
		"note_id" = note_id
	))
	if(!query_find_note_edit.warn_execute())
		qdel(query_find_note_edit)
		return
	if(query_find_note_edit.NextRow())
		target_ckey = query_find_note_edit.item[1]
		var/old_note = query_find_note_edit.item[2]
		var/adminckey = query_find_note_edit.item[3]
		var/automated = query_find_note_edit.item[4]
		if(automated)
			to_chat(usr, "<span class='notice'>That note is generated automatically. You can't edit it.</span>")
			return
		var/new_note = input("Input new note", "New Note", "[old_note]") as message|null
		if(!new_note)
			return

		var/safe_text = html_encode(new_note)

		var/edit_text = "Edited by [usr.ckey] on [SQLtime()] from \"[old_note]\" to \"[safe_text]\"<hr>"
		var/datum/db_query/query_update_note = SSdbcore.NewQuery("UPDATE notes SET notetext=:new_note, last_editor=:akey, edits = CONCAT(IFNULL(edits,''),:edit_text) WHERE id=:note_id", list(
			"new_note" = safe_text,
			"akey" = usr.ckey,
			"edit_text" = edit_text,
			"note_id" = note_id
		))
		if(!query_update_note.warn_execute())
			qdel(query_update_note)
			return
		log_admin("[usr ? key_name(usr) : "Bot"] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[safe_text]\"")
		message_admins("[usr ? key_name_admin(usr) : "Bot"] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[safe_text]\"")
		show_note(target_ckey)
		qdel(query_update_note)

/proc/show_note(target_ckey, index, linkless = 0)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/list/output = list("<!DOCTYPE html>")
	var/list/navbar = list()
	var/ruler = "<hr style='background:#000000; border:0; height:3px'>"

	navbar = "<meta charset='UTF-8'><a href='byond://?_src_=holder;nonalpha=1'>\[All\]</a>|<a href='byond://?_src_=holder;nonalpha=2'>\[#\]</a>"
	for(var/letter in GLOB.alphabet)
		navbar += "|<a href='byond://?_src_=holder;shownote=[letter]'>\[[letter]\]</a>"

	navbar += "<br><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='notessearch' value='[index]'>\
	<input type='submit' value='Search'></form>"
	if(!linkless)
		output += navbar
	if(target_ckey)
		var/target_sql_ckey = ckey(target_ckey)
		var/datum/db_query/query_get_notes = SSdbcore.NewQuery({"
			SELECT id, timestamp, notetext, adminckey, last_editor, server, crew_playtime, round_id, automated, public
			FROM notes WHERE ckey=:targetkey AND deleted=0 ORDER BY timestamp"}, list(
				"targetkey" = target_sql_ckey
			))
		if(!query_get_notes.warn_execute())
			qdel(query_get_notes)
			return
		output += "<h2><center>Notes of [target_ckey]</center></h2>"
		if(!linkless)
			output += "<center><a href='byond://?_src_=holder;addnote=[target_ckey]'>\[Add Note\]</a></center>"
		output += ruler
		while(query_get_notes.NextRow())
			var/id = query_get_notes.item[1]
			var/timestamp = query_get_notes.item[2]
			var/notetext = query_get_notes.item[3]
			var/adminckey = query_get_notes.item[4]
			var/last_editor = query_get_notes.item[5]
			var/server = query_get_notes.item[6]
			var/mins = text2num(query_get_notes.item[7])
			var/round_id = text2num(query_get_notes.item[8])
			var/automated = text2num(query_get_notes.item[9]) // 0/1 bool stored in table
			var/public = text2num(query_get_notes.item[10]) // 0/1 bool stored in table
			output += "<b>[timestamp][round_id ? " (Round [round_id])" : ""] | [server] | [adminckey]"
			if(mins)
				var/playstring = get_exp_format(mins)
				output += " | [playstring] as Crew"
			output += "</b>"

			if(!linkless)
				var/note_publicity = (public ? "Public Note" : "PRIVATE Note")
				if(adminckey == usr.ckey)
					note_publicity = "<a href='byond://?_src_=holder;toggle_note_publicity=[id]'>\[[note_publicity]]</a>"

				output += " <a href='byond://?_src_=holder;removenote=[id]'>\[Remove Note\]</a> \
					[automated ? "\[Automated Note\]" : "<a href='byond://?_src_=holder;editnote=[id]'>\[Edit Note\]</a>"] \
					[note_publicity]"

				if(last_editor)
					output += " <font size='2'>Last edit by [last_editor] <a href='byond://?_src_=holder;noteedits=[id]'>(Click here to see edit log)</a></font>"
			output += "<br>[replacetext(notetext, "\n", "<br>")]<hr style='background:#000000; border:0; height:1px'>"
		qdel(query_get_notes)
	else if(index)
		var/index_ckey
		var/search
		output += "<center><a href='byond://?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
		switch(index)
			if(1)
				search = "^."
			if(2)
				search = "^\[^\[:alpha:\]\]"
			else
				search = "^[index]"
		var/datum/db_query/query_list_notes = SSdbcore.NewQuery("SELECT DISTINCT ckey FROM notes WHERE ckey REGEXP :search ORDER BY ckey", list(
			"search" = search
		))
		if(!query_list_notes.warn_execute())
			qdel(query_list_notes)
			return
		to_chat(usr, "<span class='notice'>Started regex note search for [search]. Please wait for results...</span>")
		message_admins("[usr.ckey] has started a note search with the following regex: [search] | CPU usage may be higher.")
		while(query_list_notes.NextRow())
			index_ckey = query_list_notes.item[1]
			output += "<a href='byond://?_src_=holder;shownoteckey=[index_ckey]'>[index_ckey]</a><br>"
			CHECK_TICK
		qdel(query_list_notes)
		message_admins("The note search started by [usr.ckey] has completed. CPU should return to normal.")
	else
		output += "<center><a href='byond://?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
	usr << browse(output.Join(""), "window=show_notes;size=900x500")

/proc/toggle_note_publicity(note_id)
	if(!usr)
		return
	if(!check_rights(R_ADMIN|R_MOD))
		return
	if(!SSdbcore.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/datum/db_query/query_find_note_edit = SSdbcore.NewQuery("SELECT ckey, notetext, adminckey, automated, public FROM notes WHERE id=:note_id", list(
		"note_id" = note_id
	))
	if(!query_find_note_edit.warn_execute())
		qdel(query_find_note_edit)
		return
	if(query_find_note_edit.NextRow())
		var/target_ckey = query_find_note_edit.item[1]
		var/text = query_find_note_edit.item[2]
		var/adminckey = query_find_note_edit.item[3]
		var/automated = query_find_note_edit.item[4]
		var/public = query_find_note_edit.item[5]
		if((!adminckey || adminckey != usr.ckey) && !check_rights(R_PERMISSIONS))
			to_chat(usr, "<span class='notice'>You cannot toggle the publicity of notes created by other users.</span>")
			return
		if(automated)
			to_chat(usr, "<span class='notice'>That note is generated automatically. You can't edit it.</span>")
			return

		if(public)
			if(alert(usr, "Are you sure you want to make this note private?", "Private Note?", "Yes", "No") != "Yes")
				return
		else
			if(alert(usr, "Are you sure you want to make this note public?", "Public Note?", "Yes", "No") != "Yes")
				return

		public = !public
		var/datum/db_query/query_update_note = SSdbcore.NewQuery("UPDATE notes SET public=:new_public WHERE id=:note_id", list(
			"new_public" = public,
			"note_id" = note_id
		))
		if(!query_update_note.warn_execute())
			qdel(query_update_note)
			return
		log_admin("[key_name(usr)] has made [target_ckey]'s note [public ? "public" : "private"], contents are \"[text]\".")
		message_admins("[key_name_admin(usr)] has edited [target_ckey]'s note [public ? "public" : "private"], contents are \"[text]\".")
		show_note(target_ckey)
		qdel(query_update_note)
