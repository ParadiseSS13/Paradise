/datum/client_login_processor/cid_count
	priority = 39

/datum/client_login_processor/cid_count/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT COUNT(DISTINCT computerID) FROM connection_log WHERE ckey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/cid_count/process_result(datum/db_query/Q, client/C)
	// If the config is 0, disable this
	if(GLOB.configuration.general.max_client_cid_history == 0)
		return

	// Now query how many cids they have
	var/cidcount = 0
	if(Q.NextRow())
		cidcount = Q.item[1]

	if(cidcount > GLOB.configuration.general.max_client_cid_history)
		// Check their notes for CID tracking in the past
		var/has_note = FALSE
		var/note_text = ""
		var/datum/db_query/query_find_track_note = SSdbcore.NewQuery("SELECT notetext FROM notes WHERE ckey=:ckey AND adminckey=:ackey", list(
			"ckey" = C.ckey,
			"ackey" = CIDTRACKING_PSUEDO_CKEY
		))
		if(!query_find_track_note.warn_execute())
			qdel(query_find_track_note)
			return
		if(query_find_track_note.NextRow())
			note_text = query_find_track_note.item[1] // Grab existing note text
			has_note = TRUE
		qdel(query_find_track_note)


		if(has_note) // They have a note. Update it.
			var/new_text = "Connected on the date of this note with unique CID #[cidcount]"
			// Only update the note if the text is different. Otherwise it bumps the timestamp when it shouldnt
			if(note_text != new_text)
				var/datum/db_query/query_update_track_note = SSdbcore.NewQuery("UPDATE notes SET notetext=:notetext, timestamp=NOW(), round_id=:rid WHERE ckey=:ckey AND adminckey=:ackey", list(
					"notetext" = new_text,
					"ckey" = C.ckey,
					"ackey" = CIDTRACKING_PSUEDO_CKEY,
					"rid" = GLOB.round_id
				))
				if(!query_update_track_note.warn_execute())
					qdel(query_update_track_note)
					return
				qdel(query_update_track_note)

		else // They dont have a note. Make one.
			// NOT logged because its automatic and will spam logs otherwise
			// Also right checking must be disabled because its a psuedockey, not a real one
			add_note(C.ckey, "Connected on the date of this note with unique CID #[cidcount]", adminckey = CIDTRACKING_PSUEDO_CKEY, logged = FALSE, checkrights = FALSE, automated = TRUE)

		var/show_warning = TRUE
		// Check if they have a note that matches the warning suppressor
		var/datum/db_query/query_find_note = SSdbcore.NewQuery("SELECT id FROM notes WHERE ckey=:ckey AND notetext=:notetext", list(
			"ckey" = C.ckey,
			"notetext" = CIDWARNING_SUPPRESSED_NOTETEXT
		))
		if(!query_find_note.warn_execute())
			qdel(query_find_note)
			return
		if(query_find_note.NextRow())
			show_warning = FALSE
		qdel(query_find_note)

		if(show_warning)
			message_admins("<font color='red'>[C.ckey] has just connected and has a history of [cidcount] different CIDs.</font> (<a href='byond://?_src_=holder;webtools=[C.ckey]'>WebInfo</a>) (<a href='byond://?_src_=holder;suppresscidwarning=[C.ckey]'>Suppress Warning</a>)")
