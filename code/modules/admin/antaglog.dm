//////////////////////////////////////////////////////////////////////////////////////
// This file houses all the code for antag tracking datum serialization and deserialization
//
// If you are going to modify ANYTHING in here, please test it THOROUGHLY
// The serialization and deserialization here is so complicated that you WILL break something here
// PLEASE test things properly if you modify this file. -aa07
//
//////////////////////////////////////////////////////////////////////////////////////


// All these defines are integral to the workings and mesh together with the database.
// DO NOT EDIT THESE UNDER ANY CIRCUMSTANCES EVER
#define ANTAGRECORD_FIRST_INFRACTION "First infraction: "
#define ANTAGRECORD_LAST_INFRACTION "Last infraction: "
#define ANTAGRECORD_TOTAL_INFRACTIONS "Total infractions: "

/datum/antag_record
	var/holder_ckey
	var/first_infraction_date
	var/last_infraction_date
	var/infraction_count
	var/has_note = FALSE

/datum/antag_record/New(_holder_ckey)
	holder_ckey = _holder_ckey

/datum/antag_record/proc/handle_data(datum/db_query/Q)
	var/notetxt = null

	while(Q.NextRow())
		notetxt = Q.item[1]

	if(notetxt)
		has_note = TRUE
		deserialize_and_load(notetxt)
		infraction_count++
	else
		// Sane defaults
		first_infraction_date = SQLtime()
		infraction_count = 1

	last_infraction_date = SQLtime()

// Seems pointless but it allows code to flow smoother
// Also I grew too dependant on languages that have nice syntax stuff
/datum/antag_record/proc/get_load_query()
	return SSdbcore.NewQuery("SELECT notetext FROM notes WHERE ckey=:ckey AND adminckey=:ackey LIMIT 1", list(
		"ckey" = holder_ckey,
		"ackey" = ANTAGTRACKING_PSUEDO_CKEY
	))

/*
	Expected output below. These are parsed from raw_text by splitting by <br>
	[1] ANTAGRECORD_FIRST_INFRACTION
	[2] ANTAGRECORD_LAST_INFRACTION
	[3] ANTAGRECORD_TOTAL_INFRACTIONS
*/

/datum/antag_record/proc/deserialize_and_load(raw_text)
	var/list/lines = splittext(raw_text, "<br>")
	// Text
	first_infraction_date = splittext(lines[1], ANTAGRECORD_FIRST_INFRACTION)[2]
	last_infraction_date = splittext(lines[2], ANTAGRECORD_LAST_INFRACTION)[2]
	// Number
	infraction_count = text2num(splittext(lines[3], ANTAGRECORD_TOTAL_INFRACTIONS)[2]) // Make sure its a number

/datum/antag_record/proc/get_save_query()
	var/serialized_text
	var/list/serialized_list = list()
	serialized_list.len = 3 // Make it 3 off the bat

	serialized_list[1] = "[ANTAGRECORD_FIRST_INFRACTION][first_infraction_date]"
	serialized_list[2] = "[ANTAGRECORD_LAST_INFRACTION][last_infraction_date]"
	serialized_list[3] = "[ANTAGRECORD_TOTAL_INFRACTIONS][infraction_count]"

	serialized_text = serialized_list.Join("<br>")

	if(has_note) // They have a note. Update.
		var/datum/db_query/update_existing_note = SSdbcore.NewQuery("UPDATE notes SET notetext=:nt, timestamp=NOW(), round_id=:rid WHERE ckey=:ckey AND adminckey=:ackey", list(
			"nt" = serialized_text,
			"rid" = GLOB.round_id,
			"ckey" = holder_ckey,
			"ackey" = ANTAGTRACKING_PSUEDO_CKEY
		))

		return update_existing_note
	else
		// They dont have a note. Make an insert query.
		// To the person who asks "why dont you juse use add_note()"
		// By making a query batch, we can use async magic to make it go faster
		var/datum/db_query/query_noteadd = SSdbcore.NewQuery({"
			INSERT INTO notes (ckey, timestamp, notetext, adminckey, server, round_id, automated)
			VALUES (:targetckey, NOW(), :notetext, :adminkey, :server, :roundid, 1)
		"}, list(
			"targetckey" = holder_ckey,
			"notetext" = serialized_text,
			"adminkey" = ANTAGTRACKING_PSUEDO_CKEY,
			"server" = GLOB.configuration.system.instance_id,
			"roundid" = GLOB.round_id,
			"automated" = TRUE
		))

		return query_noteadd

#undef ANTAGRECORD_FIRST_INFRACTION
#undef ANTAGRECORD_LAST_INFRACTION
#undef ANTAGRECORD_TOTAL_INFRACTIONS
